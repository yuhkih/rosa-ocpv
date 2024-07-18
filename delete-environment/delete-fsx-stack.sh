echo "===== Delete CloudFormation stack for FSx  ====="
echo "===== This would take 30 mins ====="
echo "===== Delete Start: " `date` " =====" 
aws cloudformation delete-stack --stack-name "${CLUSTER}-FSXONTAP" --region "${FSX_REGION}"
aws cloudformation wait stack-delete-complete --stack-name "${CLUSTER}-FSXONTAP" --region "${FSX_REGION}"
echo "===== Delete Complete: " `date` " =====" 

