export FSX_ADMIN_PASS=$(LC_ALL=C tr -dc A-Za-z0-9 </dev/urandom | head -c 16; echo)
export SVM_ADMIN_PASS=$(LC_ALL=C tr -dc A-Za-z0-9 </dev/urandom | head -c 16; echo)
echo  FSX_ADMIN_PASS=$FSX_ADMIN_PASS
echo  SVM_ADMIN_PASS=$SVM_ADMIN_PASS
