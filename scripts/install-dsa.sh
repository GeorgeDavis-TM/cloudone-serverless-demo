#!/bin/bash
WSApiKey=$1
WSToken=$2
yum install -y git wget
git clone https://github.com/GeorgeDavis-TM/deepsecurity-deploy.git
cd deepsecurity-deploy
chmod +x agent_health_status.sh
./agent_health_status.sh ${WSApiKey} ${WSToken}