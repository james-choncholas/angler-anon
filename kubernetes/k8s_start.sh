#!/bin/bash
scriptpath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Install dependencies
[ ! -z "$(command -v curl)" ] || sudo apt-get install -y curl
[ ! -z "$(command -v htpasswd)" ] || sudo apt-get install -y apache2-utils
[ ! -z "$(command -v showmount)" ] || sudo apt-get install -y nfs-common
[ ! -z "$(command -v docker)" ] || bash <(curl -fsSL https://get.docker.com)
if [ -z "$(command -v kubectl)" ]; then
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add
    echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee --append /etc/apt/sources.list.d/kubernetes.list &>/dev/null
    sudo apt update
    sudo apt install -qy --allow-downgrades kubelet=1.19.2-00 kubeadm=1.19.2-00 kubectl=1.19.2-00
    sudo systemctl enable docker.service
fi

print_info() {
  echo -e "\033[33m$1\033[0m"
}

print_info "turn swap off"
sudo swapoff -a

# Cluster already running, dont stop, just exit
if sudo kubeadm config view &>/dev/null; then
    exit
    #source $scriptpath/k8s_stop.sh
fi

# Setup daemon
if [ ! -f /etc/docker/daemon.json ]; then
    sudo cat <<EOF | sudo tee /etc/docker/daemon.json 1>/dev/null
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF
    sudo mkdir -p /etc/systemd/system/docker.service.d
    #sudo journalctl -fu docker.service
    sudo systemctl daemon-reload && sudo systemctl restart docker.service
fi


print_info "start cluster..."
workerjoincmd=$(sudo kubeadm init --pod-network-cidr=10.244.0.0/16 | tail -n 2)
#workerjoincmd=$(sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=$myip | tail -n 2)

print_info "install fresh kube-config.."
mkdir -p $HOME/.kube
sudo \cp -f /etc/kubernetes/admin.conf $HOME/.kube/config
# fix any kubectl caching issues and chown .kube/config
# https://github.com/kubernetes/kubernetes/issues/59356
# https://groups.google.com/forum/#!topic/kubernetes-users/J34nmEt1NTw
sudo chown $(id -u):$(id -g) -R $HOME/.kube

print_info "start flannel CNI..."
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/k8s-manifests/kube-flannel-rbac.yml

#print_info "start weave-net CNI..."
#sudo sysctl net.bridge.bridge-nf-call-iptables=1
#kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"

# Start worker nodes
#while true; do
#    echo -e ""
#    read -p "Enter IP or FQDN of worker node (q to stop): " -r machine
#    [[ ! $machine =~ ^[Qq]$ ]] || break
#    read -p "user: " -r user
#
#ssh -p222 -tt $user@$machine "
#[ ! -z \"\$(command -v docker)\" ] || sudo bash <(curl -fsSL https://get.docker.com)
#[ ! -z \"\$(command -v showmount)\" ] || sudo apt-get install -y nfs-common
#if [ -z \"\$(command -v kubectl)\" ]; then
#    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add
#    echo \"deb http://apt.kubernetes.io/ kubernetes-xenial main\" | sudo tee --append /etc/apt/sources.list.d/kubernetes.list &>/dev/null
#    sudo apt update
#    sudo apt install -y kubelet kubeadm kubectl kubernetes-cni
#fi
#
## Stop old cluster
#if sudo kubeadm config view &>/dev/null; then
#    print_info \"stop old cluster...\"
#    echo -e \"y\n\" | sudo kubeadm reset #1>/dev/null
#    sudo rm -rf /etc/kubernetes
#    sudo rm -rf ~/.kube
#    print_info \"reset ip tables (DOES THIS AFFECT fail2ban??\"
#    sudo iptables -F && iptables -t nat -F && iptables -t mangle -F && iptables -X
#    sudo ipvsadm -C
#fi
#
#sudo mkdir -p /etc/systemd/system/docker.service.d
#
## Restart docker.
#sudo systemctl daemon-reload
#sudo systemctl restart docker
#echo \"y\" | sudo docker system prune
#echo \"y\" | sudo docker volume prune
#
#echo join cluster...
#sudo $workerjoincmd
#"
#done #done starting worker nodes

#print_info "waiting for CoreDNS to start"
#kubectl rollout status --namespace kube-system deployment coredns

print_info "allow scheduling on master node"
kubectl taint nodes --all node-role.kubernetes.io/master-

print_info "label master node"
kubectl label nodes $HOSTNAME dedicated=master

print_info "cluster nodes"
kubectl get nodes


