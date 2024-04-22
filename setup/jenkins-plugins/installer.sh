#!/bin/bash

set -eo pipefail

JENKINS_URL='http://localhost:8080'

JENKINS_CRUMB=$(curl -s --cookie-jar /tmp/cookies -u admin:admin ${JENKINS_URL}/crumbIssuer/api/json | jq .crumb -r)

JENKINS_TOKEN=$(curl -s -X POST -H "Jenkins-Crumb:${JENKINS_CRUMB}" --cookie /tmp/cookies "${JENKINS_URL}/me/descriptorByName/jenkins.security.ApiTokenProperty/generateNewToken?newTokenName=demo-token66" -u admin:admin | jq .data.tokenValue -r)

echo $JENKINS_URL
echo $JENKINS_CRUMB
echo $JENKINS_TOKEN

while read plugin; do
   echo "........Installing ${plugin} .."
   curl -s POST --data "<jenkins><install plugin='${plugin}' /></jenkins>" -H 'Content-Type: text/xml' "$JENKINS_URL/pluginManager/installNecessaryPlugins" --user "admin:$JENKINS_TOKEN"
done < plugins.txt


#### we also need to do a restart for some plugins

#### check all plugins installed in jenkins
# 
# http://<jenkins-url>/script

# Jenkins.instance.pluginManager.plugins.each{
#   plugin -> 
#     println ("${plugin.getDisplayName()} (${plugin.getShortName()}): ${plugin.getVersion()}")
# }


#### Check for updates/errors - http://<jenkins-url>/updateCenter
