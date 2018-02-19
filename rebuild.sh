#!/bin/bash

function reset_vms(){
  echo "Reset all VM's"
  virsh list --name | egrep 'util|ceph|comp|pro|inf|log|iro' | xargs -Ixx bash -c "virsh reset xx"
  echo "Sleeping 30sec to allow boot"
  sleep 35
}

function chech_health(){
echo "Check health..."
ansible -i environments/ceph/hosts  -m ping all
if [[ $? -eq 4 ]];then
  reset_vms
  ansible -i environments/ceph/hosts  -m ping all
  if [[ $? -eq 4 ]];then
     echo "Provisioning failure, exiting ..."
     exit 1
  fi
fi
}

virsh list --name | egrep 'util|ceph|comp|pro|inf|log|iro' | xargs -Ixx bash -c "virsh destroy xx;virsh undefine xx"
virsh vol-list vgdata1 |egrep 'util|ceph|comp|pro|inf|log|iro' | egrep img | awk '{print $1}' | xargs -Ixx  virsh vol-delete xx vgdata1
ansible-playbook -i environments/ceph/hosts  build_vms.yml
echo "Sleeping 50 sec to allow boot"
sleep 50

chech_health

ansible-playbook  -i environments/ceph/hosts set_network.yml
ansible-playbook  -i environments/ceph/hosts set_swift.yml
reset_vms
chech_health
ansible-playbook  -i environments/ceph/hosts set_openstack.yml
