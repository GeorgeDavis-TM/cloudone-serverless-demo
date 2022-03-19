#!/bin/bash
wget https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh > /home/ec2-user/install-nvm.log 2>&1
mv install.sh nvm-install.sh
chmod +x nvm-install.sh
./nvm-install.sh | tail -n 2 >> /home/ec2-user/.bash_profile
./nvm-install.sh >> /home/ec2-user/install-nvm.log 2>&1
source /home/ec2-user/.bash_profile
nvm --version >> /home/ec2-user/install-nvm.log 2>&1
nvm install 14 >> /home/ec2-user/install-nvm.log 2>&1
nvm ls >> /home/ec2-user/install-nvm.log 2>&1
nvm use 14 >> /home/ec2-user/install-nvm.log 2>&1
nvm current >> /home/ec2-user/install-nvm.log 2>&1