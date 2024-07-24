#!/bin/bash
export TF_VAR_token="$(jq -r .refresh_token ~/.config/ocm/ocm.json)"
export TF_VAR_cluster_name="$(whoami)-hcp"
export TF_VAR_admin_password="$(whoami)-Passw0rd12345!"
export TF_VAR_developer_password="$(whoami)-Passw0rd12345!"
export CLUSTER=$TF_VAR_cluster_name
# export CLUSTER_API_URL="$(terraform output -raw cluster_api_url)"

echo "===== Set the follwoing environment variables ====="
echo "TF_VAR_token="$TF_VAR_token
echo "TF_VAR_cluster_name="$TF_VAR_cluster_name
echo "TF_VAR_admin_password="$TF_VAR_admin_password
echo "TF_VAR_developer_password="$TF_VAR_developer_password
echo "CLUSTER="$CLUSTER
# echo "CLUSTER_API_URL="$CLUSTER_API_URL
