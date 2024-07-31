#! /bin/bash


echo -e "\e[32m =========================================== \e[m"
echo -e "\e[32m ===== 1. Delete Virtual machines      ===== \e[m"
echo -e "\e[32m =========================================== \e[m"
../test-virtual-machine/delete-vm.sh 

echo -e "\e[32m =========================================== \e[m"
echo -e "\e[32m ===== 2. Delete Baremetal Worker Node ===== \e[m"
echo -e "\e[32m =========================================== \e[m"
./delete-baremetal-machinepool.sh

if [ $? -ne  0 ]; then
        exit
fi

echo -e "\e[32m =========================================== \e[m"
echo -e "\e[32m ===== 3. Delete FSx for NetApp ONTAP  ===== \e[m"
echo -e "\e[32m =========================================== \e[m"
./delete-fsx-ontap.sh

if [ $? -ne  0 ]; then
        exit
fi

echo -e "\e[32m =========================================== \e[m"
echo -e "\e[32m ===== 4. Delete ROSA HCP Clsuter      ===== \e[m"
echo -e "\e[32m =========================================== \e[m"
./delete-rosa-cluster.sh
