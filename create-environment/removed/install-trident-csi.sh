echo "===== Set environmetal variables ====="
echo "===== Start time " `date` " ====="

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
echo "FSX_ADMIN_PASS="$FSX_ADMIN_PASS
echo "SVM_ADMIN_PASS="$SVM_ADMIN_PASS


# it's not good idea to use fixed version. need to fix later
echo "===== install trident helm chart ====="
helm repo add netapp-trident https://netapp.github.io/trident-helm-chart
helm repo update
helm search repo netapp-trident
VERSION=`helm search repo | grep "netapp-trident/trident-operator" | awk '{print $2}'`
echo "VERSION="$VERSION
helm install trident netapp-trident/trident-operator --version $VERSION \
  --create-namespace --namespace trident

helm status trident-csi


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

echo "oc get pods -n trident"
echo "oc get tbc -n trident"
