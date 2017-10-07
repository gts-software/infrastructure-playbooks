FROM alpine:3.6

RUN apk --no-cache add openssl openssh-client bash git python py-pip ansible docker \
 && pip install toposort docker-py

RUN mkdir /infrastructure-playbooks \
 && mkdir /infrastructure-playbooks/circleci \
 && mkdir /infrastructure-playbooks/filter_plugins \
 && mkdir /infrastructure-playbooks/roles

COPY ./circleci/setup-environment.sh /infrastructure-playbooks/circleci/setup-environment.sh
COPY ./filter_plugins/project.py     /infrastructure-playbooks/filter_plugins/project.py
COPY ./roles/project-build/          /infrastructure-playbooks/roles/project-build/
COPY ./roles/project-deploy/         /infrastructure-playbooks/roles/project-deploy/
COPY ./roles/project-facts/          /infrastructure-playbooks/roles/project-facts/
COPY ./roles/prune-docker/           /infrastructure-playbooks/roles/prune-docker/
COPY ./build-project.sh              /infrastructure-playbooks/build-project.sh
COPY ./build-project.yml             /infrastructure-playbooks/build-project.yml
COPY ./deploy-project.sh             /infrastructure-playbooks/deploy-project.sh
COPY ./deploy-project.yml            /infrastructure-playbooks/deploy-project.yml

CMD [ "/bin/bash" ]
