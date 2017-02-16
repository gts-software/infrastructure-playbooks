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
| `ansible_*` | Controls how ansible interacts with remote hosts | |
| `ansible_host` | The IP or DNS of the host to connect to  | `alpha.example.com` |
| `ansible_user` | The default ssh user name to use | `root` |
| `ansible_password` | The ssh password to use | `q9ShgTbqn...` |
| `base_*` | Fundamental settings | |
| `base_name_host` | Hostname to be applied | `alpha` |
| `base_name_domain` | Domainname to be applied | `base_name_domain` |
| `base_data_dir` | The base data directory for all containers | `base_data_dir` |
| `base_devops_email` | Email address of the DevOps team | `base_devops_email` |
| `` |  | `` | `` |
| `` |  | `` | `` |
| `` |  | `` | `` |
| `` |  | `` | `` |

## Manage a Cluster

TODO
