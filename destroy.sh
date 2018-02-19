#!/bin/bash
# Destroy undefine all
virsh list --name | egrep 'util|ceph|comp|pro|inf|log|iro' | xargs -Ixx bash -c "virsh destroy xx;virsh undefine xx"

# Delete all volumes
virsh vol-list vgdata1 |egrep 'util|ceph|comp|pro|inf|log|iro' | egrep img | awk '{print $1}' | xargs -Ixx  virsh vol-delete xx vgdata1
