echo "===== Start time " `date` " =====" 
echo "delete machinepool for Baremetal nodes"

# Just in case, set the environmental values again
cd ..
source ./set-env-rosa.sh
cd - 

rosa delete machine-pool virt -c $TF_VAR_cluster_name 




