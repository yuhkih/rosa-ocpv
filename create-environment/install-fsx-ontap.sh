#! /bin/bash
echo "===== Start time " `date` " =====" 

echo "===== Start: Setting environmet variables ====="  
# need to move to the upper directory  to see terraform files
cd ..
source set-env-rosa.sh
source set-env-fsx-ontap.sh  
source set-env-fsx-password.sh  
cd - 
echo "===== End: Setting environmet variables ====="  

echo -e "\e[32m ===================================================== \e[m" 
echo -e "\e[32m ===== create FSx for ONTAP using cloudformation ===== \e[m" 
echo -e "\e[32m ===================================================== \e[m" 

if [ $SVM_ADMIN_PASS == "" ] || [ $FSX_ADMIN_PASS == "" ] ; then
  echo "===== something is worng with the parameters. exit ====="
  exit 1
fi

# Don't catch error here.
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
  --capabilities CAPABILITY_NAMED_IAM 

echo "Wait cloud Formation completion. This would take about 30 mins" 
# Usually it contains "failure" in stderr when failed. (or return code 255) 
RESULT=`aws cloudformation wait stack-create-complete --stack-name "${CLUSTER}-FSXONTAP" --region "${FSX_REGION}" `

if [[ $RESULT != "" ]] ; then
  echo -e "\e[31m aws cloudformation wait stack-create-complete --stack-name "$CLUSTER"-FSXONTAP --region "$FSX_REGION ": RESULT=" $RESULT  " \e[m"
  echo -e "\e[31m Check the CloudFromation status from AWS Console \e[m" 
  echo "===== CloudFormation Complete  " `date` " =====" 
  exit 1 
fi 

echo "===== CloudFormation Complete  " `date` " =====" 

# Need to login before issuing oc commands
echo "===== login to OCP ====="
cd ..
source set-env-rosa.sh
oc login -u admin -p $TF_VAR_admin_password $(terraform output -raw cluster_api_url)
cd - 

echo -e "\e[32m ============================== \e[m" 
echo -e "\e[32m ===== Install CSI driver ===== \e[m" 
echo -e "\e[32m ============================== \e[m" 

echo "===== Prepare additionhal necessary environment variables ====="
FSX_ID=$(aws cloudformation describe-stacks \
  --stack-name "${CLUSTER}-FSXONTAP" \
  --region "${FSX_REGION}" --query \
  'Stacks[0].Outputs[?OutputKey==`FSxFileSystemID`].OutputValue' \
  --output text)
FSX_MGMT=$(aws fsx describe-storage-virtual-machines \
  --region "${FSX_REGION}" --output text \
  --query "StorageVirtualMachines[?FileSystemId=='$FSX_ID'].Endpoints.Management.DNSName")

FSX_NFS=$(aws fsx describe-storage-virtual-machines \
  --region "${FSX_REGION}" --output text \
  --query "StorageVirtualMachines[?FileSystemId=='$FSX_ID'].Endpoints.Nfs.DNSName")

echo "FSX_ID="$FSX_ID 
echo "FSX_MGMT="$FSX_MGMT 
echo "FSX_NFS="$FSX_NFS 

if [ $FSX_ID == "" ] || [ $FSX_MGMT == "" ] || [ $FSX_NFS == "" ] ; then
  echo -e  "\e[31m ===== something is worng with the parameters. exit ===== \e[m"
  exit 1
fi 


echo "===== install trident helm chart =====" 
helm repo add netapp-trident https://netapp.github.io/trident-helm-chart 
helm repo update 
# VERSION=`helm search repo | grep "netapp-trident/trident-operator" | awk '{print $2}'` 
# echo "VERSION="$VERSION
helm install trident netapp-trident/trident-operator \
  --create-namespace --namespace trident 

# Wait until all pods get ready.
RUNNING=0
READY=4
MAX_RETRY=35
COUNTER=0

while [ "$RUNNING" -lt $READY ]
do

echo "Sleep 10 seconds to check \"oc get pods -n trident\""
sleep 10;
RUNNING=`oc get pods -n trident | grep "Running" | wc -l`

let COUNTER++

if [ "$MAX_RETRY" -lt $COUNTER ]; then
echo "===== Time out ====="
break
fi
done

echo "===== Create secret for trident  =====" 
oc create secret generic backend-fsx-ontap-nas-secret \
  --namespace trident \
  --from-literal=username=vsadmin \
  --from-literal=password="${SVM_ADMIN_PASS}"

echo "===== Create TridentBackendConfig ====="  
cat << EOF | oc apply -f -
apiVersion: trident.netapp.io/v1
kind: TridentBackendConfig
metadata:
  name: backend-fsx-ontap-nas
  namespace: trident
spec:
  version: 1
  backendName: fsx-ontap
  storageDriverName: ontap-nas
  managementLIF: $FSX_MGMT
  dataLIF: $FSX_NFS
  svm: SVM1
  credentials:
    name: backend-fsx-ontap-nas-secret
EOF

echo "===== Create StorageClass ====="
cat << EOF | oc apply -f -
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: trident-csi
provisioner: csi.trident.netapp.io
parameters:
  backendType: "ontap-nas"
  fsType: "ext4"
allowVolumeExpansion: True
reclaimPolicy: Retain
EOF


