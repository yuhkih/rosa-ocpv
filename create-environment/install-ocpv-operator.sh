#! /bin/bash

echo "===== Installing OpenShift Vir Operator ====="
cd ..
source set-env-rosa.sh
cd - 
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
READY=11 # 12 pods should be running.
MAX=60
COUNTER=0

while [ "$RUNNING" -lt $READY ]
do

echo "Sleep for 10 seconds before checking \"oc get pods -n openshift-cnv\""
sleep 10;
RUNNING=`oc get pods -n openshift-cnv | grep "Running" | wc -l`

let COUNTER++

if [ "$MAX" -lt $COUNTER ]; then
echo "===== Time out ====="
break
fi 
done


oc get pods -n openshift-cnv

# echo "===== exit for debug =====" 
# exit 


echo "=====  Create HyperConverged CRD ====="

cat << EOF | oc apply -f -
apiVersion: hco.kubevirt.io/v1beta1
kind: HyperConverged
metadata:
  name: kubevirt-hyperconverged
  annotations:
    deployOVS: 'false'
  namespace: openshift-cnv
spec:
  enableCommonBootImageImport: true
  virtualMachineOptions:
    disableFreePageReporting: false
    disableSerialConsoleLog: false
  higherWorkloadDensity:
    memoryOvercommitPercentage: 100
  liveMigrationConfig:
    allowAutoConverge: false
    allowPostCopy: false
    completionTimeoutPerGiB: 150
    parallelMigrationsPerCluster: 5
    parallelOutboundMigrationsPerNode: 2
    progressTimeout: 150
  certConfig:
    ca:
      duration: 48h0m0s
      renewBefore: 24h0m0s
    server:
      duration: 24h0m0s
      renewBefore: 12h0m0s
  enableApplicationAwareQuota: false
  applicationAwareConfig:
    allowApplicationAwareClusterResourceQuota: false
    vmiCalcConfigName: DedicatedVirtualResources
  featureGates:
    downwardMetrics: false
    disableMDevConfiguration: false
    deployKubeSecondaryDNS: false
    alignCPUs: false
    persistentReservation: false
  workloadUpdateStrategy:
    batchEvictionInterval: 1m0s
    batchEvictionSize: 10
    workloadUpdateMethods:
      - LiveMigrate
  deployVmConsoleProxy: false
  uninstallStrategy: BlockUninstallIfWorkloadsExist
  resourceRequirements:
    vmiCPUAllocationRatio: 10
EOF


