## Kubernetes containerd lab
```
.----------------------------------------------------------------------.
| This is 3 node cluster contains 1 control plane and 2 compute nodes. |
| Lab using containerd as containerization engine. I would like show   |
| You are not forced to use docker only!                               | 
'----------------------------------------------------------------------'
```

## Kubernetes version
Currently I'm using 1.19.3. Version is provided as ansible varabile stored separately for master, 
workers in ansible playbook vars manifest file.

Feel free to change `version` if 1.19.3 does not satisfied your requirements.

## Avoiding Ansible installation
Due to fact that you may use different OS distribution for Vagrant host I decided
to use ansible_local provisioner instead of ansible. This approach let you avoid 
additional effort and save a lot of time in case of Ansible package installation.
Of curse on Linux this easy task but same thing is not so colorfull on Windows.
I would say it may be an nightmare ;-)  

## Requirements
Here will be short list about all requirements needed to run this environment.

+ Hardware:
  * 2 CPU
  * 6,5GB RAM
  * 60GB HDD (preferable SSD) this is thin provisioning depends on storage used.

+ Operating system:
  * Widnows 10 installed WSL 1 preferable Ubuntu 18.04 LTS or 20.04 LTS (available in Microsoft Store)
  * Ubuntu 18.04 LTS or 20.04 LTS
  * CentOS/RHEL 7/8 64 bit preferable

`Sorry I have no time to check Debian and Suse.`   

