#!/bin/sh

export NS=trident
oc get namespace $NS -o json > $NS-ns.json
API_SERVER=$(terraform output -raw cluster_api_url) 
# API_SERVER=https://api.yuhki-hcp.29t2.p3.openshiftapps.com:443

curl -k -H "Content-Type: application/json" -H "Authorization: Bearer $(oc whoami -t)" -X PUT --data-binary @$NS-ns.json  $API_SERVER/api/v1/namespaces/$NS/finalize

oc delete clusterrole trident-controller 
oc delete clusterrole trident-operator
oc delete clusterrolebinding trident-controller
oc delete clusterrolebinding trident-operator

