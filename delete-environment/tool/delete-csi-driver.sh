echo "===== Delete Storage Class  ====="
oc delete sc trident-csi
echo "===== Delete secret for trident  ====="
oc -n trident delete secret backend-fsx-ontap-nas-secret
echo "===== Delete TridentBackendConfig  ====="
oc -n trident delete TridentBackendConfig backend-fsx-ontap-nas
echo "===== Delete Trident pods ====="
helm uninstall trident -n trident


