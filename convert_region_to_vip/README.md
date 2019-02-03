# Convert a CloudForms/MIQ region to use a Virtual IP

This playbook takes a standard deployment and updates it to use a virtual IP for the
primary database. This VIP fails over when the primary fails over to the standby,
thereby eliminating the requirement to restart evmserverd when the failover occurs.

**Note**: the evmserverd service needs to restart for this change to take effect. This will
trigger an outage of the region.

# Variables

Ensure the following variables are defined:

`vmdb_current_primary_ip`: the current IP for your primary database.
`vmdb_virtual_ip`: the VIP you wish to use 
`vmdb_password`: the password to access your VMDB (default username is 'root')

See the top of the playbook for more detail about the remainder of the variables.

# Running the playbook

```
ansible-playbook convert_region_to_vip.yml -u <username> -k -K
```

Pass in your username and SSH/SUDO passwords as required.

# Verify the result

On the primary database:
```
[root@cfme-1 ~]# ip a | grep 192.168.0.28
    inet 192.168.0.28/32 scope global eth0

[root@cfme-1 ~]# journalctl -u keepalived
...
Feb 02 06:14:59 cfme-1.home.ajg.id.au Keepalived_vrrp[18188]: VRRP_Instance(VI_1) Entering BACKUP STATE
Feb 02 06:14:59 cfme-1.home.ajg.id.au Keepalived_vrrp[18188]: VRRP sockpool: [ifindex(2), proto(112), unicast(1), fd(10,11)]
Feb 02 06:14:59 cfme-1.home.ajg.id.au systemd[1]: Started LVS and VRRP High Availability Monitor.
Feb 02 06:14:59 cfme-1.home.ajg.id.au Keepalived_healthcheckers[18187]: Opening file '/etc/keepalived/keepalived.conf'.
Feb 02 06:15:00 cfme-1.home.ajg.id.au Keepalived_vrrp[18188]: VRRP_Script(chk_pgsql_primary) succeeded
Feb 02 06:15:03 cfme-1.home.ajg.id.au Keepalived_vrrp[18188]: VRRP_Instance(VI_1) Transition to MASTER STATE
Feb 02 06:15:04 cfme-1.home.ajg.id.au Keepalived_vrrp[18188]: VRRP_Instance(VI_1) Entering MASTER STATE
Feb 02 06:15:04 cfme-1.home.ajg.id.au Keepalived_vrrp[18188]: VRRP_Instance(VI_1) setting protocol VIPs.
Feb 02 06:15:04 cfme-1.home.ajg.id.au Keepalived_vrrp[18188]: Sending gratuitous ARP on eth0 for 192.168.0.28
...
```
On the standby database:

```
[root@cfme-2 ~]# journalctl -u keepalived
...
Feb 02 06:14:59 cfme-2.home.ajg.id.au Keepalived_vrrp[16477]: VRRP_Instance(VI_1) removing protocol VIPs.
Feb 02 06:14:59 cfme-2.home.ajg.id.au Keepalived_vrrp[16477]: Using LinkWatch kernel netlink reflector...
Feb 02 06:14:59 cfme-2.home.ajg.id.au Keepalived_vrrp[16477]: VRRP_Instance(VI_1) Entering BACKUP STATE
Feb 02 06:14:59 cfme-2.home.ajg.id.au Keepalived_vrrp[16477]: VRRP sockpool: [ifindex(2), proto(112), unicast(1), fd(10,11)]
Feb 02 06:15:00 cfme-2.home.ajg.id.au Keepalived_healthcheckers[16476]: Opening file '/etc/keepalived/keepalived.conf'.
Feb 02 06:15:00 cfme-2.home.ajg.id.au Keepalived_vrrp[16477]: /usr/local/bin/keepalived_check_pgsql_primary.sh exited with status 1
Feb 02 06:15:02 cfme-2.home.ajg.id.au Keepalived_vrrp[16477]: /usr/local/bin/keepalived_check_pgsql_primary.sh exited with status 1
Feb 02 06:15:03 cfme-2.home.ajg.id.au Keepalived_vrrp[16477]: VRRP_Instance(VI_1) Now in FAULT state
Feb 02 06:15:04 cfme-2.home.ajg.id.au Keepalived_vrrp[16477]: /usr/local/bin/keepalived_check_pgsql_primary.sh exited with status 1
```
