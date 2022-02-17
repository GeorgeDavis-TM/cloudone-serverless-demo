#!/bin/bash
wget https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh
mv install.sh nvm-install.sh
chmod +x nvm-install.sh
./nvm-install.sh
whoami
pwd
cat ~/.bashrc
source ~/.bashrc
source ~/.bashrc && nvm --version
source ~/.bashrc && nvm install 14
source ~/.bashrc && nvm ls
source ~/.bashrc && nvm use 14
source ~/.bashrc && nvm current