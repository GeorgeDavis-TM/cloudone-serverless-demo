#!/bin/bash
dsApiKey=$1
cd /home/ec2-user
yum install -y python3 python3-pip git curl unzip wget jq > /home/ec2-user/deploy-c1ws.log 2>&1
wget -P /home/ec2-user -O c1ws-py-sdk.zip https://cloudone.trendmicro.com/docs/downloads/sdk/ws/v1/c1ws-py-sdk.zip >> /home/ec2-user/deploy-c1ws.log 2>&1
unzip -o /home/ec2-user/c1ws-py-sdk.zip >> /home/ec2-user/deploy-c1ws.log 2>&1
pip3 install . >> /home/ec2-user/deploy-c1ws.log 2>&1
git clone https://github.com/GeorgeDavis-TM/cloudOneWorkloadSecurityDemo.git >> /home/ec2-user/deploy-c1ws.log 2>&1
cd cloudOneWorkloadSecurityDemo
pip3 install -r requirements.txt >> /home/ec2-user/deploy-c1ws.log 2>&1
localHostname=`curl http://169.254.169.254/latest/meta-data/local-hostname` >> /home/ec2-user/deploy-c1ws.log 2>&1
# TAG_NAME="Name"
# INSTANCE_ID=`curl http://instance-data/latest/meta-data/instance-id` >> /home/ec2-user/deploy-c1ws.log 2>&1
# REGION=`curl http://instance-data/latest/meta-data/placement/availability-zone | sed -e 's:\([0-9][0-9]*\)[a-z]*\$:\\1:'` >> /home/ec2-user/deploy-c1ws.log 2>&1
# TAG_VALUE="`aws ec2 describe-tags --filters "Name=resource-id,Values=$INSTANCE_ID" "Name=key,Values=$TAG_NAME" --region $REGION --output=text | cut -f5`" >> /home/ec2-user/deploy-c1ws.log 2>&1
instance="("$localHostname")"
dsmPolicyName="Serverless"
tmp=$(mktemp)
jq --arg a "$dsApiKey" '.apiSecretKey = $a' config.json > "$tmp" && mv "$tmp" config.json
jq --arg i "$instance" '.hostName = $i' config.json > "$tmp" && mv "$tmp" config.json
jq --arg i "$dsmPolicyName" '.policyName = $i' config.json > "$tmp" && mv "$tmp" config.json
# cat config.json
python3 cloud_one_workload_security_demo.py