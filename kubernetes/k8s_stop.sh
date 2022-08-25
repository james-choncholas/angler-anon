#!/bin/bash

# drain node first
kubectl drain $(hostname) --delete-local-data --force --ignore-daemonsets
#kubectl delete node <node name>

echo "stopping cluster..."
echo -e "y\n" | sudo kubeadm reset
sudo rm -rf /etc/kubernetes
sudo rm -rf ~/.kube

#print_info "reset ip tables (DOES THIS AFFECT fail2ban??)"
#sudo iptables -F && iptables -t nat -F && iptables -t mangle -F && iptables -X # This breaks chameleon
#sudo ipvsadm -C

echo "y" | sudo docker system prune
echo "y" | sudo docker volume prune

