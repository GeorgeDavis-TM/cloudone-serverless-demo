import json
import os
import time
import boto3

def lambda_handler(event, context):
    
    regionName = str(os.environ.get("REGION_NAME")) if 'REGION_NAME' in os.environ else None
    sleepTimer = int(os.environ.get("SLEEP_TIMER")) if 'SLEEP_TIMER' in os.environ else 5
    pluginName = str(os.environ.get("PLUGIN_NAME")) if 'PLUGIN_NAME' in os.environ else None

    if regionName:
        
        commandId = event["Command"]["CommandId"]
        targetTags = event["Command"]["Targets"]
        
        filterTags = []
        for tagItem in targetTags:
            filterTags.append({"Name": tagItem["Key"], "Values": tagItem["Values"]})
        
        ec2Client = boto3.client('ec2', region_name=regionName)
        
        ec2DescribeInstancesResponse = ec2Client.describe_instances(
            Filters=filterTags,
            MaxResults=5
        )
        
        # print(str(ec2DescribeInstancesResponse))
        
        ec2Instances = ec2DescribeInstancesResponse["Reservations"][0]["Instances"]
        
        instanceId = None
        
        if len(ec2Instances) == 1:
            instanceId = ec2Instances[0]["InstanceId"]
        else:
            raise Exception("Multiple instances found. Reduce the number of stack(s) deployed and try again.")
    
        ssmClient = boto3.client('ssm', region_name=regionName)

        time.sleep(sleepTimer)
        
        waiter = ssmClient.get_waiter('command_executed')
        
        # print(str(commandId), str(instanceId))

        waiter.wait(
            CommandId=commandId,
            InstanceId=instanceId,
            WaiterConfig={
                'Delay': 5,
                'MaxAttempts': 60
            }
        )    

        getCommandInvocationResponse = ssmClient.get_command_invocation(
            CommandId=commandId,
            InstanceId=instanceId,
            PluginName=pluginName
        )
        
        print(str(getCommandInvocationResponse))

        if getCommandInvocationResponse["Status"] == "Success":
            print("Success: " + getCommandInvocationResponse["StandardOutputContent"] + " - " + getCommandInvocationResponse["StandardOutputUrl"])
            return True
        else:
            raise Exception("Error: " + getCommandInvocationResponse["StandardErrorContent"] + " - " + getCommandInvocationResponse["StandardErrorUrl"])
            return False
