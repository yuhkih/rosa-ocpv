#! /bin/bash

echo -e "\e[32m===========================================\e[m"
echo -e "\e[32m===== 1. Create ROSA HCP Cluster      =====\e[m"
echo -e "\e[32m===========================================\e[m"
./create-rosa-cluster.sh

if [ $? -ne  0 ]; then
        exit
fi

echo -e "\e[32m===========================================\e[m"
echo -e "\e[32m===== 2. Install FSx for NetApp ONTAP =====\e[m"
echo -e "\e[32m===========================================\e[m"
./install-fsx-ontap.sh

if [ $? -ne  0 ]; then
        exit
fi

echo -e "\e[32m===========================================\e[m"
echo -e "\e[32m===== 3. Insall OCP-V Operator        =====\e[m"
echo -e "\e[32m===========================================\e[m"
./install-ocpv-operator.sh

if [ $? -ne  0 ]; then
        exit
fi

echo -e "\e[32m===========================================\e[m"
echo -e "\e[32m===== 4. Add Baremetal Worker Nodes    =====\e[m"
echo -e "\e[32m===========================================\e[m"
./create-baremetal-machinepool.sh

