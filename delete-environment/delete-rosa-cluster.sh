#!/bin/bash

cd ..
source ./set-env-rosa.sh
source ./set-env-fsx-ontap.sh
cd - 

echo "CLUSTER="$CLUSTER
echo "FSX_REGION="$FSX_REGION

STACK_EXIST=$(aws cloudformation list-stacks --stack-status-filter CREATE_COMPLETE | grep "${CLUSTER}-FSXONTAP" )

if [ "$STACK_EXIST" != "" ]; then
  echo "===== Delete FSx volumes first before deleting ROSA cluster ====="
  exit 0
else
  echo "===== FSx seems to be deleted. Ready for deleting ROSA cluster ====="
fi

# need to move to the upper directory to execute terraform
cd ..
echo "===== Delete base ROSA cluster using terraform ====="
echo "===== Start time " `date` " ====="
terraform destroy -auto-approve
echo "===== End time " `date` " ====="
cd - 
