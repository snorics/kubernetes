export DEBIAN_FRONTEND=noninteractive

echo "[TASK 1] show whoami"
whoami
systemctl disable --now ufw >/dev/null 2>&1

echo "[TASK 2] Stop and Disable firewall"
systemctl disable --now ufw >/dev/null 2>&1

echo "[TASK 3] Letting iptables see bridged traffic"
modprobe br_netfilter
modprobe overlay

echo "[TASK 4] Enable and Load Kernel modules"
cat >>/etc/modules-load.d/k8s.conf<<EOF
br_netfilter
overlay
EOF

echo "[TASK 5] Add Kernel settings"
cat >>/etc/sysctl.d/k8s.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward                 = 1
EOF
sysctl --system

echo "[TASK 6] Install docker"
apt-get update
apt-get install -y \
apt-transport-https \
ca-certificates \
curl \
gnupg \
lsb-release \
software-properties-common

export OS=xUbuntu_22.04
export CRIO_VERSION=1.24
echo "deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/ /"|sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list
echo "deb http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$CRIO_VERSION/$OS/ /"|sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable:cri-o:$CRIO_VERSION.list

curl -L https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable:cri-o:$CRIO_VERSION/$OS/Release.key | sudo apt-key add -
curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/Release.key | sudo apt-key add -
apt update

apt install -y cri-o cri-o-runc
systemctl start crio
systemctl enable crio

apt -y install containernetworking-plugins

cat > /etc/crio/crio.conf <<EOF
[crio.network]
network_dir = "/etc/cni/net.d/"
plugin_dirs = [
        "/opt/cni/bin/",
        "/usr/lib/cni/",
]
EOF

rm -f /etc/cni/net.d/100-crio-bridge.conf
curl -fsSLo /etc/cni/net.d/11-crio-ipv4-bridge.conf https://raw.githubusercontent.com/cri-o/cri-o/main/contrib/cni/11-crio-ipv4-bridge.conf
systemctl restart crio
apt install cri-tools
#crictl version
#crictl info
crictl completion > /etc/bash_completion.d/crictl
source ~/.bashrc

echo "[Task 6] Installing kubelet"
apt-get update && apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt-get update
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl



echo "[TASK 7] Installing dependencies"
