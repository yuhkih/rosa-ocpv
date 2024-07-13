oc delete sc trident-csi
oc -n trident delete TridentBackendConfig backend-fsx-ontap-nas
helm uninstall trident-csi -n trident

