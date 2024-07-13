oc get pod -l "kubevirt.io/domain=my-first-fedora-vm" -o jsonpath="{.items[0].metadata.labels.kubevirt\.io/nodeName}"

