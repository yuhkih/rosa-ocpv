echo "===== Set environmetal variables ====="  
echo "===== Start time " `date` " =====" 

# need to move to the upper directory  to see terraform files
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
  --capabilities CAPABILITY_NAMED_IAM 

echo "Wait cloud Formation completion. This would take about 30 mins" 
RESULT=`aws cloudformation wait stack-create-complete --stack-name "${CLUSTER}-FSXONTAP" --region "${FSX_REGION}" | grep "failure" | wc -l `
echo "===== CloudFormation Complete  " `date` " =====" 

if [ $RESULT != "0" ]; then
 echo "==== CloudFormation failed ====="
 break
fi

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


# it's not good idea to use fixed version. need to fix later
echo "===== install trident helm chart =====" 
helm repo add netapp-trident https://netapp.github.io/trident-helm-chart 
helm repo update 
VERSION=`helm search repo | grep "netapp-trident/trident-operator" | awk '{print $2}'` 
echo "VERSION="$VERSION
helm install trident netapp-trident/trident-operator --version $VERSION \
  --create-namespace --namespace trident 

# Wait until all pods get ready.
RUNNING=0
READY=5
MAX_RETRY=35
COUNTER=20

while [ "$RUNNING" -lt $READY ]
do

echo "Sleep 10 seconds to check \"oc get pods -n openshift-cnv\""
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


echo "===== check completion using the following commands ======"

oc get pods -n trident 
oc get tbc -n trident 