+ Packages:
  * vagrant 2.2.10 or higher (https://www.vagrantup.com/intro/getting-started/install.html)
  * git 1.8 or higher for Linux / 2.29.2 or higher for Windows  (https://pl.atlassian.com/git/tutorials/install-git)
  * VirtualBox 6.1 or higher (https://www.virtualbox.org/wiki/Downloads)

## Before you start
There are some prerequisite task which need to be completed before you start for example:
installing virtualbox, vagrant or if you are on Windows WSL1/2 or CygWin. I assume that you have
already installed and prepared everything to run. You don't need to install ansible cause I am
using embaded ansible provisioner.

I highly encurage you to use Ubuntu 18.0.4 or 20.04 LTS! It does not matter if ud is a direct installation
or not.

## Items

+ Host entries:

```
172.18.0.2   mk8s-master
172.18.0.10  mk8s-worker1
172.18.0.11  mk8s-worker2
```

`Don't need to be added to your /etc/hosts, in all cases we will use vagrant ssh command instead of standard ssh!`

+ Pods networking
```
Weavenet Networks
```

+ Kubernetes version
```
Kubernetes v1.19.3
```

+ containerD
```
containerd github.com/containerd/containerd 1.3.3-0ubuntu1~18.04.4
```

+ Operating system version
```
Ubuntu 18.04 LTS - Kubernetes control plane and compute nodes
```


## Clone repo
How to clone repo? I'm sending you to documentation: https://confluence.atlassian.com/bitbucket/clone-a-repository-223217891.html

Please use following link to clone repository:

https://github.com/super-jkdevops/mk8s-ContainerD-lab.git


In your home directory type:

```
git clone https://github.com/super-jkdevops/mk8s-ContainerD-lab.git kubernetes-vagrant-containerd
```

Move to "kubernetes-vagrant-containerd" directory:

```
cd kubernetes-vagrant-containerd
```

## Start vagrant machines
When repo will be on your station then you need to run only 1 command.
You should be in kubernetes-vagrant-containerd directory. If not please enter this directory

run:

Run provisioning scripts one shoot setup.

```
vagrant up
```

`
Please be patient this process can take a while usually depends on your hardware: disk speed, memory type,
cpu type and generation. 
`

You should see similar output:
```

```

It can take a while, up to 20 mins. Please be patient.

### Smoke test from master node:


vagrant ssh mk8s-master1

```
.--- k8s lab ---.
| Master Node 1 |
'---------------'
[vagrant@mk8s-master ~]$ hostname
mk8s-master
```


### Test if you can connect use names:

```
# ping -c 1 mk8s-master
PING mk8s-master (172.18.0.2) 56(84) bytes of data.
64 bytes from mk8s-master1 (172.18.0.2): icmp_seq=1 ttl=64 time=0.202 ms

--- mk8s-master1 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.202/0.202/0.202/0.000 ms

# ping -c 1 mk8s-worker1
PING k8s-worker1 (172.18.0.10) 56(84) bytes of data.
64 bytes from mk8s-worker1 (172.18.0.10): icmp_seq=1 ttl=64 time=0.256 ms

--- k8s-worker1 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.256/0.256/0.256/0.000 ms

$ ping -c 1 mk8s-worker2
PING mk8s-worker2 (172.18.0.11) 56(84) bytes of data.
64 bytes from mk8s-worker2 (172.18.0.11): icmp_seq=1 ttl=64 time=0.256 ms

--- mk8s-worker2 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.256/0.256/0.256/0.000 ms
```

You don't need to repeat this steps on other nodes cause it works on first master!

### List Kubernetes nodes
Kubectl binary has been installed only on master node. If you would like to use kubectl on your station you should install
it and copy configuration from .kubectl directory. Without kubectl you will be not able to check kubernetes status and
other cluster things.

On the master node: "mk8s-master" and vagrant user type:

```
kubectl get nodes -o wide
```

Then following output should be displayed:
```
NAME           STATUS   ROLES    AGE     VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION       CONTAINER-RUNTIME
mk8s-master    Ready    master   7m16s   v1.19.3   172.18.0.2    <none>        Ubuntu 18.04.5 LTS   4.15.0-128-generic   containerd://1.3.3
mk8s-worker1   Ready    <none>   2m3s    v1.19.3   172.18.0.10   <none>        Ubuntu 18.04.5 LTS   4.15.0-128-generic   containerd://1.3.3
mk8s-worker2   Ready    <none>   0m35s   v1.19.3   172.18.0.11   <none>        Ubuntu 18.04.5 LTS   4.15.0-128-generic   containerd://1.3.3
```

Please remember that you should see all nodes and masters as ready. If for some reason
nodes are unavailable please check kubelet logs.

### List Kubernetes cluster objects:
In this section we will check Kubernetes cluster in details. Thanks to this we will know if
all parts of cluster are ready for future operation/deployments etc.

#### Check Kubernetes cluster:"

Namespaces:
```
kubectl get namespaces
```

should return output:

```
NAME              STATUS   AGE
default           Active   45m
kube-node-lease   Active   45m
kube-public       Active   45m
kube-system       Active   45m
```


Pods in kube-system namespace:
```
kubectl -n kube-system get pods
```

You should see following output:

```
NAME                                  READY   STATUS    RESTARTS   AGE
coredns-f9fd979d6-7r7sc               1/1     Running   0          13m
coredns-f9fd979d6-hljv5               1/1     Running   0          13m
etcd-mk8s-master                      1/1     Running   0          14m
kube-apiserver-mk8s-master            1/1     Running   0          14m
kube-controller-manager-mk8s-master   1/1     Running   0          14m
kube-proxy-c6p45                      1/1     Running   0          3m49s
kube-proxy-kc892                      1/1     Running   0          9m4s
kube-proxy-xv2vr                      1/1     Running   0          13m
kube-scheduler-mk8s-master            1/1     Running   0          14m
weave-net-5phk2                       2/2     Running   1          9m4s
weave-net-b4sd5                       2/2     Running   1          13m
weave-net-p7wjh                       2/2     Running   1          3m49s
```

Deployments in kube-system namespace:
```
kubectl -n kube-system get deployments
```

Desired output:

```
NAME      READY   UP-TO-DATE   AVAILABLE   AGE
coredns   2/2     2            2           14
```

## Used technology:
- Ansible
- Kubernetes
- Vagrant
- Git
- Github

## Post installation steps
There is always good ida to have lab hosts in /etc/hosts file. It can be usefull in many cases 
(reach loadbalancer, check if ingress or application is running on the nodes and scheduled
properly).

If you are intrested please go as follow:

```
cat <<EOT >> /etc/hosts
172.18.0.2   mk8s-master
172.18.0.10  mk8s-worker1
172.18.0.11  mk8s-worker2
EOT
```