FROM runatlantis/atlantis:latest

#Remove link to terraform added by base image
RUN rm /usr/local/bin/terraform

#Install go
COPY --from=golang:1.16-alpine /usr/local/go/ /usr/local/go/
RUN ln -s /usr/local/go/bin/* /usr/local/bin

#Switch to atlantis user and homedir
USER atlantis
WORKDIR /home/atlantis
#Install terragrunt-config-generator
RUN cd && GO111MODULE=on go get github.com/transcend-io/terragrunt-atlantis-config@v1.7.0 && cd -
ENV PATH="/home/atlantis/go/bin:${PATH}"

#Install tfenv and tgenv, and link in /usr/local/bin
RUN git clone --depth 1 --branch v2.2.2 https://github.com/tfutils/tfenv.git .tfenv
RUN git clone --depth 1 --branch v0.0.3 https://github.com/cunymatthieu/tgenv.git .tgenv
ENV PATH="/home/atlantis/.tfenv/bin:${PATH}"
ENV PATH="/home/atlantis/.tgenv/bin:${PATH}"
RUN tfenv install latest:^1.* && tfenv use latest:^1.*
RUN tgenv install latest:^0.30.*

#Add Github keys
RUN mkdir -p -m 0700 ~/.ssh && ssh-keyscan github.com >> ~/.ssh/known_hosts

#Add script for retrieving github credentials and update config
COPY --chown=atlantis:atlantis ./credentials.sh credentials.sh
RUN chmod +x /home/atlantis/credentials.sh && git config --global credential.helper "/home/atlantis/credentials.sh"
RUN git config --global url.https://.insteadOf ssh://git@

COPY --chown=atlantis:atlantis ./server-atlantis.yaml /home/atlantis/server-atlantis.yaml
