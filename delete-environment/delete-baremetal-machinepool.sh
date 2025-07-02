echo "===== Start time " `date` " =====" 
echo "delete machinepool for Baremetal nodes"

# Just in case, set the environmental values again
cd ..
source ./set-env-rosa.sh
cd - 

rosa delete machine-pool virt1 -c $TF_VAR_cluster_name -y
rosa delete machine-pool virt2 -c $TF_VAR_cluster_name -y


