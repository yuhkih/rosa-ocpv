FSX_VOLUME_IDS=$(aws fsx describe-volumes --region $FSX_REGION --output text --query "Volumes[?FileSystemId=='$FSX_ID' && Name!='SVM1_root'].VolumeId")
for FSX_VOLUME_ID in $FSX_VOLUME_IDS; do
  aws fsx delete-volume --volume-id $FSX_VOLUME_ID --region $FSX_REGION
done

watch "aws fsx describe-volumes --region $FSX_REGION \
  --output text --query \"Volumes[?FileSystemId=='$FSX_ID' \
  && Name!='SVM1_root'].Name\""

