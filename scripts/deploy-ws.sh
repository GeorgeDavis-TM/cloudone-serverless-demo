#!/bin/bash
dsApiKey=$1
localHostname=`curl http://169.254.169.254/latest/meta-data/local-hostname`
TAG_NAME="Name"
INSTANCE_ID=`curl http://instance-data/latest/meta-data/instance-id`
REGION=`curl http://instance-data/latest/meta-data/placement/availability-zone | sed -e 's:\([0-9][0-9]*\)[a-z]*\$:\\1:'`
TAG_VALUE="`aws ec2 describe-tags --filters "Name=resource-id,Values=$INSTANCE_ID" "Name=key,Values=$TAG_NAME" --region $REGION --output=text | cut -f5`"
instance=$TAG_VALUE"("$localHostname")"
cd /home/ec2-user
yum install -y python3 python3-pip git curl unzip wget jq
wget -P /home/ec2-user https://automation.deepsecurity.trendmicro.com/sdk/20_0/v1/dsm-py-sdk.zip
unzip /home/ec2-user/dsm-py-sdk.zip > /dev/null 2>&1
cd deepsecurity
pip3 install .
cd /home/ec2-user
git clone https://github.com/GeorgeDavis-TM/cloudOneWorkloadSecurityDemo.git
cd cloudOneWorkloadSecurityDemo
tmp=$(mktemp)
jq --arg a "$dsApiKey" '.apiSecretKey = $a' config.json > "$tmp" && mv "$tmp" config.json
jq --arg i "$instance" '.hostName = $i' config.json > "$tmp" && mv "$tmp" config.json
python3 cloud_one_workload_security_demo.py