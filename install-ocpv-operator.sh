echo "----- Installing OpenShift Vir Operator -----"
cat << EOF | oc apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: openshift-cnv
---
apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  name: kubevirt-hyperconverged-group
  namespace: openshift-cnv
spec:
  targetNamespaces:
    - openshift-cnv
---
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: hco-operatorhub
  namespace: openshift-cnv
spec:
  source: redhat-operators
  sourceNamespace: openshift-marketplace
  name: kubevirt-hyperconverged
  channel: "stable"
EOF

# echo "Wait for Operator CRD is available"
# wait 10
# oc projectopenshift-cnv
# get pods | grep Running | wc -l # =12
# wait 60
RUNNING=0
READY=35
MAX=35
COUNTER=20

while [ "$RUNNING" -lt $READY ]
do

echo "Sleep 10 seconds to check \"oc get pods -n openshift-cnv\""
sleep 10;
RUNNING=`oc get pods -n openshift-cnv | grep "Running" | wc -l`

let COUNTER++

if [ "$MAX" -lt $COUNTER ]; then
echo "===== Time out ====="
break
fi 
done


oc get pods -n openshift-cnv

echo "=====  Create HyperConverged CRD ====="

cat << EOF | oc apply -f -
apiVersion: hco.kubevirt.io/v1beta1
kind: HyperConverged
metadata:
  name: kubevirt-hyperconverged
  namespace: openshift-cnv
  annotations:
    deployOVS: "false"
  labels:
    app: kubevirt-hyperconverged
spec:
  applicationAwareConfig:
    allowApplicationAwareClusterResourceQuota: false
    vmiCalcConfigName: DedicatedVirtualResources
  certConfig:
    ca:
      duration: 48h0m0s
      renewBefore: 24h0m0s
    server:
      duration: 24h0m0s
      renewBefore: 12h0m0s
  evictionStrategy: LiveMigrate
  featureGates:
    alignCPUs: false
    autoResourceLimits: false
    deployKubeSecondaryDNS: false
    deployTektonTaskResources: false
    deployVmConsoleProxy: false
    disableMDevConfiguration: false
    enableApplicationAwareQuota: false
    enableCommonBootImageImport: true
    enableManagedTenantQuota: false
    nonRoot: true
    persistentReservation: false
    withHostPassthroughCPU: false
  infra: {}
  liveMigrationConfig:
    allowAutoConverge: false
    allowPostCopy: false
    completionTimeoutPerGiB: 800
    parallelMigrationsPerCluster: 5
    parallelOutboundMigrationsPerNode: 2
    progressTimeout: 150
  resourceRequirements:
    vmiCPUAllocationRatio: 10
  uninstallStrategy: BlockUninstallIfWorkloadsExist
  virtualMachineOptions:
    disableFreePageReporting: false
    disableSerialConsoleLog: true
  workloadUpdateStrategy:
    batchEvictionInterval: 1m0s
    batchEvictionSize: 10
    workloadUpdateMethods:
    - LiveMigrate
  workloads: {}
EOF


