#! /bin/bash

echo "==========================================="
echo "===== 1. Create ROSA HCP Cluster      ====="
echo "==========================================="
./create-rosa-cluster.sh

if [ $? -ne  0 ]; then
        exit
fi

echo "==========================================="
echo "===== 2. Install FSx for NetApp ONTAP ====="
echo "==========================================="
./install-fsx-ontap.sh

if [ $? -ne  0 ]; then
        exit
fi

echo "==========================================="
echo "===== 3. Insall OCP-V Operator        ====="
echo "==========================================="
./install-ocpv-operator.sh

if [ $? -ne  0 ]; then
        exit
fi

echo "==========================================="
echo "===== 4. Add Baremetal Worker Nodes    ====="
echo "==========================================="
./create-baremetal-machinepool.sh

