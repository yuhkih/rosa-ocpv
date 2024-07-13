echo "----- Installing OpenShift Vir Operator -----"
cat << EOF | oc apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: openshift-cnv
---
apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  name: kubevirt-hyperconverged-group
  namespace: openshift-cnv
spec:
  targetNamespaces:
    - openshift-cnv
---
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: hco-operatorhub
  namespace: openshift-cnv
spec:
  source: redhat-operators
  sourceNamespace: openshift-marketplace
  name: kubevirt-hyperconverged
  startingCSV: kubevirt-hyperconverged-operator.v4.15.1
  channel: "stable"
EOF

# echo "Wait for Operator CRD is available"
# wait 10
# oc projectopenshift-cnv
# get pods | grep Running | wc -l # =12
# wait 60

echo "execute \"get pods -n projectopenshift-cnv\" and then wait for all pods to get Running"
echo "execute \"install-ocpv-crd.sh\" after all the pods are \"Running\""
