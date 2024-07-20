cd ..
echo "===== create base ROSA cluster using terraform ====="
echo "===== Start time " `date` " ====="
terraform init
source set-env-rosa.sh
terraform plan -out rosa.plan
terraform apply rosa.plan
echo "====== wait until login is available  =====" 
RC=0
ERROR=1
MAX=60
COUNTER=0

while [ "$RC" -eq  $ERROR ]
do

echo "Sleep 10 seconds to check \"oc get pods -n openshift-cnv\""
sleep 10;
RC=`oc login -u admin -p " $TF_VAR_admin_password " "$(terraform output -raw cluster_api_url) | grep "Unauthorized"  | wc-l`

let COUNTER++

if [ "$MAX" -lt $COUNTER ]; then
echo "===== Time out ====="
break
fi
done

# test loggin 
oc login -u admin -p $TF_VAR_admin_password $(terraform output -raw cluster_api_url)

echo "====== you can login ROSA with the follwoing comman =====" 
echo "oc login -u admin -p " $TF_VAR_admin_password " "$(terraform output -raw cluster_api_url)
echo "===== End time " `date` " ====="

echo "===== resize workers-2 machinepool to zero to reduce cost ====="
rosa edit machinepool workers-2 -c $TF_VAR_cluster_name --replicas=0



# return to the original directory
cd -

