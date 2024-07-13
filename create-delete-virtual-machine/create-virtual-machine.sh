oc new-project my-vms
oc create secret generic authorized-keys --from-file=ssh-publickey=$HOME/.ssh/id_rsa.pub
cat << EOF | oc apply -f -
apiVersion: kubevirt.io/v1
kind: VirtualMachine
metadata:
  name: my-first-fedora-vm
  labels:
    app: my-first-fedora-vm
spec:
  dataVolumeTemplates:
    - metadata:
        name: my-first-fedora-vm
      spec:
        preallocation: false
        sourceRef:
          kind: DataSource
          name: fedora
          namespace: openshift-virtualization-os-images
        storage:
          resources:
            requests:
              storage: 30Gi
          storageClassName: trident-csi
  running: true
  template:
    metadata:
      annotations:
        vm.kubevirt.io/flavor: small
        vm.kubevirt.io/os: fedora
        vm.kubevirt.io/workload: server
      labels:
        kubevirt.io/domain: my-first-fedora-vm
        kubevirt.io/size: small
    spec:
      accessCredentials:
        - sshPublicKey:
            propagationMethod:
              noCloud: {}
            source:
              secret:
                secretName: authorized-keys
      architecture: amd64
      domain:
        cpu:
          cores: 1
          sockets: 1
          threads: 1
        devices:
          disks:
            - bootOrder: 1
              disk:
                bus: virtio
              name: rootdisk
            - bootOrder: 2
              disk:
                bus: virtio
              name: cloudinitdisk
          interfaces:
            - masquerade: {}
              model: virtio
              name: default
          networkInterfaceMultiqueue: true
        machine:
          type: pc-q35-rhel9.2.0
        memory:
          guest: 2Gi
      networks:
        - name: default
          pod: {}
      volumes:
        - dataVolume:
            name: my-first-fedora-vm
          name: rootdisk
        - cloudInitNoCloud:
            userData: |-
              #cloud-config
              user: fedora
              password: xtg8-ly36-swy3
              chpasswd: { expire: False }
          name: cloudinitdisk
EOF




