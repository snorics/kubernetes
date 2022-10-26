#!/bin/bash

echo "[TASK 1] Pull required containers"
kubeadm config images pull >/dev/null 2>&1

echo "[TASK 2] Initialize Kubernetes Cluster"
#kubeadm init --apiserver-advertise-address=172.16.16.100 --pod-network-cidr=192.168.0.0/16 >> /root/kubeinit.log 2>/dev/null
kubeadm init --pod-network-cidr 10.85.0.0/16 --apiserver-advertise-address=192.168.178.37 >> /root/kubeinit.log

echo "[TASK 3] Deploy Calico network"
#kubectl --kubeconfig=/etc/kubernetes/admin.conf create -f https://docs.projectcalico.org/v3.24.3/manifests/calico.yaml >/dev/null 2>&1
kubectl create -f https://projectcalico.docs.tigera.io/manifests/calico.yaml


# echo "[TASK 3] Deploy Weave network"
# kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"

echo "[TASK 4] Generate and save cluster join command to /joincluster.sh"
kubeadm token create --print-join-command > /joincluster.sh 2>/dev/null

echo "[TASK 5] Setup public key for workers to access master"
cat >>~/.ssh/authorized_keys<<EOF
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDVVswUXh11xbn8Wtuj0jZeEtCXGlbfU3eP9NKIAzjj5H3IgZxWGcbSvz+dBkUfP50CRjQx5v1k4vpe1DCx3K+nL2zidk6qotlKqGybnz9UHS61EGuKvxuDOwCwWMK1OEkmrjYdZVKgCn1qUMfI3UzIn0N9DVTFolLm/vjpSZ0NX9PLkzMbUv/MMO4GY6fk4O9Lo/cog9L5pvtGSl4ecFl3RJ+a/o3gWGLYWwJdV/2tpTps3/hh559nAVqdk0EPkFvJJklFhzjL4B5kpHsk2wvKGbgpca2PUmE6hVEljBivUfV7RCuFJB+0NVsJhO61TsErROt7h+2uJWhGwiP7YJTn vagrant@master01
EOF

echo "[TASK 6] Setup kubectl"
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

echo "[Task 7] Deploy Rook"
git clone --single-branch --branch master https://github.com/rook/rook.git
cd rook/deploy/examples
kubectl create -f crds.yaml -f common.yaml -f operator.yaml
kubectl create -f cluster.yaml
kubectl get pod -n rook-ceph

#/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
# brew install k9s

# curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
# chmod 700 get_helm.sh
# ./get_helm.sh


#kubectl apply -f rbd/storageclass.yaml
#kubectl apply -f ../filesystem.yaml
#kubectl apply -f cephfs/storageclass.yaml


#kubectl patch storageclass rook-ceph-block -p '{"metadata":{"annotations": {"storageclass.kubernetes.io/is-default-class": "true"}}}'


