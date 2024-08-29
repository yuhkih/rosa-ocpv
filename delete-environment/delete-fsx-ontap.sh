#! /bin/bash
echo "===== FSx for NetApp ONTAP Deletion Start: " `date` " ====="
echo "===== This would take about more than 20 mins  ====="

# Set all the environmental values just in case

cd ..
source ./set-env-rosa.sh
source ./set-env-fsx-ontap.sh
cd -

echo "============================================================="


echo "CLUSTER="$CLUSTER
echo "FSX_REGION="$FSX_REGION
FSX_ID=$(aws cloudformation describe-stacks \
  --stack-name "${CLUSTER}-FSXONTAP" \
  --region "${FSX_REGION}" --query \
  'Stacks[0].Outputs[?OutputKey==`FSxFileSystemID`].OutputValue' \
  --output text)

echo "FSX_ID="$FSX_ID


echo "============================================================="

FSX_VOLUME_IDS=$(aws fsx describe-volumes --region $FSX_REGION --output text --query "Volumes[?FileSystemId=='$FSX_ID' && Name!='SVM1_root'].VolumeId")
for FSX_VOLUME_ID in $FSX_VOLUME_IDS; do
  aws fsx delete-volume --volume-id $FSX_VOLUME_ID --region $FSX_REGION
done

echo "FSX_VOLUME_IDS="$FSX_VOLUME_IDS
if [[ $FSX_VOLUME_IDS == "" ]] ; then
  echo "===== FSX vlumes don't exist ====="
  echo " Something wrong...but continue"
  # exit 1
fi


# Wait until .
RETURN=1
READY=0
MAX_RETRY=60
COUNTER=0

while [ "$RETURN" -gt "0" ]
do

  echo "Sleep 30 seconds to check volume delete completion"
  sleep 30;

  RETURN=`aws fsx describe-volumes --region $FSX_REGION --output text --query "Volumes[?FileSystemId=='$FSX_ID'  && Name!='SVM1_root'].Name" | wc -l`

  echo "RETURN="$RETURN

  let COUNTER++

  if [ "$MAX_RETRY" -lt $COUNTER ]; then
    echo "===== Time out to delete FSX volumes  ====="
    break
  fi
done

echo "============================================================="
echo "===== Delete FSx stack using CloudFormation. This would take 30 mins ====="
echo "===== Delete Start: " `date` " =====" 
RESULT=`aws cloudformation delete-stack --stack-name "${CLUSTER}-FSXONTAP" --region "${FSX_REGION}" 2>&1 `
echo "aws cloudformation delete-stack RESULT=" $RESULT " ( expectation is NULL when succeeded ) "

# Wait and check the result (sometimes fail to delete)
RESULT=`aws cloudformation wait stack-delete-complete --stack-name "${CLUSTER}-FSXONTAP" --region "${FSX_REGION}" 2>&1 | grep "DELETE_FAILED" | wc -l `

echo "Wait stack delete completion" 
echo "aws cloudformation wait stack-delete-complete RESULT=" $RESULT " ( expectation is 0 when succeeded ) "

if [ "$RESULT" -eq 1 ]; then 
  # echo -e  "\e[35m ===== Initial CloudFromation Stack delete failed. FORCE_DELETE_STACK will be executed ===== \e[m"
  # echo "===== Force Delete Start: " `date` " ====="
  # aws cloudformation delete-stack --stack-name "${CLUSTER}-FSXONTAP" --region "${FSX_REGION}" --deletion-mode FORCE_DELETE_STACK
  # echo "==== Wait until force delete completion  ====="
  # aws cloudformation wait stack-delete-complete --stack-name "${CLUSTER}-FSXONTAP" --region "${FSX_REGION}"
  echo -e  "\e[35m ===== There is a good chance that the FSx volume for the Fedora VM  was registered just after the deletion check. Check the AWS Console for FSx and delete remaining objects manually.  ===== \e[m"
  echo -e  "\e[35m ===== Or run delete-fsx-ontap.sh manually again  ===== \e[m"
  exit 1
fi

echo "===== Delete Complete: " `date` " =====" 
echo "===== Now you can delete ROSA HCP cluster using delete-rosa-cluster.sh =====" 
