1. Controlling your cluster from machines other than the control-plane node


    Copy the `admin.conf` the file from the `control-plane` to the local device . 
    
   ```bash
        scp /etc/kubernetes/admin.conf  monzu@10.10.10.1:~/
   ```
    
    Once the `admin.conf` file is copied, then we can use the respective file to access the kube cluster from the local machine. 
    
    ```bash
        monzu@dust:~$ kubectl --kubeconfig ./admin.conf get nodes
        NAME          STATUS   ROLES           AGE    VERSION
        kube-master   Ready    control-plane   45h    v1.28.2
        kube-node02   Ready    <none>          166m   v1.28.5
        kube01        Ready    <none>          45h    v1.28.2
    
        monzu@dust:~$ kubectl --kubeconfig ./admin.conf get pods
        NAME   READY   STATUS    RESTARTS   AGE
        demo   1/1     Running   0          54m
    
        monzu@dust:~$ kubectl --kubeconfig ./admin.conf delete  pods demo
        pod "demo" deleted
        monzu@dust:~$ 
    ```
