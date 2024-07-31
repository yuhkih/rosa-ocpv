#! /bin/bash


echo "======" `date` "=====" 
echo "====== wait until VM is available  ====="
RC=0
RUNNING=1
MAX=100
COUNTER=0

while [ "$RC" -ne  $RUNNING ]
do

RC=`oc get virtualmachine my-first-fedora-vm | grep "Running"  | wc -l`
oc get virtualmachine my-first-fedora-vm

echo "Sleep 30 seconds and then check again"
sleep 30;

let COUNTER++

if [ "$MAX" -lt $COUNTER ]; then
echo "===== Time out ====="
break
fi
done

echo "===== Summary ====="
oc get virtualmachine -n my-vms
echo "==================="
oc get pvc -n my-vms
echo "==================="
oc get pv | grep trident
echo "===================="

echo "======" `date` "====="  

