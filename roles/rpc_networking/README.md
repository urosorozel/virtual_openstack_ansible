rpc_networking
==============

This role is specifically for setting up networking in Rackspace Private Cloud OpenStack environments.

In order for this Ansible Role to work, your Ansible Root Directory must contain a __host_vars__ folder. Inside that folder will be a file for every server in your environment. Each file needs to be named after their respective server.

## Single Network Interfaces

If you are using single network interfaces, i.e. no bonding, each server's host_vars will have the following configuration (the IP addresses will be different for each file). The __mtu__ key is optional and will default to 1500 if not specified.

    ---
    rpc_networking:
        template: interfaces-single.j2
        host:
          interface: em1
          address: 10.240.0.200
          netmask: 255.255.252.0
          gateway: 10.240.0.1
          nameservers: '8.8.8.8 8.8.4.4'
          mtu: 1500
        mgmt:
          interface: em2
          vlan: 10
          address: 172.29.236.51
          netmask: 255.255.252.0
          mtu: 1500
        storage:
          interface: em2
          vlan: 20
          address: 172.29.240.51
          netmask: 255.255.252.0
          mtu: 1500
        vlan:
          interface: em2
          mtu: 1500
        vxlan:
          interface: em2
          vlan: 30
          address: 172.29.244.51
          netmask: 255.255.252.0
          mtu: 1500
        swift:
          interface: em2
          vlan: 40
          address: 172.29.248.51
          netmask: 255.255.252.0
          mtu: 1500

## Active-Passive Bonding

If you are using active-passive bonding, each server's host_vars will have the following configuration (the IP addresses will be different for each file). The __mtu__ key is optional and will default to 1500 if not specified.

    ---
    rpc_networking:
        template: interfaces-active-passive.j2
        bond_interfaces:
          - name: p1p1
            bond: bond0
            bond_primary: true
            mtu: 1500
          - name: p1p2
            bond: bond1
            bond_primary: true
            mtu: 1500
          - name: p4p1
            bond: bond0
            mtu: 1500
          - name: p4p2
            bond: bond1
            mtu: 1500
        host:
          interface: bond0
          address: 10.240.0.200
          netmask: 255.255.252.0
          gateway: 10.240.0.1
          nameservers: '8.8.8.8 8.8.4.4'
          mtu: 1500
        mgmt:
          interface: bond0
          vlan: 10
          address: 172.29.236.51
          netmask: 255.255.252.0
          mtu: 1500
        storage:
          interface: bond0
          vlan: 20
          address: 172.29.240.51
          netmask: 255.255.252.0
          mtu: 1500
        vlan:
          interface: bond1
          mtu: 1500
        vxlan:
          interface: bond1
          vlan: 30
          address: 172.29.244.51
          netmask: 255.255.252.0
          mtu: 1500
        swift:
          interface: bond1
          vlan: 40
          address: 172.29.248.51
          netmask: 255.255.252.0
          mtu: 1500

## Active-Active Bonding

If you are using active-active bonding, each server's host_vars will have the following configuration (the IP addresses will be different for each file). The __mtu__ key is optional and will default to 1500 if not specified.

    ---
    rpc_networking:
        template: interfaces-active-active.j2
        bond_interfaces:
          - name: p1p1
            bond: bond0
            mtu: 1500
          - name: p1p2
            bond: bond1
            mtu: 1500
          - name: p4p1
            bond: bond0
            mtu: 1500
          - name: p4p2
            bond: bond1
            mtu: 1500
        host:
          interface: bond0
          address: 10.240.0.200
          netmask: 255.255.252.0
          gateway: 10.240.0.1
          nameservers: '8.8.8.8 8.8.4.4'
          mtu: 1500
        mgmt:
          interface: bond0
          vlan: 10
          address: 172.29.236.51
          netmask: 255.255.252.0
          mtu: 1500
        storage:
          interface: bond0
          vlan: 20
          address: 172.29.240.51
          netmask: 255.255.252.0
          mtu: 1500
        vlan:
          interface: bond1
          mtu: 1500
        vxlan:
          interface: bond1
          vlan: 30
          address: 172.29.244.51
          netmask: 255.255.252.0
          mtu: 1500
        swift:
          interface: bond1
          vlan: 40
          address: 172.29.248.51
          netmask: 255.255.252.0
          mtu: 1500

