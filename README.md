With this repository, you can create OpenShift Virtuatlization test environment with a few shell scripts.

# 1. Preparation  

## 1.1 CLI

You need to install the following command line tools.

### 1.1.1 aws
Install aws CLI from [here](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) and configure it.

```
aws configure
```

Check if the command is properly installed

```
aws --version
```

### 1.1.2 git

Install git from [here](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)

Check if the command is properly installed

```
git version
```

### 1.1.3 terraform

Install terraform from [here](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli).

```
terraform -v
```

### 1.1.4 rosa / oc 

Download rosa command

```
curl -LO https://mirror.openshift.com/pub/openshift-v4/clients/rosa/latest/rosa-linux.tar.gz
```
```
tar -zxf rosa-linux.tar.gz 
```
```
sudo mv ./rosa /usr/local/bin/
```

```
rosa download oc
```

```
tar -xzf openshift-client-linux.tar.gz 
```

```
sudo mv ./oc /usr/local/bin
```

```
sudo mv ./kubectl /usr/local/bin
```

Check if rosa command is properly installed

```
rosa version
```
Check if oc command is properly installed

```
oc version
```

### 1.1.5 jq 

install jq from [here](https://jqlang.github.io/jq/download/)


### 1.1.6 helm

install helm from [here](https://helm.sh/docs/intro/install/) 

```
helm version
```


## 1.1 Clone this reposity

This repository contains another repository as a submodule. Use `--recusrive` option to clone this repository.


```
git clone --recursive https://github.com/yuhkih/rosa-ocpv.git
```

## 1.2 Enable ROSA HCP 

You need to activate ROSA HCP on AWS console and like the AWS account to your Red Hat account. See the official [document](https://docs.openshift.com/rosa/cloud_experts_tutorials/cloud-experts-rosa-hcp-activation-and-account-linking-tutorial.html)


# 2 Create Enviroment

Move to directory where creation scripts are placed.

```
export BASE_DIR=~
```

```
cd $BASE_DIR/rosa-ocpv/create-environment
```
## 2.1 Create a ROSA Cluster

Inside the scripts, terraform script is being called.

```
./create-rosa-cluster.sh
```

Check if you can login the ROSA cluster.

```
./ocp-login.sh
```

You can see OpenShift web console url address with the following shell.

```
./ocp-show-console-url.sh
```


## 2.2 Install OpenShift Virtualization Operator

```
./install-ocpv-operator.sh
```


## 2.3 Set up FSX for NetApp ONTAP

```
./install-fsx-ontap.sh
```

## 2.4 Add Baremetal Node

Baremetal EC2 is expensive. So, I put this procedure at the end of the whole procedure.

```
./create-baremetal-machinepool.sh
```

# 3. Play with Virtual Machine

Move to directory where VM creation scripts are placed.

```
cd $BASE_DIR/rosa-ocpv/test-virtual-machine
```

## 3.1 Download virtctl

Log in OpenShift web console to download `virtctl` command. You can find the console url with the following shell.

```
./ocp-show-console-url.sh
```

```
tar xzf virtctl.tar.gz
```

```
sudo mv virtctl /usr/local/bin
```

```
virtctl version
```

## 3.2 Create a Fedora Virtual Machine

```
watch oc get virtualmachine my-first-fedora-vm
```

## 3.3 Login virtual machine

```
virtctl ssh fedora@my-first-fedora-vm -i ~/.ssh/id_vm_rsa
```

```
watch oc get virtualmachine my-first-fedora-vm
```


## 3.4 Delete VM

```
oc delete vm my-first-fedora-vm
oc delete project my-vms
```

# 4. Delete environment

## 4.1 Change directory

Move to directory where delete scripts are placed.

```
cd $BASE_DIR/rosa-ocpv/delete-environment
```

## 4.2 Delete baremetal nodes

```
./delete-baremetal-machinepool.sh
```

## 4.3 Delete FSx ONTAP

```
./delete-fsx-ontap.sh 
```

## 4.4 Delete ROSA cluster

```
./delete-rosa-cluster.sh
```




