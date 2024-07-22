#! /bin/bash
echo "===== Create Baremetal Node machinepool ====="
echo "===== This will take about 20 mins ====="
echo "===== Start time " `date` " =====" 
echo "create machinepool for Baremetal nodes"

cd ..
source set-env-rosa.sh
cd -

rosa create machine-pool -c $TF_VAR_cluster_name \
   --replicas 2 --availability-zone $METAL_AZ \
   --instance-type m5zn.metal --name virt


# Wait until all pods get ready.
READY=0
NODE_OK=1
MAX_RETRY=90
COUNTER=0

while [ "$NODE_OK" -ne $READY ]
do
  echo "Baremetal nodes are not Ready yet. Sleep 60 seconds. then check \"rosa list machinepools\" again"
  sleep 60;
  READY=`rosa list machinepools --cluster $TF_VAR_cluster_name | grep virt  | grep "2/2" | wc -l`

let COUNTER++

if [ "$MAX_RETRY" -lt $COUNTER ]; then
    echo "===== Time out ====="
    break
fi
done


echo "===== End time " `date` " =====" 
