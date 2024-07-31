FROM ubuntu:22.04

ARG RUNNER_VERSION="2.317.0"
ARG DOCKER_GROUP_ID

# Prevents installdependencies.sh from prompting the user and blocking the image creation
ARG DEBIAN_FRONTEND=noninteractive

RUN apt update -y && apt upgrade -y && useradd -m docker
RUN apt install -y --no-install-recommends \
    curl jq build-essential libssl-dev libffi-dev python3 python3-venv python3-dev python3-pip git openssh-client unzip wget git-lfs

RUN chmod 1777 /tmp

ARG YQ_VERSION=4.43.1
ARG YQ_BINARY=yq_linux_amd64
RUN wget -q https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}/${YQ_BINARY} -O /usr/bin/yq && \
    chmod +x /usr/bin/yq

RUN git-lfs install


RUN cd /home/docker && mkdir actions-runner && cd actions-runner \
    && curl -O -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

RUN chown -R docker ~docker && /home/docker/actions-runner/bin/installdependencies.sh
RUN curl -fsSL https://get.docker.com | sh
RUN mkdir -p /home/docker/.ssh
COPY --chmod=700 id_rsa_shared /home/docker/.ssh/id_rsa
RUN chown -R docker:docker /home/docker/.ssh
RUN echo "Host github.com\n\tStrictHostKeyChecking no\n" >> /home/docker/.ssh/config
COPY start.sh start.sh

# make the script executable
RUN chmod +x start.sh
RUN groupmod -g $DOCKER_GROUP_ID docker


# since the config and run script for actions are not allowed to be run by root,
# set the user to "docker" so all subsequent commands are run as the docker user
USER docker

ENTRYPOINT ["./start.sh"]
