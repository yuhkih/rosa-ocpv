#! /bin/bash

rm /home/yuhki/rosa-ocpv-qt.log
touch /home/yuhki/rosa-ocpv-qt.log
export LOG_FILE="/home/yuhki/rosa-ocpv-qt.log"

echo "=====================================" | tee $LOG_FILE
echo "====== Run create-all.sh script =====" | tee $LOG_FILE
echo "=====================================" | tee $LOG_FILE
echo "=====" date "=====" | tee $LOG_FILE

cd ../create-environment
./create-all.sh | tee $LOG_FILE


echo "=====================================" | tee $LOG_FILE
echo "====== Run create-all.sh script =====" | tee $LOG_FILE
echo "=====================================" | tee $LOG_FILE
echo "=====" date "=====" | tee $LOG_FILE

cd ../test-virtual-machine
./create-virtual-machine.sh
./watch-vm-ready.sh

sleep 60

echo "=====================================" | tee $LOG_FILE
echo "====== Run delete-all.sh script =====" | tee $LOG_FILE
echo "=====================================" | tee $LOG_FILE
echo "=====" date "=====" | tee $LOG_FILE

cd ../delete-environment 
./delete-all.sh | tee $LOG_FILE

echo "=====================================" | tee $LOG_FILE
echo "====== create / delete done  =====" | tee $LOG_FILE
echo "=====================================" | tee $LOG_FILE
echo "=====" date "=====" | tee $LOG_FILE


