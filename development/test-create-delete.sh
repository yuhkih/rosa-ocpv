#! /bin/bash

export LOG_FILE="~/rosa-ocpv-qt.log"

echo "=====================================" | tee $LOG_FILE
echo "====== Run create-all.sh script =====" | tee $LOG_FILE
echo "=====================================" | tee $LOG_FILE
echo "=====" date "=====" | tee $LOG_FILE

cd ../create-environment
./create-all.sh | tee $LOG_FILE




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


