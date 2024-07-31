#! /bin/bash


rm $HOME/rosa-ocpv-qt.log
touch $HOME/rosa-ocpv-qt.log
export LOG_FILE="$HOME/rosa-ocpv-qt.log"

echo "=====================================" | tee $LOG_FILE
echo "====== Run create-all.sh script =====" | tee $LOG_FILE
echo "=====================================" | tee $LOG_FILE
echo "=====" `date` "=====" | tee $LOG_FILE

cd ../create-environment
./create-all.sh | tee $LOG_FILE

if [ $? -ne  0 ]; then
        exit 1
fi

echo "=====================================" | tee $LOG_FILE
echo "====== Run create-all.sh script =====" | tee $LOG_FILE
echo "=====================================" | tee $LOG_FILE
echo "=====" `date` "=====" | tee $LOG_FILE

cd ../test-virtual-machine
./create-virtual-machine.sh
./watch-vm-ready.sh

echo "=====================================================" | tee $LOG_FILE
echo "====== Run wait-fsx-volume-registered.sh script =====" | tee $LOG_FILE
echo "=====================================================" | tee $LOG_FILE
echo "=====" `date` "=====" | tee $LOG_FILE
cd ../development
./wait-fsx-volume-registered.sh

echo "===========================================================" | tee $LOG_FILE
echo "======  It seems all creating scripts are done        =====" | tee $LOG_FILE
echo "======  Wait for a while before deleting environment  =====" | tee $LOG_FILE
echo "===========================================================" | tee $LOG_FILE

sleep 60

echo "=====================================" | tee $LOG_FILE
echo "====== Run delete-all.sh script =====" | tee $LOG_FILE
echo "=====================================" | tee $LOG_FILE
echo "=====" `date` "=====" | tee $LOG_FILE

cd ../delete-environment 
./delete-all.sh | tee $LOG_FILE

if [ $? -ne  0 ]; then
        exit 1
fi

echo "=====================================" | tee $LOG_FILE
echo "====== create / delete done  =====" | tee $LOG_FILE
echo "=====================================" | tee $LOG_FILE
echo "=====" `date` "=====" | tee $LOG_FILE


