With this repository, you can create OpenShift Virtualization test environment with a few shell scripts.

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

It's a simple procedure, but I think many people (including me) tend to forget this process when working with a new AWS account. 
Please make sure you not only enabled HCP but also linked your AWS account with your Red Hat account.

You need to create a Red Hat account if you don't have one. Creating a Red Hat account is for free from [Red Hat Customer Portal](https://access.redhat.com/) 

# 3 Create Environment

The scripts included in this repository will create the following environment.
![image](https://github.com/user-attachments/assets/91421078-8367-4bd8-b0fe-4a557b4208c8)

This repository contains another repository as a submodule. Use `--recusrive` option to clone this repository.

```
git clone --recursive https://github.com/yuhkih/rosa-ocpv.git
```

Move to the directory where creation scripts are placed.

```
export BASE_DIR=`pwd`
```

```
cd $BASE_DIR/rosa-ocpv/create-environment
```

## 3.1 Create a ROSA Cluster (20-30mins)

log in to your Red Hat account.

```
rosa login
```

Set AWS region where you want to create a ROSA HCP cluster. You can check AWS region name [here](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.RegionsAndAvailabilityZones.html).

The default is ap-northeast-1 (Tokyo). If you want to change it to ap-southeast-1 (Singapore), set the region name to TF_VAR_region.

```
export TF_VAR_region=ap-southeast-1
```

Sample regions:

```
Asia Pacific (Melbourne) : ap-southeast-4
Asia Pacific (Mumbai) : ap-south-1
Asia Pacific (Seoul) : ap-northeast-2
Asia Pacific (Singapore) : ap-southeast-1
Asia Pacific (Sydney) : ap-southeast-2
Asia Pacifig (Tokyo) : ap-northeast-1
```

Inside the scripts, terraform script will be called.

```
./create-rosa-cluster.sh
```

Check if you can log in the ROSA cluster.

```
./ocp-login.sh
```

You can see OpenShift web console url address with the following shell.

```
./ocp-show-console-url.sh
```


## 3.2 Install OpenShift Virtualization Operator (5 mins)

This will install OpenShift Virtualization Operator on OpenShift cluster.

```
./install-ocpv-operator.sh
```


## 3.3 Set up FSx for NetApp ONTAP (30-40 mins)

This will create FSx for Net App ONTAP as RWX storage which can be accessed from all OpenShift nodes and then install CSI driver. 

```
./install-fsx-ontap.sh
```

## 3.4 Add two Baremetal Nodes (20-30 mins)

Baremetal EC2 is expensive. So, I put this procedure at the end of the whole procedure.

```
./create-baremetal-machinepool.sh
```

This shell tries to create two bare-metal nodes(`m5zn.metal`) in your AWS region. But AWS sometimes takes a long time to deploy two bare-metal nodes depending on the region.


# 4. Play with a Virtual Machine

Move to the directory where VM creation scripts are placed.

```
cd $BASE_DIR/rosa-ocpv/test-virtual-machine
```

## 4.1 Download virtctl

Log in OpenShift web console to download `virtctl` command. You can find the console url with the following shell.

```
./ocp-show-console-url.sh
```

After logging in to the console, select "Command Line Tools"

![image](https://github.com/user-attachments/assets/60e458c8-0b8a-4055-8e2e-bd2a409c5829)

Download `virtclt` tool.

![image](https://github.com/user-attachments/assets/0067472f-be21-478a-a4c6-98f7baa23cb4)

```
tar xzf virtctl.tar.gz
```

```
sudo mv virtctl /usr/local/bin
```

```
virtctl version
```

## 4.2 Create a Fedora Virtual Machine (10 mins)

Create a virtual machine "my-first-fedora-vm"

```
./create-virtual-machine.sh
```

Wait for the virtual machine to be ready.

```
./watch-vm-ready.sh
```

## 4.3 Login the Fedora virtual machine

```
virtctl ssh fedora@my-first-fedora-vm -i ~/.ssh/id_vm_rsa
```

## 4.4  Operato virtual machine from OpenShift console.

You can also operate the virtual machine from OpenShift UI. You can get OpenShift console URL with the following shell.

```
./ocp-show-console-url.sh
```

After logging in to the console, go to "Virtualization" => "Virtual Machine", you can start, stop, or live migrate your virtual machine from there.

![image](https://github.com/user-attachments/assets/c973ac78-4c27-4f3e-8eb1-1d0f0e4ccc1d)

![image](https://github.com/user-attachments/assets/305b1c31-b75e-4930-b954-d384bbf68a40)

## 4.5 Delete VM

```
oc delete vm my-first-fedora-vm
oc delete project my-vms
```

delete the ssh key from known hosts for the Fedora VM.

```
ssh-keygen -f $HOME"/.ssh/known_hosts" -R "vmi/my-first-fedora-vm.my-vms"
```

# 5. Clean up environment

## 5.1 Change directory

Move to the directory where delete scripts are placed.

```
cd $BASE_DIR/rosa-ocpv/delete-environment
```

## 5.2 Delete bare-metal nodes

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
