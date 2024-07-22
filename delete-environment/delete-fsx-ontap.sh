#! /bin/bash
echo "===== FSx for NetApp ONTAP Deletion Start: " `date` " ====="
echo "===== This would take about more than 20 mins  ====="

# Set all the environmental values just in case

cd ..
source ./set-env-rosa.sh
source ./set-env-fsx-ontap.sh
cd -


echo "CLUSTER="$CLUSTER
echo "FSX_REGION="$FSX_REGION
FSX_ID=$(aws cloudformation describe-stacks \
  --stack-name "${CLUSTER}-FSXONTAP" \
  --region "${FSX_REGION}" --query \
  'Stacks[0].Outputs[?OutputKey==`FSxFileSystemID`].OutputValue' \
  --output text)

echo "FSX_ID="$FSX_ID

FSX_VOLUME_IDS=$(aws fsx describe-volumes --region $FSX_REGION --output text --query "Volumes[?FileSystemId=='$FSX_ID' && Name!='SVM1_root'].VolumeId")
for FSX_VOLUME_ID in $FSX_VOLUME_IDS; do
  aws fsx delete-volume --volume-id $FSX_VOLUME_ID --region $FSX_REGION
done

echo "FSX_VOLUME_IDS="$FSX_VOLUME_IDS
if [ "$FSX_VLUME_IDS" == "" ]; then
  echo "===== FSX vlumes don't exist ====="
fi


# Wait until .
RETURN=1
READY=0
MAX_RETRY=60
COUNTER=0

while [ "$RETURN" -gt "0" ]
do

  echo "Sleep 10 seconds to check volume delete completion"
  sleep 10;

  RETURN=`aws fsx describe-volumes --region $FSX_REGION --output text --query "Volumes[?FileSystemId=='$FSX_ID'  && Name!='SVM1_root'].Name" | wc -l`

  let COUNTER++

  if [ "$MAX_RETRY" -lt $COUNTER ]; then
    echo "===== Time out to delete FSX volumes  ====="
    break
  fi
done


echo "===== Delete FSx stack using CloudFormation. This would take 30 mins ====="
echo "===== Delete Start: " `date` " =====" 
aws cloudformation delete-stack --stack-name "${CLUSTER}-FSXONTAP" --region "${FSX_REGION}"
aws cloudformation wait stack-delete-complete --stack-name "${CLUSTER}-FSXONTAP" --region "${FSX_REGION}"
echo "===== Delete Complete: " `date` " =====" 

