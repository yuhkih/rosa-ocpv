echo "===== create base ROSA cluster using terraform ====="
echo "===== Start time " `date` " ====="
terraform init
source set-env.sh
terraform plan -out rosa.plan
terraform apply rosa.plan
echo "===== End time " `date` " ====="
