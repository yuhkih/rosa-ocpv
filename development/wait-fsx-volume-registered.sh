#! /bin/bash
echo "===== wait start: " `date` " =====" 

echo "=================================================================================="
echo "===== This shell was made to wait for a new FSx volume to appear AWS console ====="
echo "===== Even when the volume is available as a PV on ROSA, it takes more time  ====="
echo "===== to appear as an FSx volume on AWS console                              ====="
echo "=================================================================================="

# Set all the environmental values just in case

cd ..
source ./set-env-rosa.sh
source ./set-env-fsx-ontap.sh
cd -

echo -e "\e[32m ======================= \e[m"
echo -e "\e[32m ===== Get FSx ID  ===== \e[m" 
echo -e "\e[32m ======================= \e[m"

echo "CLUSTER="$CLUSTER
echo "FSX_REGION="$FSX_REGION
FSX_ID=$(aws cloudformation describe-stacks \
  --stack-name "${CLUSTER}-FSXONTAP" \
  --region "${FSX_REGION}" --query \
  'Stacks[0].Outputs[?OutputKey==`FSxFileSystemID`].OutputValue' \
  --output text)

echo "FSX_ID="$FSX_ID


echo -e "\e[32m ============================== \e[m"
echo -e "\e[32m ===== Get FSx volume IDs ===== \e[m"
echo -e "\e[32m ============================== \e[m"

FSX_VOLUME_IDS=$(aws fsx describe-volumes --region $FSX_REGION --output text --query "Volumes[?FileSystemId=='$FSX_ID' && Name!='SVM1_root'].VolumeId")
echo "FSX_VOLUME_IDS="$FSX_VOLUME_IDS

echo -e "\e[32m ========================================= \e[m"
echo -e "\e[32m ===== Wait unitl FSx IDs registered ===== \e[m"
echo -e "\e[32m ========================================== \e[m"

# Wait until .
RETURN=1
READY=0
MAX_RETRY=60
COUNTER=0

while [ "$FSX_VOLUME_IDS" == "" ]
do

  echo "Sleep 30 seconds to check volume id registered"
  sleep 30;

  FSX_VOLUME_IDS=$(aws fsx describe-volumes --region $FSX_REGION --output text --query "Volumes[?FileSystemId=='$FSX_ID' && Name!='SVM1_root'].VolumeId")

  echo "FSX_VOLUME_IDS="$FSX_VOLUME_IDS

  let COUNTER++

  if [ "$MAX_RETRY" -lt $COUNTER ]; then
    echo "===== Time out for FSX volumes to be registered  ====="
    break
  fi
done

echo "===== wait complete: " `date` " =====" 

