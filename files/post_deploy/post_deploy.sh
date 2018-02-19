#!/bin/bash
export CONTENT="Content-Type: application/json"
export API='Openstack-API-Version: placement 1.10'
source openrc

wget -q http://tarballs.openstack.org/ironic-python-agent/tinyipa/files/tinyipa-stable-pike.vmlinuz  -O tinyipa_production_pxe.vmlinuz
wget -q http://tarballs.openstack.org/ironic-python-agent/tinyipa/files/tinyipa-stable-pike.gz -O tinyipa_production_pxe_image-oem.cpio.gz
# Load deployment image kernel into glance
DEPLOY_VMLINUZ_UUID=$(glance image-create --name deploy-vmlinuz --visibility public --disk-format aki \
--container-format aki --file tinyipa_production_pxe.vmlinuz | awk '/id/ {print $4}')

# Load deployment image ramdisk into glance
DEPLOY_INITRD_UUID=$(glance image-create --name deploy-initrd --visibility public --disk-format aki \
--container-format aki --file tinyipa_production_pxe_image-oem.cpio.gz | awk '/id/ {print $4}')

# Clean up source files
rm tinyipa_production_pxe.vmlinuz tinyipa_production_pxe_image-oem.cpio.gz

guest_url=http://download.cirros-cloud.net/0.3.5/cirros-0.3.5-x86_64-disk.img
guest_filename=${guest_url##*/}

wget -q $guest_url -O $guest_filename

glance image-create --name $guest_filename --visibility public --disk-format qcow2 --container-format bare --file $guest_filename
rm $guest_filename

# Flavors
nova flavor-create virtual-flavor 200 256 1 1
nova flavor-create baremetal-flavor 400 1024 10 1
nova flavor-key  virtual-flavor set  baremetal=false
nova flavor-key  baremetal-flavor  set  baremetal=true
#nova flavor-key  baremetal-flavor  set cpu_arch=x86_64
openstack aggregate set --property baremetal=false virtual-hosts
openstack aggregate set --property baremetal=true baremetal-hosts


TOKEN=$(openstack token issue | grep " id" | awk '{ print $4}')
export TOKEN="X-Auth-Token: ${TOKEN}"

PLACEMENT_API=$(openstack endpoint list | grep place| grep internal | awk '{print $14}')

# Create custom resource class
RS_PROVIDERS=/resource_providers
DATA='{"name": "CUSTOM_BAREMETAL_SMALL"}'
curl -s -X POST $PLACEMENT_API/resource_classes -H "$CONTENT" -H "$TOKEN" -H "$API" -d "$DATA"

nova flavor-key baremetal-flavor set resources:CUSTOM_BAREMETAL_SMALL=1
# enroll ironic nodes

source enroll/bin/activate
export OS_CACERT=''
source openrc

python enroll_ironic.py --deploy-kernel $DEPLOY_VMLINUZ_UUID  --deploy-ramdisk $DEPLOY_INITRD_UUID ironic_nodes.yml ironic_nodes.yml
# Wait for ironic nodes available in resource list
sleep 45

# Attach custom resource class to ironic node resource inventory
DATA='{"resource_provider_generation": 1, "inventories": {"VCPU": {"allocation_ratio": 1.0, "total": 1, "reserved": 0, "step_size": 1, "min_unit": 1, "max_unit": 1}, "MEMORY_MB": {"allocation_ratio": 1.0, "total": 1024, "reserved": 0, "step_size": 1, "min_unit": 1, "max_unit": 1024}, "DISK_GB": {"allocation_ratio": 1.0, "total": 10, "reserved": 0, "step_size": 1, "min_unit": 1, "max_unit": 10}, "CUSTOM_BAREMETAL_SMALL": {"allocation_ratio": 1.0, "total": 1, "reserved": 0, "step_size": 1, "min_unit": 1, "max_unit": 1}}}'

for IRONIC in $(ironic node-list| grep ironic | awk '{print $2}'); do
  openstack  baremetal node set $IRONIC  --resource-class baremetal.small
  PROVIDER=$(openstack resource provider list| grep $IRONIC| awk '{print $2}')
  #;echo $PROVIDER;done
  curl -s -X PUT $PLACEMENT_API/resource_providers/$PROVIDER/inventories -H "$CONTENT" -H "$TOKEN" -H "$API" -d "$DATA" | python -m json.tool
done

# clean
#  glance image-list | egrep -v '\+|ID' | awk '{ print $2}' | xargs glance image-delete
#  nova flavor-list |egrep -v '\+|ID' | awk '{ print $4}' | xargs -Ixx nova flavor-delete xx
# ironic node-list | egrep -v '\+|ID' | awk '{ print $4}' | xargs -Ixx ironic node-delete xx

# boot
# nova boot --flavor baremetal-flavor --image cirros-0.3.5-x86_64-disk.img --nic net-name=public baremetal
# nova boot --flavor virtual-flavor --security-groups server_ssh_icmp --image cirros-0.3.5-x86_64-disk.img --nic net-name=public virtual
