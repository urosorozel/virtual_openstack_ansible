#!/bin/bash
virsh list --name | egrep 'util|ceph|comp|pro|inf|log|iro' | xargs -Ixx bash -c "virsh reset xx"
