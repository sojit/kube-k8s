#!/bin/bash
#set -x 

# Check if all required arguments are provided
if [ "$#" -lt 4 ]; then
  echo "Usage: $0 <vm_name> <memory> <cpu> <disk_size>"
  exit 1
fi

# Assign command line arguments to variables
VM_NAME="$1"
VM_MEMORY="$2"
VM_CPU="$3"
BASE_DISK_SIZE="$4"
NETWORK_NAME="kub-network"  
deb_qcow2_path="https://cloud.debian.org/images/cloud/buster/20190909-10/debian-10-generic-amd64-20190909-10.qcow2"
qcow_name=$(basename "$deb_qcow2_path")

image_storage_path="/home/monzu/Documents/disk_images"

vm_storage_path="/home/monzu/Documents/kvm_storage"


#check if the file exists
if [[ ! -f "$image_storage_path/$qcow_name" ]]; then
    wget  "$deb_qcow2_path"
    if [[ $? -eq 0 ]]; then
    echo "File downloaded successfully!"
    else
    echo "Download failed!"
    fi
elif [[ -f "$image_storage_path/$qcow_name" ]]; then
    vm_name="${VM_NAME}_$qcow_name"
    cp "$image_storage_path/$qcow_name"  "$vm_storage_path/$vm_name"
    
fi

 
virt-install  \
   --name "$VM_NAME" \
   --memory "$VM_MEMORY" \
   --vcpus "$VM_CPU" \
   --disk path="$vm_storage_path/$vm_name",size="$BASE_DISK_SIZE" \
   --network network="$NETWORK_NAME" \
   --os-variant ubuntu19.04 \
   --graphics none --noautoconsole \
   --console pty,target_type=virtio \
   --serial pty  \
   --cdrom=/home/monzu/Documents/kvm_storage/seed-init.iso 
