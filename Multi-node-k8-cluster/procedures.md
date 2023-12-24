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

   Uncomment the swap enrty from the `"/etc/fstab"` file to turn off swap permanently:

   ```bash
   #/swapfile none swap sw 0 0

2. Enable IP forwading in the VMs by uncommenting the following line from the "/etc/sysctl.conf" file. 

   ```bash
   net.ipv4.ip_forward = 1
   ```
   Use  `sudo sysctl -p` to apply the change.
   Also, make sure to enable the bridge parameters. for more details [refer](https://wiki.libvirt.org/Net.bridge.bridge-nf-call_and_sysctl.conf.html) 
   ```bash
   modprobe br_netfilter
   echo 1 > /proc/sys/net/bridge/bridge-nf-call-iptables
   ```    

4. Add the k8 node VMs hostnames in the file ```/etc/hosts```  file for easy node access. 
   

## Step 2 Install container runtime, we will be using containerd

a. Install the package using the following command: 
   ```bash
   sudo apt-get install containerd
   ```
   
## Step 3: Kubernetes Installation 

1. Install Kubernetes repository and the package using the following commands. [Ref link](https://v1-28.docs.kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#k8s-install-0) 

       
       sudo apt-get install -y apt-transport-https ca-certificates curl gpg
       sudo mkdir -m 755 /etc/apt/keyrings
       sudo curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
       echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
       sudo apt-get update
       sudo apt-get install -y kubelet kubeadm kubectl
       sudo apt-mark hold kubelet kubeadm kubectl

Once the nodes are ready, then proceed with the cluster creation. 

### Create a Cluster using Kubeadm.

1. Initialize the **control-plane node** using the following command. 
   ```bash
   sudo kubeadm init --apiserver-advertise-address=<control-plane node IP> --pod-network-cidr=10.244.0.0/16
   ```
   Relavent command traces example:
  <details>
      <summary>Expected kubeadm init traces:</summary>
      
    ~$sudo kubeadm init --apiserver-advertise-address=10.100.10.49 --pod-network-cidr=10.244.0.0/16
    I1222 22:10:17.798326    4010 version.go:256] remote version is much newer: v1.29.0; falling back to: stable-1.28
    [init] Using Kubernetes version: v1.28.5
    [preflight] Running pre-flight checks
    [preflight] Pulling images required for setting up a Kubernetes cluster
    [preflight] This might take a minute or two, depending on the speed of your internet connection
    [preflight] You can also perform this action in beforehand using 'kubeadm config images pull'
    W1222 22:10:56.628882    4010 checks.go:835] detected that the sandbox image "registry.k8s.io/pause:3.6" of the container runtime is inconsistent with that used by kubeadm. It is recommended that using "registry.k8s.io/pause:3.9" as the CRI sandbox image.
    [certs] Using certificateDir folder "/etc/kubernetes/pki"
    [certs] Generating "ca" certificate and key
    [certs] Generating "apiserver" certificate and key
    [certs] apiserver serving cert is signed for DNS names [kube-master kubernetes kubernetes.default kubernetes.default.svc kubernetes.default.svc.cluster.local] and IPs [10.96.0.1 10.100.10.49]
    [certs] Generating "apiserver-kubelet-client" certificate and key
    [certs] Generating "front-proxy-ca" certificate and key
    [certs] Generating "front-proxy-client" certificate and key
    [certs] Generating "etcd/ca" certificate and key
    [certs] Generating "etcd/server" certificate and key
    [certs] etcd/server serving cert is signed for DNS names [kube-master localhost] and IPs [10.100.10.49 127.0.0.1 ::1]
    [certs] Generating "etcd/peer" certificate and key
    [certs] etcd/peer serving cert is signed for DNS names [kube-master localhost] and IPs [10.100.10.49 127.0.0.1 ::1]
    [certs] Generating "etcd/healthcheck-client" certificate and key
    [certs] Generating "apiserver-etcd-client" certificate and key
    [certs] Generating "sa" key and public key
    [kubeconfig] Using kubeconfig folder "/etc/kubernetes"
    [kubeconfig] Writing "admin.conf" kubeconfig file
    [kubeconfig] Writing "kubelet.conf" kubeconfig file
    [kubeconfig] Writing "controller-manager.conf" kubeconfig file
    [kubeconfig] Writing "scheduler.conf" kubeconfig file
    [etcd] Creating static Pod manifest for local etcd in "/etc/kubernetes/manifests"
    [control-plane] Using manifest folder "/etc/kubernetes/manifests"
    [control-plane] Creating static Pod manifest for "kube-apiserver"
    [control-plane] Creating static Pod manifest for "kube-controller-manager"
    [control-plane] Creating static Pod manifest for "kube-scheduler"
    [kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
    [kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
    [kubelet-start] Starting the kubelet
    [wait-control-plane] Waiting for the kubelet to boot up the control plane as static Pods from directory "/etc/kubernetes/manifests". This can take up to 4m0s
    debug2: channel 0: window 999356 sent adjust 49220
    [apiclient] All control plane components are healthy after 29.560158 seconds
    [upload-config] Storing the configuration used in ConfigMap "kubeadm-config" in the "kube-system" Namespace
    [kubelet] Creating a ConfigMap "kubelet-config" in namespace kube-system with the configuration for the kubelets in the cluster
    [upload-certs] Skipping phase. Please see --upload-certs
    [mark-control-plane] Marking the node kube-master as control-plane by adding the labels: [node-role.kubernetes.io/control-plane node.kubernetes.io/exclude-from-external-load-balancers]
    [mark-control-plane] Marking the node kube-master as control-plane by adding the taints [node-role.kubernetes.io/control-plane:NoSchedule]
    [bootstrap-token] Using token: 9p9hho.hsb5sogk1nik4q7j
    [bootstrap-token] Configuring bootstrap tokens, cluster-info ConfigMap, RBAC Roles
    [bootstrap-token] Configured RBAC rules to allow Node Bootstrap tokens to get nodes
    [bootstrap-token] Configured RBAC rules to allow Node Bootstrap tokens to post CSRs in order for nodes to get long term certificate credentials
    [bootstrap-token] Configured RBAC rules to allow the csrapprover controller automatically approve CSRs from a Node Bootstrap Token
    [bootstrap-token] Configured RBAC rules to allow certificate rotation for all node client certificates in the cluster
    [bootstrap-token] Creating the "cluster-info" ConfigMap in the "kube-public" namespace
    [kubelet-finalize] Updating "/etc/kubernetes/kubelet.conf" to point to a rotatable kubelet client certificate and key
    [addons] Applied essential addon: CoreDNS
    [addons] Applied essential addon: kube-proxy

    Your Kubernetes control-plane has initialized successfully!

    To start using your cluster, you need to run the following as a regular user:

      mkdir -p $HOME/.kube
      sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
      sudo chown $(id -u):$(id -g) $HOME/.kube/config

    Alternatively, if you are the root user, you can run:

      export KUBECONFIG=/etc/kubernetes/admin.conf

    You should now deploy a pod network to the cluster.
    Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
      https://kubernetes.io/docs/concepts/cluster-administration/addons/

    Then you can join any number of worker nodes by running the following on each as root:

    kubeadm join 10.100.10.49:6443 --token dw2sis.hijjzfih6o3q8eoj \
            --discovery-token-ca-cert-hash sha256:bb53242c675615ba7d4f047865369ff6f1811ca6bbf9e5fed8e73b444519637f
  
  </details> 

2. As instructed we have to add the following commands. 

   ```bash
   mkdir -p $HOME/.kube
   sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
   sudo chown $(id -u):$(id -g) $HOME/.kube/config
   ```


## Pod network Installation. 

This pod network installation to make sure the pods can communicate with each other. Cluster DNS (CoreDNS) will not start up before a network is installed.
We can use the followng command to install the pod network add-on

`kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml`

  
  <details>
      <summary>Expected Flannel pod status:</summary>
      
        kubeuser@kube-master:~$ kubectl get pods --all-namespaces
        NAMESPACE      NAME                                  READY   STATUS    RESTARTS     AGE
        kube-flannel   kube-flannel-ds-grgbv                 1/1     Running   0            77m
        kube-flannel   kube-flannel-ds-m8rld                 1/1     Running   4 (8h ago)   44h
        kube-flannel   kube-flannel-ds-wf8kb                 1/1     Running   4 (8h ago)   44h
        kube-system    coredns-5dd5756b68-lvr54              1/1     Running   3 (8h ago)   44h
        kube-system    coredns-5dd5756b68-pf6zv              1/1     Running   3 (8h ago)   44h
        kube-system    etcd-kube-master                      1/1     Running   5 (8h ago)   44h
        kube-system    kube-apiserver-kube-master            1/1     Running   5 (8h ago)   44h
        kube-system    kube-controller-manager-kube-master   1/1     Running   4 (8h ago)   44h
        kube-system    kube-proxy-7ndfb                      1/1     Running   3 (8h ago)   44h
        kube-system    kube-proxy-hcwjr                      1/1     Running   3 (8h ago)   44h
        kube-system    kube-proxy-qwl79                      1/1     Running   0            77m
        kube-system    kube-scheduler-kube-master            1/1     Running   5 (8h ago)   44h
  </details> 

Once the control pod is ready them proceed with ading the worker nodes. 

## Adding the worker nodes
  Using the below command to add the worker node to the cluster, in the worker nodes all the pods and the container will be running. 

  `kubeadm join --token <token> <control-plane-host>:<control-plane-port> --discovery-token-ca-cert-hash sha256:<hash>`

   <details>
      <summary>Example join command traces:</summary>
     
      kubeuser@kube01:~$ sudo kubeadm join 10.100.10.49:6443 --token dw2sis.hijjzfih6o3q8eoj \
      >         --discovery-token-ca-cert-hash sha256:bb53242c675615ba7d4f047865369ff6f1811ca6bbf9e5fed8e73b444519637f
      [preflight] Running pre-flight checks
      [preflight] Reading configuration from the cluster...
      [preflight] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -o yaml'
      [kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
      [kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
      [kubelet-start] Starting the kubelet
      [kubelet-start] Waiting for the kubelet to perform the TLS Bootstrap...
      
      This node has joined the cluster:
      * Certificate signing request was sent to apiserver and a response was received.
      * The Kubelet was informed of the new secure connection details.
      
      Run 'kubectl get nodes' on the control-plane to see this node join the cluster.	
  </details> 

  Cluster status after adding the worker node: 
   
   ```bash
      kubeuser@kube-master:~$ kubectl get nodes
      NAME          STATUS   ROLES           AGE   VERSION
      kube-master   Ready    control-plane   44h   v1.28.2
      kube-node02   Ready    <none>          89m   v1.28.5
      kube01        Ready    <none>          44h   v1.28.2
   ```

We are all set we can now deploy the different kind's in the K8 cluster. 


      
