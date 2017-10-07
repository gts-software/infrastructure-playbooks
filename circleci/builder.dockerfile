FROM alpine:3.6

RUN apk --no-cache add openssl openssh-client bash git python py-pip ansible docker \
 && pip install toposort docker-py

RUN mkdir /infrastructure-playbooks \
 && mkdir /infrastructure-playbooks/circleci \
 && mkdir /infrastructure-playbooks/filter_plugins

COPY ./circleci/setup-environment.sh /infrastructure-playbooks/circleci/setup-environment.sh
COPY ./filter_plugins/project.py     /infrastructure-playbooks/filter_plugins/project.py
COPY ./roles/                        /infrastructure-playbooks/roles/
COPY ./*.sh                          /infrastructure-playbooks/
COPY ./*.yml                         /infrastructure-playbooks/

CMD [ "/bin/bash" ]
