echo "Wait for a while"
export CLUSTER=${TF_VAR_cluster_name}
export FSX_REGION=$(rosa describe cluster -c ${CLUSTER} -o json | jq -r '.region.id')
export FSX_NAME="${CLUSTER}-FSXONTAP"
export FSX_SUBNET1="$(terraform output -json private_subnet_ids | jq -r '.[0]')"
export FSX_SUBNET2="$(terraform output -json private_subnet_ids | jq -r '.[1]')"
export FSX_VPC="$(terraform output -raw vpc_id)"
export FSX_VPC_CIDR="$(terraform output -raw vpc_cidr)"
export FSX_ROUTE_TABLES="$(terraform output -json private_route_table_ids | jq -r '. | join(",")')"
export METAL_AZ=$(terraform output -json private_subnet_azs | jq -r '.[0]')
export METAL_AZ1=$(terraform output -json private_subnet_azs | jq -r '.[0]')
export METAL_AZ2=$(terraform output -json private_subnet_azs | jq -r '.[1]')
export ONTAP_LOGFILE=ontap-install.log

echo "Prepare the following paramaters"
echo "CLUSTER="$CLUSTER
echo "FSX_REGION="$FSX_REGION
echo "FSX_NAME="$FSX_NAME
echo "FSX_SUNBET1="$FSX_SUBNET1
echo "FSX_SUBNET2="$FSX_SUBNET2
echo "FSX_VPC="$FSX_VPC
echo "FSX_VPC_CIDR="$FSX_VPC_CIDR
echo "FSX_ROUTE_TABE="$FSX_ROUTE_TABLES
echo "METAL_AZ="$METAL_AZ
echo "METAL_AZ1="$METAL_AZ1
echo "METAL_AZ2="$METAL_AZ2

