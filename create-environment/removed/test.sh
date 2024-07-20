cd ..
source set-env-rosa.sh
RC=0
READY=0
MAX=60
COUNTER=0

while [ "$RC" -ne  $READY ]
do

echo "Sleep 10 seconds to check if API server is ready"
sleep 10;
RC=`oc login -u admin -p " $TF_VAR_admin_password " "$(terraform output -raw cluster_api_url) | grep "Unauthorized"  | wc-l`

let COUNTER++

if [ "$MAX" -lt $COUNTER ]; then
echo "===== Time out ====="
break
fi
done
echo "oc login -u admin -p " $TF_VAR_admin_password " "$(terraform output -raw cluster_api_url)
oc login -u admin -p $TF_VAR_admin_password $(terraform output -raw cluster_api_url)
cd - 
