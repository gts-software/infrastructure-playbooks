# Infrastructure Playbooks

This project provides a set of Ansible playbooks for a Docker-centric world. Use them to setup single servers, full cluster and projects on top of it. It supports logging and backup out of the box.

Please have a look at the following sister projects too:
- [infrastructure-inventory-example](https://github.com/core-process/infrastructure-inventory-example)
- [linux-unattended-installation](https://github.com/core-process/linux-unattended-installation)
- [docker-backup](https://github.com/core-process/docker-backup)

## Manage the Inventory

```sh
# prepare:
# - install ansible and helper tools required for the infrastructure scripts
# - see http://docs.ansible.com/ansible/intro_installation.html
sudo apt-get install software-properties-common
sudo apt-add-repository ppa:ansible/ansible
sudo apt-get update
sudo apt-get install git curl unzip openssh-client sshpass ansible

# clone the latest infrastructure playbooks:
mkdir workspace && cd workspace
git clone https://github.com/core-process/infrastructure-playbooks.git

# initialize your inventory:
mkdir infrastructure-inventory && cd infrastructure-inventory
../infrastructure-playbooks/inventory-init.sh

# now it is your turn:
# - setup new target machines if required
# - adjust and/or remove example hosts of the newly generated inventory

# nice to know:
# - you can use the 'linux-unattended-installation' project to setup new
#   hosts easily (see link above)
# - you can use the '../infrastructure-playbooks/inventory-add.sh' script
#   to add new hosts to the inventory easily

# once you are done, just call:
ansible-playbook ../infrastructure-playbooks/deploy.yml -e docker_pull=true

# nice to know:
# - the 'docker_pull' variable ensures a pull of the docker images
# - in case you do not want to update docker images to the newest
#   version, discard the variable and call:
ansible-playbook ../infrastructure-playbooks/deploy.yml
```

## Manage a Server

TODO

## Manage a Cluster

TODO
