#!/bin/bash
wget https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh
mv install.sh nvm-install.sh
chmod +x nvm-install.sh
touch ~/.bash_profile
./nvm-install.sh
cat ~/.bash_profile
cat ~/.bashrc
source ~/.bashrc
nvm --version
nvm install 14
nvm ls
nvm use 14
nvm current