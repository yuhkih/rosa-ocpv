#! /bin/bash

echo "==========================================="
echo "===== 1. Create ROSA HCP Cluster      ====="
echo "==========================================="
./create-rosa-cluster.sh


echo "==========================================="
echo "===== 2. Install FSx for NetApp ONTAP ====="
echo "==========================================="
./install-fsx-ontap.sh

echo "==========================================="
echo "===== 3. Insall OCP-V Operator        ====="
echo "==========================================="
./install-ocpv-operator.sh

echo "==========================================="
echo "===== 4. Add Baremetal Worker Nodes    ====="
echo "==========================================="
./create-baremetal-machinepool.sh

