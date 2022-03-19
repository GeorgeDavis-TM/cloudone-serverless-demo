#!/bin/bash
cd /home/ec2-user
yum install -y git wget > /home/ec2-user/deploy-fss.log 2>&1
VERSION=v4.20.2
BINARY=yq_linux_amd64
wget -P /home/ec2-user -O ${BINARY}.tar.gz https://github.com/mikefarah/yq/releases/download/${VERSION}/${BINARY}.tar.gz >> /home/ec2-user/deploy-fss.log 2>&1
tar xvf /home/ec2-user/${BINARY}.tar.gz >> /home/ec2-user/deploy-fss.log 2>&1
mv /home/ec2-user/${BINARY} /usr/bin/yq >> /home/ec2-user/deploy-fss.log 2>&1
git clone https://github.com/GeorgeDavis-TM/filestoragesecurity-malwaretest.git >> /home/ec2-user/deploy-fss.log 2>&1
cd filestoragesecurity-malwaretest
yq -i '.custom.stages.prod.profile = "default"' serverless.yml
source /home/ec2-user/.bash_profile
nvm use 14 >> /home/ec2-user/deploy-fss.log 2>&1
npm install -g serverless >> /home/ec2-user/deploy-fss.log 2>&1
serverless --version >> /home/ec2-user/deploy-fss.log 2>&1
npm install
serverless plugin install -n serverless-python-requirements >> /home/ec2-user/deploy-fss.log 2>&1
# serverless deploy -s prod >> /home/ec2-user/deploy-fss.log 2>&1