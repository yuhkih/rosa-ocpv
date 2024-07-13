echo "===== Set environmetal variables =====" 
cd ..
source set-env-for-fsx-ontap.sh

echo "===== Make sure FSX cloudFormation completion, just in case ====="
aws cloudformation wait stack-create-complete --stack-name "${CLUSTER}-FSXONTAP" --region "${FSX_REGION}"

echo "===== Prepare necessary environment variables ====="
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

echo "===== install trident helm chart ====="
helm repo add netapp https://netapp.github.io/trident-helm-chart
helm repo update
helm install trident-csi netapp/trident-operator \
  --create-namespace --namespace trident
oc get pods -n trident

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

oc get pods -n trident
oc get tbc -n trident
