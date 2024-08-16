# need to move to the upper directory to see terraform files
cd ..
source ./set-env-rosa.sh 2>&1 > /dev/null
oc login -u admin -p $TF_VAR_admin_password $(terraform output -raw cluster_api_url) 
