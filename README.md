# Kubernetes Fundamentals

These are my notes from the Kubernetes Fundamentals training from The Linux Foundation

## Chapter 1

`¯\_(ツ)_/¯`

## Chapter 2

**Kubernetes**: An open-source system for automating deployment, scaling and management of containerized applications.
*source: kubernetes.io*

Built from the Google project **Borg**.

Kubernetes is all about decoupled and transient services. **Decoupling** means that everything has been designed to not require anything else in particular. **Transient** means that the whole system expects various components to be terminated and replaced. A **flexible** and **scalable** environment means to have a framework that does not tie itself from one aspect to the next, and expect objects to die and to reconnect to their replacements.

Kubernetes deploy a large number of microservices. Other parties (internal or external to K8s) expect that there are many possible microservices available to respond a request, to die and be replaced.

The communication between components is API call-driven. It's stored in JSON but written in YAML. K8s convert from YAML to JSON prior store it in the DB.

Other solutions to Kubernetes are:

* Docker Swarm
* Apache Mesos
* Nomad
* Rancher: Container orchestrator-agnostic system. Supports Mesos, Swarm and Kubernetes.

**Kubernetes Architecture:**

![Kubernetes Architecture](./images/02-01-Kubernetes Architecture.png)

Kubernetes is made of a central manager (master) and some worker nodes, although both can run in a single machine or node. The manager runs an API server (`kube-apiserver`), a scheduler (`kube-scheduler`), controllers and a storage system (`etcd`).

Kubernetes exposes an API which could be accessible with `kubectl` or your own client. The scheduler sees the requests for running containers coming to the API and find a node to run that container in. Each node runs a `kubelet` and a proxy (`kube-proxy`). Kubelet receives requests tu run containers, manage resources and watches over them in the local node. The proxy creates and manage networking rules to expose the container on the network.

A **Pod** consist of one or more containers which share an IP address, access to storage and namespace. A container in a pod runs an application, and the secondary containers supports such application.

Orchestration is managed though a series of watch-loops, or **controllers** that check with the <u>API server</u> for a particular object state, modifying the object until declares the desired state.

A **Deployment** is a controller that ensures that resources are available, and then deploys a ReplicaSet. The **ReplicaSet** is a controller which deploys and restart containers until the requested number of containers running. The ReplicationController was deprecated and replaced by Deployment.

There is also **Jobs** and **CronJobs** controllers to handle single or recurring tasks.

**Labels** are strings part of the object metadata used to manage the Pods, they can be used to check or changing the state of objects without having to know the name or UID. Nodes can have **taints** to discourage Pod assignment, unless the Pod has a **toleration** in the metadata.

There is also **annotations** in metadata which is information used by third-party agents or tools.

Tools:

* **Minikube** which runs with **VirtualBox** to have a local Kubernetes cluster
* `kubeadm`
* `kubectl`
* **Helm**
* charts
* **Kompose**: translate Docker Compose files into Kubernetes manifests

