echo "===== Set environmetal variables ====="
echo "===== Start time " `date` " ====="
cd ..
source set-env-fsx-ontap.sh
source set-env-fsx-password.sh
cd -

echo "create FSx for ONTAP using cloudformation"
aws cloudformation create-stack \
  --stack-name "${CLUSTER}-FSXONTAP" \
  --template-body file://./rosa-fsx-netapp-ontap/fsx/FSxONTAP.yaml \
  --region "${FSX_REGION}" \
  --parameters \
  ParameterKey=Subnet1ID,ParameterValue=${FSX_SUBNET1} \
  ParameterKey=Subnet2ID,ParameterValue=${FSX_SUBNET2} \
  ParameterKey=myVpc,ParameterValue=${FSX_VPC} \
  ParameterKey=FSxONTAPRouteTable,ParameterValue=\"$FSX_ROUTE_TABLES\" \
  ParameterKey=FileSystemName,ParameterValue=ROSA-myFSxONTAP \
  ParameterKey=ThroughputCapacity,ParameterValue=512 \
  ParameterKey=FSxAllowedCIDR,ParameterValue=${FSX_VPC_CIDR} \
  ParameterKey=FsxAdminPassword,ParameterValue=\"${FSX_ADMIN_PASS}\" \
  ParameterKey=SvmAdminPassword,ParameterValue=\"${SVM_ADMIN_PASS}\" \
  --capabilities CAPABILITY_NAMED_IAM | tee 

echo "Wait cloud Formation completion. This would take about 30 mins"
aws cloudformation wait stack-create-complete --stack-name "${CLUSTER}-FSXONTAP" --region "${FSX_REGION}"
echo "===== CloudFormation Complete  " `date` " ====="

echo "===== Create secret for trident  ====="
oc create namespace trident
oc create secret generic backend-fsx-ontap-nas-secret \
  --namespace trident \
  --from-literal=username=vsadmin \
  --from-literal=password="${SVM_ADMIN_PASS}"



