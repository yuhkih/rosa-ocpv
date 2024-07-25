#! /bin/bash


echo "======" date "=====" 
echo "====== wait until VM is available  ====="
RC=1
RUNNING=1
MAX=60
COUNTER=0

while [ "$RC" !=  $RUNNING ]
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
