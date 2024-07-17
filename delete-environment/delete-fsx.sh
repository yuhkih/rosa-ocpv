echo "===== Delete Storage Class  ====="
oc delete sc trident-csi
echo "===== Delete secret for trident  ====="
oc -n trident delete secret backend-fsx-ontap-nas-secret
echo "===== Delete TridentBackendConfig  ====="
oc -n trident delete TridentBackendConfig backend-fsx-ontap-nas
echo "===== Delete Trident pods ====="
helm uninstall trident -n trident
echo "===== Delete CloudFormation stack for FSx  ====="
echo "===== This would take 30 mins ====="
echo "===== Delete Start: " `date` " =====" 
aws cloudformation delete-stack --stack-name "${CLUSTER}-FSXONTAP" --region "${FSX_REGION}"
aws cloudformation wait stack-delete-complete --stack-name "${CLUSTER}-FSXONTAP" --region "${FSX_REGION}"
echo "===== Delete Complete: " `date` " =====" 

