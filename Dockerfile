FROM ubuntu:24.04
ARG RUNNER_VERSION="2.311.0"

RUN apt-get update && apt-get install -y \
    curl sudo git jq build-essential libssl-dev libffi-dev python3 && \
    apt-get clean
RUN useradd -m docker
RUN usermod -aG sudo docker
RUN echo "%sudo ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

WORKDIR /home/docker
RUN mkdir actions-runner && cd actions-runner \
    && curl -o actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

COPY --chown=docker:docker entrypoint.sh /home/docker/entrypoint.sh
RUN chmod +x /home/docker/entrypoint.sh

USER docker
ENTRYPOINT ["./entrypoint.sh"]