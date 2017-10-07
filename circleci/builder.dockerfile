FROM alpine:3.6

RUN apk --no-cache add openssl openssh-client bash git python py-pip ansible docker \
 && pip install toposort docker-py \
 && wget -qO- https://github.com/core-process/infrastructure-playbooks/archive/master.tar.gz | tar xvz \
 && rm -r /infrastructure-playbooks-master/circleci

CMD [ "/bin/bash" ]
