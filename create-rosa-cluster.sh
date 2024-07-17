echo "===== create base ROSA cluster using terraform ====="
echo "===== Start time " `date` " ====="
terraform init
source set-env-rosa.sh
terraform plan -out rosa.plan
terraform apply rosa.plan
echo "====== you can login ROSA with the follwoing comman =====" 
echo "====== But you would need to wait for a few minuite. 401 would return for a few minuite until the server gets ready"
echo "oc login -u admin -p " $TF_VAR_admin_password " "$(terraform output -raw cluster_api_url)
echo "===== End time " `date` " ====="
