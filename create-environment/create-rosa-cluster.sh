#! /bin/bash
cd ..
echo "===== create base ROSA cluster using terraform ====="
echo -e  "\e[32m===== Start time " `date` " =====\e[0m"
terraform init
source set-env-rosa.sh
terraform plan -out rosa.plan
terraform apply rosa.plan

if [ $? -ne  0 ]; then
	echo "===== terraform error ====="
	echo "Exit due to  terraform error"
	echo "Check if you already..."
        echo " 1. Eenabled  HCP on AWS console "
        echo " 2. Link the AWS account to Red Hat account" 
	echo " 3. rosa login --token=......"
	exit 1
fi

echo "====== wait until login is available  =====" 
RC=1
ERROR=1
MAX=60
COUNTER=0

while [ "$RC" ==  $ERROR ]
do

  echo "Sleep for 10 seconds before checking\"oc login\" again"
  sleep 10;
  RC=`oc login -u admin -p $TF_VAR_admin_password $(terraform output -raw cluster_api_url) | grep "Unauthorized"  | wc -l`


  let COUNTER++

  if [ "$MAX" -lt $COUNTER ]; then
    echo "===== Time out ====="
    break
  fi
done

# test loggin 
oc login -u admin -p $TF_VAR_admin_password $(terraform output -raw cluster_api_url)

echo -e "\e[32m====== you can login ROSA with the follwoing comman =====\e[0m" 
echo "oc login -u admin -p " $TF_VAR_admin_password " "$(terraform output -raw cluster_api_url)
echo -e "\e[32m===== End time " `date` " =====\e[0m"

echo -e "\e[32m===== resizing workers-2 machinepool to zero to reduce cost =====\e[0m"
rosa edit machinepool workers-2 -c $TF_VAR_cluster_name --replicas=0



# return to the original directory
cd -