## PLUMgrid

### All Nodes

All nodes connecting to the Fabric Network will have the following configuration (the IP addresses will be different for each file). The __mtu__ key is optional for everything but the __plumgrid__ interface; for all other interfaces it will default to 1500 if not specified.

    ---
    rpc_networking:
        template: interfaces-single-plumgrid.j2
        host:
          interface: em1
          address: 10.240.0.200
          netmask: 255.255.252.0
          gateway: 10.240.0.1
          nameservers: '8.8.8.8 8.8.4.4'
          mtu: 1500
        mgmt:
          interface: em2
          vlan: 10
          address: 172.29.236.51
          netmask: 255.255.252.0
          mtu: 1500
        storage:
          interface: em2
          vlan: 20
          address: 172.29.240.51
          netmask: 255.255.252.0
          mtu: 1500
        plumgrid:
          interface: em2
          address: 172.29.252.51
          netmask: 255.255.252.0
          mtu: 1580
        vxlan:
          interface: em2
          vlan: 30
          address: 172.29.244.51
          netmask: 255.255.252.0
          mtu: 1500
        swift:
          interface: em2
          vlan: 40
          address: 172.29.248.51
          netmask: 255.255.252.0
          mtu: 1500

### LCM Node

The node responsible for hosting the LCM virtual machine will have the following configuration (the IP addresses will be different for each file). The __mtu__ key is optional for everything but the __plumgrid__ interface; for all other interfaces it will default to 1500 if not specified.

    ---
    rpc_networking:
        template: interfaces-single-plumgrid-lcm.j2
        host:
          interface: em1
          address: 10.240.0.200
          netmask: 255.255.252.0
          gateway: 10.240.0.1
          nameservers: '8.8.8.8 8.8.4.4'
          mtu: 1500
        mgmt:
          interface: em2
          vlan: 10
          address: 172.29.236.51
          netmask: 255.255.252.0
          mtu: 1500
        storage:
          interface: em2
          vlan: 20
          address: 172.29.240.51
          netmask: 255.255.252.0
          mtu: 1500
        plumgrid:
          interface: em2
          address: 172.29.252.51
          netmask: 255.255.252.0
          mtu: 1580
        vxlan:
          interface: em2
          vlan: 30
          address: 172.29.244.51
          netmask: 255.255.252.0
          mtu: 1500
        swift:
          interface: em2
          vlan: 40
          address: 172.29.248.51
          netmask: 255.255.252.0
          mtu: 1500

### Gateway Nodes

All nodes acting as Gateway nodes will have the following configuration (the IP addresses will be different for each file). The __mtu__ key is optional for everything but the __plumgrid__ and __plumgrid_gateway__ interfaces; for all other interfaces it will default to 1500 if not specified.

    ---
    rpc_networking:
        template: interfaces-single-plumgrid.j2
        host:
          interface: em1
          address: 10.240.0.200
          netmask: 255.255.252.0
          gateway: 10.240.0.1
          nameservers: '8.8.8.8 8.8.4.4'
          mtu: 1500
        mgmt:
          interface: em2
          vlan: 10
          address: 172.29.236.51
          netmask: 255.255.252.0
          mtu: 1500
        storage:
          interface: em2
          vlan: 20
          address: 172.29.240.51
          netmask: 255.255.252.0
          mtu: 1500
        plumgrid:
          interface: em2
          address: 172.29.252.51
          netmask: 255.255.252.0
          mtu: 1580
        plumgrid_gateway:
          interface: em3
          vlan: 50
          mtu: 1580
        vxlan:
          interface: em2
          vlan: 30
          address: 172.29.244.51
          netmask: 255.255.252.0
          mtu: 1500
        swift:
          interface: em2
          vlan: 40
          address: 172.29.248.51
          netmask: 255.255.252.0
          mtu: 1500
