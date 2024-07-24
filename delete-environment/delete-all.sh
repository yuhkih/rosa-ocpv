#! /bin/bash


echo "==========================================="
echo "===== 1. Delete Virtual machines      ====="
echo "==========================================="
oc delete vm my-first-fedora-vm
oc delete project my-vms

echo "==========================================="
echo "===== 2. Delete Baremetal Worker Node ====="
echo "==========================================="
./delete-baremetal-machinepool.sh

if [ $? -ne  0 ]; then
        exit
fi

echo "==========================================="
echo "===== 3. Delete FSx for NetApp ONTAP  ====="
echo "==========================================="
./delete-fsx-ontap.sh

if [ $? -ne  0 ]; then
        exit
fi

echo "==========================================="
echo "===== 4. Delete ROSA HCP Clsuter      ====="
echo "==========================================="
./delete-rosa-cluster.sh
