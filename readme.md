# Infrastructure Playbooks

This project provides a set of Ansible playbooks for a Docker-centric world. Use them to set up single servers, entire clusters, and projects on top of it. It supports logging and backup out of the box.

Please have a look at the following sister projects too:
- [infrastructure-inventory-example](https://github.com/core-process/infrastructure-inventory-example)
- [linux-unattended-installation](https://github.com/core-process/linux-unattended-installation)
- [docker-backup](https://github.com/core-process/docker-backup)

## Setup

Install Ansible and a few helper tools first:

```sh
sudo apt-get install software-properties-common
sudo apt-add-repository ppa:ansible/ansible
sudo apt-get update
sudo apt-get install git curl unzip openssh-client sshpass ansible
```

Clone the latest playbooks:

```sh
mkdir workspace && cd workspace
git clone https://github.com/core-process/infrastructure-playbooks.git
```

## Manage the Inventory

Initialize your inventory:

```sh
mkdir infrastructure-inventory && cd infrastructure-inventory
../infrastructure-playbooks/inventory-init.sh
```

Adjust or remove the example hosts of the newly generated inventory. Setup new hosts either manually or by utilizing the [linux-unattended-installation](https://github.com/core-process/linux-unattended-installation) project.

Add hosts to the inventory with the help of the `inventory-add.sh` script:

```sh
# Usage: inventory-add.sh <host name> <host ip or dns> <current root password> [<new root password>|auto]
# - If you provide a new root password, we will change the password on the host automatically.
# - If you provide the keyword 'auto', we will generate a strong password automatically.
../infrastructure-playbooks/inventory-add.sh gamma gamma.example.com root-password auto
```

## Manage a Server

Run the `deploy-server.yml` playbook to setup Docker, logging and backup:

```sh
ansible-playbook ../infrastructure-playbooks/deploy-server.yml -e docker_pull=true

# The 'docker_pull' variable ensures a pull of the docker images. In case
# you do not want to update docker images to the newest version on every run,
# discard the variable and call:
ansible-playbook ../infrastructure-playbooks/deploy-server.yml
```

Configure the `deploy-server.yml` playbook with the following variables:

| Name | Description | Values |
| :--- | :--- |  :--- |
| **Ansible** | | |
| ansible_host | The IP or DNS of the host to connect to  | `alpha.example.com` |
| ansible_user | The default ssh user name to use | `root` |
| ansible_password | The ssh password to use | `q9ShgTbqn...` |
| **Base** | | |
| base_name_host | Hostname to be applied | `alpha` |
| base_name_domain | Domainname to be applied | `example.com` |
| base_data_dir | The base data directory for all containers | `/data` |
| base_devops_email | Email address of the DevOps team | `devops@example.com` |
| **Logging** | | |
| logging_token | Loggly customer token  | `a6b1ba3...` |
| **Backup** | | |
| backup_interval | A cron string describing the backup interval | `'0 3 * * *` |
| backup_full_every | Perform a full backup if the latest full backup is older than the given time (time format according to Duplicity) | `1M` |
| backup_remove_older_than | Delete all backups older than the given time (time format according to Duplicity) | `1Y` |
| backup_storage_url | Duplicity target url | `s3://s3-<region>.amazonaws.com/<bucket>/` |
| backup_storage_password | A password for accessing the storage | `2r93ur...` |
| backup_storage_key_id | Amazon AWS access key id | `7M1VGFL6...` |
| backup_storage_secret_key | Amazon AWS secret access key | `HvbMb9v8dW...` |

## Manage a Cluster

TODO
