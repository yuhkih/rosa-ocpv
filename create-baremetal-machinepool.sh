echo "create machinepool for Baremetal nodes"
rosa create machine-pool -c $TF_VAR_cluster_name \
   --replicas 2 --availability-zone $METAL_AZ \
   --instance-type m5zn.metal --name virt
