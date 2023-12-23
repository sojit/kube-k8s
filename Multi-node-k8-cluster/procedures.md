# Kubernetes Multi-Node Cluster Setup using Ubuntu

## Prerequisites for the setup
1. Prepare VM's 
2. Disable Swap and enable IP forwarding. 
3. Install Docker Runtime. 
4. Install k8 componenet on all nodes.


## Step 1: Create VMs using KVM, 

Run the following script to create virtual machines individually based on the need. Furthermore, ensure to install the SSH server during VM initialization.

```bash
#!/bin/bash
set -x 

# Check if all required arguments are provided
if [ "$#" -lt 4 ]; then
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
```

## Post-VM Creation Configuration

Once the VMs are ready, use the following commands for post-creation configuration:

1. Disable swap:

    ```bash
    sudo swapoff -a
    ```

   Uncomment the swap enrty from the "/etc/fstab" file to turn off swap permanently:

   ```bash
   #/swapfile none swap sw 0 0

2. Enable IP forwading in the VMs by uncommenting the following line from the "/etc/sysctl.conf" file. 

   ```bash
   net.ipv4.ip_forward = 1
   ```
   
   Use  ```sudo sysctl -p``` to apply the change. 

3. Add the k8 node VMs hostnames in the file ```/etc/hosts```  file for easy node access. 
   

## Step 2 Docker Installation on All Nodes

a. Install the required dependencies to access Docker:

```bash
sudo apt-get install apt-transport-https ca-certificates curl software-properties-common -y
```
b. Add Docker’s GPG key (requires root user):
```bash
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
```
c. Add Docker’s official repository to apt:
```bash
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu  $(lsb_release -cs)  stable"
```
d. Run the following command to install Docker.
```bash
sudo apt-get install docker.io -y
```

 Once after the installtion you we can verify the status using ```docker -v``` or ```docker version```. 

### Step 3: Kubernetes Installation 

1. Install Kubernetes repository




