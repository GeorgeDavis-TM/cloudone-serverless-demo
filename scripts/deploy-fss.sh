#!/bin/bash
cd /home/ec2-user
yum install -y git wget > ~/deploy-fss.log 2>&1
git clone https://github.com/GeorgeDavis-TM/filestoragesecurity-malwaretest.git >> ~/deploy-fss.log 2>&1
cd filestoragesecurity-malwaretest
source /home/ec2-user/.bash_profile
nvm use 14 >> ~/deploy-fss.log 2>&1
npm install -g serverless >> ~/deploy-fss.log 2>&1
serverless --version >> ~/deploy-fss.log 2>&1
serverless plugin install -n serverless-python-requirements >> ~/deploy-fss.log 2>&1
VERSION=v4.20.2
BINARY=yq_linux_amd64
wget https://github.com/mikefarah/yq/releases/download/${VERSION}/${BINARY}.tar.gz -O - | tar xz && mv ${BINARY} /usr/bin/yq >> ~/deploy-fss.log 2>&1
which yq
yq -i '.custom.stages.prod.profile = "default"' serverless.yml
cat serverless.yml
serverless deploy -s prod >> ~/deploy-fss.log 2>&1