[Lab 2.1](https://lms.quickstart.com/custom/858487/LAB_2.1.pdf): View Online Resources

## Chapter 3

To configure and manage the cluster we'll use `kubectl`.  This command use `~/.kube/config` as configuration file with all the Kubernetes endpoints that you might use.

A **context** is a combination of a cluster and user credentials. To switch between contexts or cluster use the command:

```bash
kubectl config use-context NAME
```

Using **Google Kubernetes Engine** (**GKE**) requires to install Could SDK, the instructions are [here](https://cloud.google.com/sdk/install). Then follow the [Quickstart Guide](https://cloud.google.com/kubernetes-engine/docs/quickstart) to create a Kubernetes cluster and delete ir when not need it.

```bash
gcloud container clusters create NAME
gcloud container clusters list
kubectl get nodes
...
gcloud container clusters delete NAME
```

Using **Minikube** requires to download/install minikube (i.e. use `brew`) then start Kubernetes executing:

```bash
minikube start
kubectl get nodes
```

This will start a VM with a single node Kubernetes cluster and the Docker engine.

Installing with **`kubeadm`** is another option, the instructions are [here](https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/). Packages are available for Ubuntu and CentOS.

Run `kubeadm init` on the master node, that will return a token. On the worker node execute `kubeadm join --token TOKEN MASTER-IP`. This will create a network for IP-per-Pod criteria but you can use `kubectl` to apply a resource manifest of a different network. For example, a Weave network:

```bash
kubectl create -f https://git.io/weave-kube
```

Installing a Pod Network may be the next step, there are several to choose:

* **Calico**: A flat layer 3 network which communicate without IP encapsulation. It's used in production, It's a simple and flexible networking model, scales well for large environments. It supports Network Policies
* **Canal**: Is part of the Calico project. Allows integration with Flannel and implementation of Network Policies. It has the best of Calico and Flannel.
* **Flannel**: A layer 3 IPv4 network between nodes. Focused on traffic between hosts, not containers, can use one of several backend mechanisms such as VXLAN. There is a `flanneld` agent on each node to allocate subnet leases for the host. It's easier to deploy it prior any Pod. While it's easier to deploy and supports a wide range of architectures, it does not support the use of Network Policies.
* **Kube-router**: A single binary to "do it all". At this time it's in alpha stage.
* **Romana**: aimed at network and security automation, large clusters, IPAM-aware topology and integration with `kops`
* **Weave Net**: Add-on for CNI-enabled clusters.

**CNI**: Container Network Interface, which is a CNCF project. Several containers runtime use CNI.

The selection of the Pod Network for **CNI** depends of the expected demand on the cluster. There can be only one Pod Network per cluster (**CNI-Genie** is working on change this). The network must allow container-to-container, pod-to-pod, pod-to-service, and external-to-service communications. Docker use host-private networking, so using <u>docker0</u> and <u>veth</u> requires to be on that host to communicate.

Other tools to install Kubernetes:

* **`kubespary`** : Ansible playbook to setup Kubernetes on various OS. Once known as kargo.
* **`kops`**: creates a Kubernetes cluster on AWS, in beta for GKE and alpha for VMware
* **`kube-aws`**: creates a Kubernetes cluster on AWS using Cloud Formation.
* **`kubicorn`**: leverages the use of `kubeadm` to build a cluster.

The best way to learn how to install Kubernetes using the manual commands is the [kelsey hightower walkthorugh](https://github.com/kelseyhightower/kubernetes-the-hard-way) and [kubernetes the hard way](https://github.com/kelseyhightower/kubernetes-the-hard-way).

The article [Picking the Right Solution](https://kubernetes.io/docs/setup/pick-right-solution/) helps to choose the best option.

On Linux, Kubernetes components may be running as **systemd** unit files, or run via a kubelet running on the master node (i.e. kubeadm).

There are 4 main deployment configurations:

1. **Single-node**: All components on same server. Good for testing, learning and developing.
2. **Single master node, multiple workers**: It's an etcd instance running on the master node with the API, scheduler and controller manager.
3. **Multiple master nodes with HA, multiple workers**: Adds more durability to te cluster. There is a Load Balancer in front of the API server, the scheduler and the controller manager. The etcd can still be single mode.
4. **HA etcd, HA master nodes, multiple workers**: Most advance and resilient setup. The etcd runs as a true cluster, providing HA and runs on nodes separate from Kubernetes master nodes.

The use of Kubernetes Federation also offers HA.

For any configuration, it's required some components as **systemd**. This is an example for controller-manager:

```yaml
- name: kube-controller-manager.service
    command: start
    content: |
      [Unit]
      Description=Kubernetes Controller Manager
      Documentation=https://github.com/kubernetes/kubernetes
      Requires=kube-apiserver.service
      After=kube-apiserver.service
      [Service]
      ExecStartPre=/usr/bin/curl -L -o /opt/bin/kube-controller-manager -z /opt/bin/kube-controller-manager https://storage.googleapis.com/kubernetes-release/release/v1.7.6/bin/linux/amd64/kube-controller-manager
      ExecStartPre=/usr/bin/systemd +x /opt/bin/kube-controller-manager
      ExecStart=/opt/bin/kube-controller-manager \
      --service-account-private-key-file=/opt/bin/kube-serviceaccount.key \
      --root-ca-file=/var/run/kubernetes/apiserver.crt \
      --master=127.0.0.1:8080 \
      --logtostderr=true
      Restart=always
      RestartSec=10
```

This is not a perfect unit file, it downloads the controller binary and set the permissions to run. Every component is highly configurable.

Other option is to run the components as containers, this is what `kubeadm` does. There is a binary named **hyperkube** also available as a container image **gcr.io/google_containers/hyperkube**.

This method runs **kubelet** as a system daemon and configure it with a manifest specifying how to run the other components. The **kubelet** will manage them as pods, making sure they get restarted if they die.

To get help usage executing:

```bash
docker run --rm gcr.io/google_containers/hyperkube:v1.9.2 /hyperkube apiserver --help
docker run --rm gcr.io/google_containers/hyperkube:v1.9.2 /hyperkube scheduler --help
docker run --rm gcr.io/google_containers/hyperkube:v1.9.2 /hyperkube controller-manager --help
```

To compile Kubernetes from source, get the repository and build it with `make`. You need Go or Docker installed.

```bash
cd $GOPATH
git clone https://github.com/kubernetes/kubernetes
cd kubernetes
make
```

With Docker, execute `make quick-release` instead of the bare make above.

The `_output/bin` directory will contain all the built binaries.

[Lab 3.1](https://lms.quickstart.com/custom/858487/LAB_3.1.pdf): Install Kubernetes

**Solution**:

Create a `Vagrantfile` with the following content:

```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/bionic64"
  config.vm.network "forwarded_port", guest: 6443, host: 6443
  config.vm.hostname = "master"
  config.vm.network "private_network", ip: "10.0.0.10"
  config.vm.synced_folder "./shared_folder", "/home/vagrant/shared_folder"
  config.vm.provision "shell", inline: <<-SHELL
    # add the provisioning script here
  SHELL
end
```

The `forwarded_port` is to allow the access from the guest host, your computer, to the cluster using `kubectl`. The master IP is static and private, so there is no access to the node from outside the network. We used the shared folder to store the kubeconfig file, required to access the cluster with `kubectl`.

The vagrant provisioning script on the master node is about installing all the dependencies and install Kubernetes by **kubeadm**.

1. Install dependencies script:

```bash
# Upgrading system and installing dependencies
apt-get update && apt-get install -y apt-transport-https curl
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
apt-get update && apt-get upgrade -y

# Installing Docker, kubeadm, kubelet, kubectl and Kubernetes CNI
apt-get update
apt-get install -y \
  docker.io \
  kubeadm=1.11.1-00 \
  kubelet=1.11.1-00 \
  kubectl=1.11.1-00 \
  kubernetes-cni=0.6.0-00
apt-mark hold docker.io kubelet kubeadm kubectl kubernetes-cni
swapoff -a
systemctl enable docker.service
```

The script is going to install the latest supported version of Docker, and the version `1.11` of kubeadm, kubelet and kubectl, the Kubernetes CNI version that works with them is `0.6.0-00`. It's important to use these versions, otherwise select the version of OS and Calico manifest that works with them (and maybe, modify the instructions)

2. Script to install Kubernetes by **kubeadmin**:

```bash
# Installing Kubernetes by kubeadmin
kubeadm init \
  --pod-network-cidr 192.168.0.0/16 \
  --apiserver-advertise-address=10.0.0.10 \
  --apiserver-cert-extra-sans=localhost

# Installing Canal
kubectl apply -f https://docs.projectcalico.org/v3.1/getting-started/kubernetes/installation/hosted/canal/rbac.yaml --kubeconfig /etc/kubernetes/admin.conf
kubectl apply -f https://docs.projectcalico.org/v3.1/getting-started/kubernetes/installation/hosted/canal/canal.yaml --kubeconfig /etc/kubernetes/admin.conf

# Only in non-production environments:
kubectl taint nodes --all node-role.kubernetes.io/master- --kubeconfig /etc/kubernetes/admin.conf

# Share kubeconfig and copy it for user 'vagrant'
cp /etc/kubernetes/admin.conf /home/vagrant/shared_folder/config
sed 's/10.0.0.10/localhost/' /etc/kubernetes/admin.conf > /home/vagrant/shared_folder/remote_config
mkdir -p /home/vagrant/.kube
cp /home/vagrant/shared_folder/config /home/vagrant/.kube/
chown vagrant:vagrant -R /home/vagrant/.kube
```

The command `kubeadm init` will install and configure Kubernetes, it's important to use the network CIDR `192.168.0.0/16` because it's the same used by Calico. Also `localhost` is used to generate the certificates to make it possible to access the cluster API from the guest machine. The `remote_config` file is the same as the original kubeconfig just replacing the master IP for `localhost`.

This solution install Canal but it could also install Calico if you replace those 2 lines for:

```bash
kubectl apply -f https://docs.projectcalico.org/v2.6/getting-started/kubernetes/installation/hosted/kubeadm/1.6/calico.yaml
```

This uses version 2.6 because latest versions (v3.1 & v3.2) were failing.

Insert the above provisioning script and execute `vagrant up`. The `Vagrantfile` will download and create an Ubuntu VM, then will install Kubernetes.

Using the file `shared_folder/remote_config` as kubeconfig file, execute the following commands to validate the cluster:

```bash
export KUBECONFIG=shared_folder/remote_config
kubectl get nodes
node_name=$(kubectl get node -o jsonpath='{.items[*].status.addresses[?(@.type=="Hostname")].address}')
kubectl describe node $node_name
kubectl describe node $node_name | grep -i taint
kubectl get pods --all-namespaces
```

There should be one node in the cluster (master) and all the pods should be running.

[Lab 3.2](https://lms.quickstart.com/custom/858487/LAB_3.2.pdf) Grow the Cluster

**Solution**:

Execute `vagrant destroy` to destroy the VM's and the cluster.

Modify the Vagrantfile to define the master and the worker nodes. In the master provisioning script, get the node ip address, kubeadm token and token hash to save them in the shared folder:

```bash
token=$(kubeadm token list | tail -2 | head -1 | cut -f1 -d' ')
token_ca_cert=$(openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //')

echo $token > /home/vagrant/shared_folder/token
echo $token_ca_cert > /home/vagrant/shared_folder/token_ca_cert.hash
```

The token and the token certificate hash are required by `kubeadm join` to join the worker to the cluster. Only the master node knows these 2, so they are saved into the shared directory to be accessible by the worker(s).

Also, assign to `kubelet` the correct node IP address and restart the daemon:

```bash
echo "KUBELET_EXTRA_ARGS=--node-ip='${IP}'" >/etc/default/kubelet
systemctl daemon-reload
systemctl restart kubelet
```

This workaround is to fix a kubeadm issue/feature #203, it assign to the node the first IP found. This first IP is the same on every vagrant node (*10.0.2.15*), therefore calico failed to start up because both nodes have the same IP address.

Now for the worker provisioner repeat the same instructions as in the master and the following script:

```bash
token=$(cat /home/vagrant/shared_folder/token)
token_ca_cert=$(cat /home/vagrant/shared_folder/token_ca_cert.hash)

# Adding Worker to Master running on https://10.0.0.10:6443
kubeadm join \
  --token $token \
  --discovery-token-ca-cert-hash sha256:$token_ca_cert \
  10.0.0.10:6443
```

The final and easily customizable Vagrantfile is located at `Solutions/Lab_03/Vagrantfile`.

To create the cluster execute `vagrant up` or you may startup the cluster one node at a time with:

```bash
vagrant up master
vagrant up worker
```

Verify the cluster health executing the same instructions as for the previous lab (Lab 3.1)

Some of the pages used to solve this Lab are:

* **Another Kubernetes the hard way**: https://github.com/kinvolk/kubernetes-the-hard-way-vagrant
* **Kubeadm playground**: https://github.com/kubernetes/kubeadm/tree/master/vagrant
* **Another playground**: https://github.com/davidkbainbridge/k8s-playground
* **Kubeadm issue #203**: https://github.com/kubernetes/kubeadm/issues/203

To destroy the cluster, execute:

```bash
vagrant destroy
```

And to cleanup everything, execute:

```bash
rm shared_folder/*
rm *.log
rm -rf .vagrant/
vagrant box remove ubuntu/bionic64 --all
```

Lab 3.2: [Deploy A Simple Application](https://lms.quickstart.com/custom/858487/LAB_3.3.pdf)

A **deployment** is an Kubernetes object that deploy and monitor an application in a container.

Execute the following commands to deploy a nginx web server:

```bash
kubectl run nginx --image nginx
kubectl get deployments
kubectl describe deployment nginx
kubectl get events
kubectl get deployment nginx -o yaml
kubectl get deployment nginx -o yaml > nginx.yaml
kubectl delete deployment nginx
```

Edit `nginx.yaml` to remove the `creationTimestamp`, `resourceVersion`, `selfLink`, `uid` and `status:` lines.

Deploy again the nginx but this time using a manifest file with the deployment object:

```bash
kubectl create -f nginx.yaml
kubectl get deployment nginx -o yaml > temp_nginx.yaml
diff nginx.yaml temp_nginx.yaml
```

Another way to generate the manifest without pre-deploying it is:

```bash
kubectl run nginx --image=nginx --dry-run -o yaml
kubectl get deployments
```

And one more, from an existing deployed object but this time there is no need to edit the file:

```bash
kubectl get deployments nginx --export -o yaml
```

You can get the manifest file in JSON format using `-o json`.

The container in the deployed pods are running but are not accessible from outside the cluster. To view the nginx default web page, you need to create a **service** using either the command `expose` or modifying the manifest file. Executing `kubectl expose deployment/nginx` will throw an error because the `--port` flag is not used. So we either modify the manifest file adding the 3 lines to define the `ports` at the `image:` section, and then use the `replace` command to apply the change, like this:

```yaml
containers:
- image: nginx
  imagePullPolicy: Always
  name: nginx
  ports:
  - containerPort: 80
    protocol: TCP
```

Then: `kubectl replace -f nginx.yaml`

Here we used the `replace` command because the container was create with the `create` sub-command. The best way from the very beginning was to use the sub-command `apply` so this is the only command to use when we have to update the deployment. Like this: `kubectl apply -f nginx.yaml`

To verify the change, execute:

```bash
kubectl get deploy,pod
kubectl get svc nginx   # or: kubectl get services nginx
kubectl get ep nginx    # or: kubectl get endpoints nginx
```

Running the `expose` subcommand now won't throw any error. And, notice that the **Cluster IP** from the service is not the node IP neither the pod endpoint IP

To know in which node the pod is running on use one of the following commands:

```bash
kubectl get pods -o wide | grep nginx
kubectl get pods -o jsonpath='{.items[*].spec.nodeName}'
kubectl describe pod nginx-UUID | grep 'Node:'
```

~~And to watch the traffic going back and forward on that container, login into the node where the pod is running to use the command `tcpdump` on the `tun10` interface: `sudo tcpdump -i tunl0`~~

Now use `curl` to access the pod endpoint ~~and see all the messages going back and forth~~, but as the endpoint IP of the pod is not accessible from the guest computer, the curl has to be executed from the node where it's running.

```bash
ip=$(kubectl get ep nginx -o jsonpath='{.subsets[0].addresses[0].ip}')
vagrant ssh worker -c "curl http://${ip}:80"
```

To scale up the number of nginx servers running, increase the number of **replicas** of the deployment with:

```bash
kubectl get deployment nginx
kubectl scale deployment nginx --replicas=3
kubectl get deployment nginx
kubectl get pods
```

And the number of endpoint addresses have also increased, one per replica:

```bash
kubectl get endpoints nginx
ip_addresses=$(kubectl get ep nginx -o jsonpath='{.subsets[0].addresses[*].ip}')
for ip in ip_addresses; do
  echo "getting http://$ip:80"
  vagrant ssh worker -c "curl http://${ip}:80"
done
```

Using the endpoint address is not good nor practical as they will change every time the pod is restored. List the pods and delete one of them, then watch how a new one takes its place and the endpoint change:

```bash
kubectl get pods -o wide
pod=$(kubectl get po -o wide | tail -1 | awk '{print $1}')
kubectl delete pods ${pod}
kubectl get pods -o wide
kubectl get endpoints nginx
```

There is no need to get the new pod IP address to access the nginx web page, using the service IP or, in this case: Cluster IP, is enough and better. But, same as the endpoints, the Cluster IP is only accessible from within the cluster so use the `curl` command from any node of the cluster, i.e. the master node.

```bash
kubectl get services nginx
ip=$(kubectl get services nginx -o jsonpath='{.spec.clusterIP}')
port=$(kubectl get services nginx -o jsonpath='{.spec.ports[0].port}')
vagrant ssh master -c "curl http://${ip}:${port}"
```

To pause and resume, use the commands `vagrant halt` and `vagrant up`. Or, to destroy and partially cleanup execute:

```bash
vagrant destroy
rm *.yaml
rm *.log
rm shared_folder/*
```

## Sources

* **Certified Kubernetes Administrator (CKA)**:

  Program: https://www.cncf.io/certification/cka/

  Handbook: https://www.cncf.io/certification/candidate-handbook

  Curriculum: https://github.com/cncf/curriculum/raw/master/certified_kubernetes_administrator_exam_v1.9.0.pdf

  Github: https://github.com/cncf/curriculum

  Exam Tips: https://www.cncf.io/certification/tips

* **Kubernetes Fundamental Labs**: https://lms.quickstart.com/custom/858487/LFS258-Labs_V2018-08-06.pdf

* **Kubernetes Fundamental Solutions**: https://training.linuxfoundation.org/cm/LFS258/

  Require credentials, use: `getsol.sh`

## TODO

* [ ] Review **Kompose**
* [ ] Read about **Canal**
* [x] Include **Canal** into the Vagrant project Lab 3
* [ ] Add more workers to the Vagrant project Lab 3
* [ ] Review **kubespary**
* [ ] Review **kubicorn**
