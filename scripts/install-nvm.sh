#!/bin/bash
wget https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh
mv install.sh nvm-install.sh
chmod +x nvm-install.sh
./nvm-install.sh | tail -n 2 >> /home/ec2-user/.bash_profile
./nvm-install.sh
source /home/ec2-user/.bash_profile
nvm --version
nvm install 14
nvm ls
nvm use 14
nvm current