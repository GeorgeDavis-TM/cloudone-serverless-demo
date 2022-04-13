import json
import logging
import time
import os
import urllib3
import boto3
import cfnresponse

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):   

    # Setup
    logger.info("event: {}".format(event))
    status = cfnresponse.SUCCESS
    responseData = {}
    responseData['Data'] = {} 

    try:        

        if event['RequestType'] == 'Create':
            
            utilsObj = Utils()
            groupsObj = Groups()

            createGroupResponse = groupsObj.createNewGroup()
            # print(str(createGroupResponse))

            utilsObj.setAwsSsmParameter("TREND_AP_KEY", createGroupResponse["apiCredsKey"])
            utilsObj.setAwsSsmParameter("TREND_AP_SECRET", createGroupResponse["apiCredsSecret"])

            time.sleep(5)

            groupsObj.setGroupEnablePolicy(createGroupResponse["groupId"])

            policyObj = Policies()

            currentIllegalFileAccessPolicyDict = policyObj.getIllegalFileAccessPolicy(createGroupResponse["groupId"])
            currentRCEPolicyDict = policyObj.getRCEPolicy(createGroupResponse["groupId"])

            policyObj.addIllegalFileAccessPolicy(createGroupResponse["groupId"], currentIllegalFileAccessPolicyDict)
            policyObj.addRCEPolicy(createGroupResponse["groupId"], currentRCEPolicyDict)

    except Exception as e:
        logger.info("Exception: {}".format(e))
        status = cfnresponse.FAILED
            
    cfnresponse.send(event, context, status, responseData, None)

class Groups:

    utilsObj = None

    def __init__(self):

        self.utilsObj = Utils()

    def createNewGroup(self):

        body = {
            "name": self.utilsObj.c1asSecurityGroupName
        }       

        r = self.utilsObj.httpObj.request('POST', self.utilsObj.baseUrl + '/accounts/groups', body=json.dumps(body))
        
        jsonResponse = json.loads(r.data)
        # print(str(jsonResponse))

        return {
            "groupId": jsonResponse["group_id"],
            "apiCredsKey": jsonResponse["credentials"]["key"],
            "apiCredsSecret": jsonResponse["credentials"]["secret"]
        }        

    def setGroupEnablePolicy(self, groupId):

        body = {
            'credential_stuffing': 'mitigate',
            'file_access': 'mitigate',
            'ip_protection': 'mitigate',
            'malicious_file_upload': 'mitigate',
            'malicious_payload': 'mitigate',
            'rce': 'mitigate',
            'redirect': 'mitigate',
            'sqli': 'mitigate'
        }

        r = self.utilsObj.httpObj.request('PUT', self.utilsObj.baseUrl + '/accounts/groups/' + str(groupId) + '/settings', body=json.dumps(body))

        return self.utilsObj.isHttpRequestSuccess(r.status)

class Policies:

    apiCredsKey = apiCredsSecret = None
    groupId = None

    utilsObj = None

    def __init__(self):

        self.utilsObj = Utils()

    def getIllegalFileAccessPolicy(self, groupId):       

        r = self.utilsObj.httpObj.request('GET', self.utilsObj.baseUrl + '/security/file_access/' + groupId + '/policy')        
                
        return json.loads(r.data)

    def addIllegalFileAccessPolicy(self, groupId, existingPolicyDict):

        newRuleDict = {     
            'action': 'allow',
            'glob': '/proc/meminfo'
        }

        existingPolicyDict["read_control"]["configuration"]["rules"].append(newRuleDict)

        print(str(existingPolicyDict))

        r = self.utilsObj.httpObj.request('PUT', self.utilsObj.baseUrl + '/security/file_access/' + groupId + '/policy', body=json.dumps(existingPolicyDict))
                
        return self.utilsObj.isHttpRequestSuccess(r.status)

    def getRCEPolicy(self, groupId):       

        r = self.utilsObj.httpObj.request('GET', self.utilsObj.baseUrl + '/security/rce/' + groupId + '/policy')
                
        return json.loads(r.data)

    def addRCEPolicy(self, groupId, existingPolicyDict):

        newRuleDict = {            
            'action': 'allow',
            'command': '^file.*'
        }

        existingPolicyDict["exec_control"]["configuration"]["rules"].append(newRuleDict)

        print(str(existingPolicyDict))

        r = self.utilsObj.httpObj.request('PUT', self.utilsObj.baseUrl + '/security/rce/' + groupId + '/policy', body=json.dumps(existingPolicyDict))
                
        return self.utilsObj.isHttpRequestSuccess(r.status)

class Utils:

    def __init__(self):

        self.awsDeployRegion = str(os.environ.get("awsDeployRegion"))

        self.ssmClient = boto3.client('ssm', region_name=self.awsDeployRegion)

        self.c1asSecurityGroupName = str(os.environ.get("c1asSecurityGroupName"))
        self.c1asApiAuthToken = str(os.environ.get("c1asApiAuthToken"))

        if "ssm:" in self.c1asApiAuthToken:
            ssmParamKey = self.c1asApiAuthToken.split('ssm:')[1]
            if self.getAwsSsmParameter(ssmParamKey):
                self.c1asApiAuthToken = self.getAwsSsmParameter(ssmParamKey)

        self.httpHeaders = {
            'Content-Type': 'application/json;charset=utf-8',
            'Authorization': 'ApiKey ' + self.c1asApiAuthToken,
            'api-version': 'v1'
        }

        self.httpObj = urllib3.PoolManager(headers=self.httpHeaders)
        self.c1TrendRegion = self.getApiKeyRegion(self.httpObj)
        self.baseUrl = self.c1asApiEndpointBaseUrl(self.c1TrendRegion)

    # Returns Cloud One region-based Accounts API Endpoint URL.
    def c1AccountsApiEndpointBaseUrl(self):

        return "https://accounts.cloudone.trendmicro.com/api"

    # Retrieve API Key ID from the raw API Key passed to this function.
    def parseApiKeyForKeyId(self):        

        return str(self.c1asApiAuthToken.split(':')[0])

    # Get Cloud One API Region endpoint.
    def getApiKeyRegion(self, http):    

        r = http.request('GET', self.c1AccountsApiEndpointBaseUrl() + '/apikeys/' + self.parseApiKeyForKeyId())

        return json.loads(r.data)["urn"].split(":")[3]

    # Returns Cloud One region-based Services API Endpoint URL.
    def c1asApiEndpointBaseUrl(self, c1TrendRegion):

        return "https://application." + str(c1TrendRegion) + ".cloudone.trendmicro.com"

    # Returns true when request status is success.
    def isHttpRequestSuccess(self, statusCode):

        if statusCode == 204:
            return True
        elif statusCode == 409:
            raise Exception("Error 409: Failure to validate rule(s).")
        elif statusCode == 422:
            raise Exception("Error 422: Unprocessable Entity.")
        return False

    # Retrieve SSM Parameter value based on parameter key passed.
    def getAwsSsmParameter(self, paramKey):
        
        print("Fetching SSM Parameter value from AWS...")  
        parameter = self.ssmClient.get_parameter(Name=paramKey, WithDecryption=True)

        return parameter ['Parameter']['Value']

    # Store SSM Parameter key and value on the AWS backend for future use.
    def setAwsSsmParameter(self, paramKey, paramValue):        
        
        parameter = self.ssmClient.put_parameter(Name=paramKey, Value=paramValue, Type='String', Overwrite=True)

        print(str(parameter))