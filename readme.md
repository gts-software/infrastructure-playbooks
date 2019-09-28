# Infrastructure Playbooks

This project provides a set of Ansible playbooks for a Docker-centric world. Use them to set up single servers, entire clusters, and projects on top of it. It supports logging and backup out of the box.

Please have a look at the following projects too:
- [infrastructure-playbooks/templates/inventory](https://github.com/core-process/infrastructure-playbooks/tree/master/templates/inventory)
- [linux-unattended-installation](https://github.com/core-process/linux-unattended-installation)

## Setup

Install Ansible and a few helper tools first:

```sh
sudo apt-get install software-properties-common
sudo apt-add-repository ppa:ansible/ansible
sudo apt-get update
sudo apt-get install git curl unzip openssh-client sshpass ansible
```

Clone or pull the latest playbooks:

```sh
mkdir workspace && cd workspace
git clone https://github.com/core-process/infrastructure-playbooks.git
```

## Manage the Inventory

Initialize your Ansible inventory by using the following template: [infrastructure-playbooks/templates/inventory](https://github.com/core-process/infrastructure-playbooks/tree/master/templates/inventory)

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

| Name | Description | Example |
| :--- | :--- |  :--- |
| **Ansible** | | |
| ansible_host | The IP or DNS of the host to connect to  | `alpha.example.com` |
| ansible_user | The default ssh user name to use | `root` |
| **Base** | | |
| base_name_host | Hostname to be applied | `alpha` |
| base_name_domain | Domainname to be applied | `example.com` |
| base_devops_email | Email address of the DevOps team | `devops@example.com` |
| **Remote Access** | | |
| base_authorized_keys | Authorized user keys for root access | `- ssh-rsa AAAAB3N...` |
| backup_authorized_keys | Authorized keys for backup procedure access | `- ssh-rsa AAAAB3N...` |
| deployment_authorized_keys | Authorized keys for deployment access | `- ssh-rsa AAAAB3N...` |
| **Registry** | | |
| registry_username | Registry username  | `example+deployment` |
| registry_password | Registry password  | `nVKU7....5Qi4Y` |
| registry_fqdn | Registry FQDN  | `docker.pkg.github.com` |
| **Logging** | | |
| logging_token | Loggly customer token  | `a6b1ba3...` |
| **Backup** | | |
| backup_remote_full_if_older_than | Perform a full backup if the latest full backup is older than the given time | `1M` |
| backup_remote_remove_older_than | Delete all backups older than the given time on Amazon AWS | `1Y` |
| backup_local_remove_older_than | Delete all backups older than the given time on local disk | `3M` |
| backup_aws_s3_url | Duplicity target url | `s3://s3...amazonaws.com/...` |
| backup_aws_key_id | Amazon AWS access key id | `7M1VGFL6...` |
| backup_aws_key_secret | Amazon AWS access key secret | `HvbMb9v8dW...` |

Please have a look at the following projects for further information and instructions:
- [logspout-loggly](https://github.com/iamatypeofwalrus/logspout-loggly): This is a log router for Docker containers that runs inside Docker. It attaches to all containers on a host, then routes their logs to Loggly.

## Manage a Cluster

Coming soon...

## Manage a Project

Run the following command to build a project (builds on localhost):

```sh
ansible-playbook ../infrastructure-playbooks/build-project.yml \
  -e docker_push=true \
  -e project_source=`pwd` \
  -e project_mode=staging \
  -e project_branch=develop \
  -e project_version=1.0.1 \
  -e '@project.yml'

# For convenience we provided a wrapper script. Use the following for more:
../infrastructure-playbooks/build-project.sh -?
```

Run the following command to deploy a project (deploys to project target):

```sh
ansible-playbook ../infrastructure-playbooks/deploy-project.yml \
  -e docker_pull=true \
  -e project_mode=staging \
  -e project_branch=develop \
  -e project_version=1.0.1 \
  -e '@project.yml'

# For convenience we provided a wrapper script. Use the following for more:
../infrastructure-playbooks/deploy-project.sh -?
```

Define your project as follows:

```yml
# naming parts used for service and network names
project_group: example
project_name: simple

# images to be build and registered
project_images:
  app:
    dockerfile: Dockerfile
    repository: docker.pkg.github.com/some/example

# domains used to serve the application
project_domains:
  staging:
    develop: example-staging-develop.local
    master: example-staging-master.local
  production: example.local

# hosts used to serve the application
project_target:
  staging:
    develop: example-staging-server.local
    master: example-staging-server.local
  production: example-production-server.local

# service composition (will be connected through their own network)
project_services:
  web:
    image: 'project:app'
    depends_on:
      - db
    active: true
  db:
    image: 'mongo:latest'
    volumes:
      - source: 'service:/db'
        destination: '/data/db'
    active: true

# services to be exposed via reverse proxy
project_expose:
  web:
    - type: http
      port: 3000
      domains:
        - '@'
        - www
```
