# Kubernetes Multi-Node Cluster Setup

## Step 1: Create VMs

Run the following script to create virtual machines. Ensure SSH server is installed during the console installation.

```bash
#!/bin/bash
set -x 

# Check if all required arguments are provided
if [ "$#" -lt 3 ]; then
  echo "Usage: $0 <vm_name> <memory> <cpu> <disk_size>"
  exit 1
fi

# Assign command line arguments to variables
VM_MEMORY="$2"
VM_CPU="$3"
BASE_NAME="$1"
BASE_DISK_SIZE="$4"
LOCATION_URL="http://archive.ubuntu.com/ubuntu/dists/bionic/main/installer-amd64/"
NETWORK_NAME="kub-network"  

# Set the storage path for the VM
STORAGE_PATH="/home/monzu/Documents/kvm_storage"

# Create VM
virt-install \
  --name $BASE_NAME \
  --memory $VM_MEMORY \
  --vcpus $VM_CPU \
  --disk size=$BASE_DISK_SIZE,path=$STORAGE_PATH/${BASE_NAME}_disk.img \
  --network network=$NETWORK_NAME \
  --graphics=vnc -v \
  --virt-type kvm \
  --os-type linux \
  --os-variant ubuntu18.04 \
  --console pty,target_type=serial \
  --location $LOCATION_URL \
  --extra-args 'console=ttyS0,115200n8 serial'


VM Configuration
Disable swap on all VMs:

bash
Copy code
sudo swapoff -a
Uncomment the swap line in "/etc/fstab" if needed:

bash
Copy code
#/swapfile none swap sw 0 0
Update "/etc/hosts" on each VM to reflect the hostname.

bash
Copy code
nano /etc/hosts
Edit "/etc/sysctl.conf" and uncomment the following line:

bash
Copy code
#net.ipv4.ip_forward = 1
Apply the changes:

bash
Copy code
sysctl -p
Run the following command for each VM to disable swap temporarily:

bash
Copy code
sudo swapoff -a
Docker Installation on All Nodes
Install Docker on all nodes using the following commands:

bash
Copy code
sudo apt-get install apt-transport-https ca-certificates curl software-properties-common -y
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu  $(lsb_release -cs)  stable"
sudo apt-get install docker-ce -y
Kubernetes Installation
Install Kubernetes components on all nodes:

bash
Copy code
sudo apt-get install apt-transport-https ca-certificates curl software-properties-common -y &&
sudo curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add - &&
sudo apt-add-repository "deb https://apt.kubernetes.io/ Kubernetes-xenial main" &&
sudo apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main" &&
sudo apt-get update -y &&
sudo apt-get install kubectl kubelet kubeadm -y
Initialize the Kubernetes master node:

bash
Copy code
sudo kubeadm init --apiserver-advertise-address=10.100.10.49 --pod-network-cidr=10
