#!/bin/bash
WSApiKey=$1
WSPolicyId=$2
yum install -y git wget curl jq > /home/ec2-user/install-dsa.log 2>&1
git clone https://github.com/GeorgeDavis-TM/deepsecurity-deploy.git >> /home/ec2-user/install-dsa.log 2>&1
cd deepsecurity-deploy
chmod +x agent_health_status.sh
./agent_health_status.sh ${WSApiKey} ${WSPolicyId} >> /home/ec2-user/install-dsa.log 2>&1