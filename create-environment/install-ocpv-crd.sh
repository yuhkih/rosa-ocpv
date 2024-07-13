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
