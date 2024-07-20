# Wait until all pods get ready.
READY=0
NODE_OK=1
MAX_RETRY=90
COUNTER=0

while [ "$NODE_OK" -ne $READY ]
do
  echo "Sleep 60 seconds to check \"rosa list machinepools\""
  sleep 60;
  READY=`rosa list machinepools --cluster $TF_VAR_cluster_name | grep virt  | grep "2/2" | wc -l`

let COUNTER++

if [ "$MAX_RETRY" -lt $COUNTER ]; then
    echo "===== Time out ====="
    break
fi
done
