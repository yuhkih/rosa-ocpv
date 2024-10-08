#! /bin/bash
echo "===== Create Baremetal Node machinepool ====="
echo "===== This will take about 20 mins ====="
echo "===== Start: " `date` " =====" 
echo "create machinepool for Baremetal nodes"

cd ..
source set-env-rosa.sh
source set-env-fsx-ontap.sh
cd -


# create machinepools
 rosa create machine-pool -c $TF_VAR_cluster_name \
   --replicas 1 --availability-zone $METAL_AZ1 \
   --instance-type m5zn.metal --name virt1 

 rosa create machine-pool -c $TF_VAR_cluster_name \
   --replicas 1 --availability-zone $METAL_AZ2 \
   --instance-type m5zn.metal --name virt2 

# Wait until all pods get ready.
READY=0
NODE_OK=2
MAX_RETRY=90
COUNTER=0

while [ "$NODE_OK" -ne $READY ]
do
  echo "Baremetal nodes are not Ready yet. Sleep 60 seconds. then check \"rosa list machinepools\" again"
  sleep 60;
  READY=`rosa list machinepools --cluster $TF_VAR_cluster_name | grep virt  | grep "1/1" | wc -l`

let COUNTER++

if [ "$MAX_RETRY" -lt $COUNTER ]; then
    echo "===== Time out ====="
    break
fi
done

echo "===== Baremetal nodes are successfully added ====="
rosa list machinepools --cluster $TF_VAR_cluster_name | grep virt  | grep "1/1" 

echo "===== End: " `date` " =====" 
