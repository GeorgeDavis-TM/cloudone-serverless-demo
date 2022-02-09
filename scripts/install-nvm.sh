#!/bin/bash
wget https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh
mv install.sh nvm-install.sh
chmod +x nvm-install.sh
./nvm-install.sh
whoami
pwd
cat ~/.bashrc
source ~/.bashrc
nvm --version
nvm install 14
nvm ls
nvm use 14
nvm current