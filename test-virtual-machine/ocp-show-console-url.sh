cd ..
source ./set-env-rosa.sh 2>&1 >null
oc whoami --show-console
echo "You can login with user= admin, password= "$TF_VAR_admin_password
