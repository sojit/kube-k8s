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

# Set the download path for the ISO
ISO_DOWNLOAD_PATH="/home/monzu/Documents/disk_images"

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

