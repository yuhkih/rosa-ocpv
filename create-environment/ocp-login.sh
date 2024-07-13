oc login -u admin -p $TF_VAR_admin_password $(terraform output -raw cluster_api_url) 
