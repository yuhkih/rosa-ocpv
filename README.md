With this repository, you can create OpenShift Virtuatlization test environment with a few shell scripts.

# 1. Preparation  

## 1.1 Download and setup CLI

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



# 2 Enable ROSA HCP and link the AWS account with your Red Hat account

You need to activate ROSA HCP on AWS console and link the AWS account with your Red Hat account. See the official [document](https://docs.openshift.com/rosa/cloud_experts_tutorials/cloud-experts-rosa-hcp-activation-and-account-linking-tutorial.html)

It's a simple procedure, but I think a lot of people (including me) tend to forget this process when working with a new AWS account. 
Please make sure not only you enabled HCP but also linked your AWS account with your Red Hat account.

You need to create a Red Hat account if you don't have one. Creating a Red Hat account is for free from [Red Hat Customer Portal](https://access.redhat.com/) 

# 3 Create Enviroment

This repository contains another repository as a submodule. Use `--recusrive` option to clone this repository.

```
git clone --recursive https://github.com/yuhkih/rosa-ocpv.git
```

Move to directory where creation scripts are placed.

```
export BASE_DIR=~
```

```
cd $BASE_DIR/rosa-ocpv/create-environment
```

## 3.1 Create a ROSA Cluster

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


## 3.2 Install OpenShift Virtualization Operator

```
./install-ocpv-operator.sh
```


## 3.3 Set up FSX for NetApp ONTAP

```
./install-fsx-ontap.sh
```

## 3.4 Add Baremetal Node

Baremetal EC2 is expensive. So, I put this procedure at the end of the whole procedure.

```
./create-baremetal-machinepool.sh
```

# 4. Play with a Virtual Machine

Move to directory where VM creation scripts are placed.

```
cd $BASE_DIR/rosa-ocpv/test-virtual-machine
```

## 4.1 Download virtctl

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

## 4.2 Create a Fedora Virtual Machine

```
watch oc get virtualmachine my-first-fedora-vm
```

## 4.3 Login virtual machine

```
virtctl ssh fedora@my-first-fedora-vm -i ~/.ssh/id_vm_rsa
```

```
watch oc get virtualmachine my-first-fedora-vm
```


## 4.4 Delete VM

```
oc delete vm my-first-fedora-vm
oc delete project my-vms
```

# 5. Clean up 

## 5.1 Change directory

Move to directory where delete scripts are placed.

```
cd $BASE_DIR/rosa-ocpv/delete-environment
```

## 5.2 Delete baremetal nodes

```
./delete-baremetal-machinepool.sh
```

## 5.3 Delete FSx ONTAP

```
./delete-fsx-ontap.sh 
```

## 5.4 Delete ROSA cluster

```
./delete-rosa-cluster.sh
```




