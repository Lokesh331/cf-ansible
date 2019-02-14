# cloudforms-ansible

## Purpose

This repository houses a number of playbooks and, eventually, roles that are useful for administrating, deploying and configuration
a CloudForms/ManageIQ appliance or region.

## Pull requests

Pull requests are always welcome and very much encouraged. Please fork and submit requests as you wish!

## Minimum versions

Most playbooks in this repository have been tested against the following Ansible versions:

* 2.4.6
* 2.5.11
* 2.6.7
* 2.7.0

## Usage Instructions

### Inventory

The playbooks depend on a fairly simple inventory file, with the following groups:

* `vmdb`: all database appliances, including the below two groups:
  * `primary_db`: all primary database appliances
  * `standby_db`: all standby database appliances
* `non-vmdb`: all other appliances that join the region in the primary db.

### Required variables

Please review the group_vars directory for a list of the various variables that are 
expected. Each of the parameters is documented. Playbooks should be documented at the top of their files.

