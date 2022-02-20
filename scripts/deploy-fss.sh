#!/bin/bash
cd /home/ec2-user
yum install -y git wget > ~/deploy-ws.log 2>&1
git clone https://github.com/GeorgeDavis-TM/filestoragesecurity-malwaretest.git
cd filestoragesecurity-malwaretest
source /home/ec2-user/.bash_profile
nvm ls
nvm use 14
nvm current
npm install -g serverless
sls --version
VERSION=v4.20.2
BINARY=yq_linux_amd64
wget https://github.com/mikefarah/yq/releases/download/${VERSION}/${BINARY}.tar.gz -O - | tar xz && mv ${BINARY} /usr/bin/yq
yq -i '.custom.stages.prod.profile = "default"' serverless.yml
sls deploy -s prod