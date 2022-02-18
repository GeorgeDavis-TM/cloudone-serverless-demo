#!/bin/bash
cd /home/ec2-user
git clone https://github.com/GeorgeDavis-TM/filestoragesecurity-malwaretest.git
cd filestoragesecurity-malwaretest
source /home/ec2-user/.bash_profile
sls deploy