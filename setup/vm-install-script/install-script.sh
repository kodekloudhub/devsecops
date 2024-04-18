#!/bin/bash
set -e

echo ".........----------------#################._.-.-INSTALL-.-._.#################----------------........."
PS1='\[\e[01;36m\]\u\[\e[01;37m\]@\[\e[01;33m\]\H\[\e[01;37m\]:\[\e[01;32m\]\w\[\e[01;37m\]\$\[\033[0;37m\] '
echo "PS1='\[\e[01;36m\]\u\[\e[01;37m\]@\[\e[01;33m\]\H\[\e[01;37m\]:\[\e[01;32m\]\w\[\e[01;37m\]\$\[\033[0;37m\] '" >> ~/.bashrc
sed -i '1s/^/force_color_prompt=yes\n/' ~/.bashrc
source ~/.bashrc
export DEBIAN_FRONTEND=noninteractive 
apt-get autoremove -y  #removes the packages that are no longer needed
apt-get update
systemctl daemon-reload

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --batch --yes --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' >  /etc/apt/sources.list.d/kubernetes.list

sed -i 's/#$nrconf{restart} = '"'"'i'"'"';/$nrconf{restart} = '"'"'a'"'"';/g' /etc/needrestart/needrestart.conf | true
apt-get update
apt-get upgrade -y
apt-get install -y kubelet wget vim build-essential jq python3-pip kubectl runc kubernetes-cni kubeadm
apt-mark hold kubeadm kubectl kubelet
pip3 install jc

### UUID of VM 
### comment below line if this Script is not executed on Cloud based VMs
jc dmidecode | jq .[1].values.uuid -r

wget https://github.com/containerd/containerd/releases/download/v1.7.0/containerd-1.7.0-linux-amd64.tar.gz
tar Czxvf /usr/local containerd-1.7.0-linux-amd64.tar.gz
wget https://raw.githubusercontent.com/containerd/containerd/main/containerd.service
mkdir -p /usr/lib/systemd/system
mv containerd.service /usr/lib/systemd/system/
mkdir -p /etc/containerd/
containerd config default > /etc/containerd/config.toml
sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml
crictl config runtime-endpoint unix:///var/run/containerd/containerd.sock
echo "alias docker='crictl'" > /etc/profile.d/00-alises.sh
alias docker='crictl'
systemctl daemon-reload
systemctl enable --now containerd

systemctl enable kubelet
systemctl start kubelet

echo ".........----------------#################._.-.-KUBERNETES-.-._.#################----------------........."
rm /root/.kube/config | true
kubeadm reset -f
modprobe br_netfilter
sed -ir 's/#{1,}?net.ipv4.ip_forward ?= ?(0|1)/net.ipv4.ip_forward = 1/g' /etc/sysctl.conf
sysctl -w net.ipv4.ip_forward=1
sed -i '/ swap / s/^ (.*)$/#1/g' /etc/fstab
swapoff -a

# uncomment below line if your host doesnt have minimum requirement of 2 CPU
# kubeadm init --kubernetes-version=${KUBE_VERSION} --ignore-preflight-errors=NumCPU --skip-token-print
kubeadm init --kubernetes-version=${KUBE_VERSION} --skip-token-print

mkdir -p ~/.kube
cp -f /etc/kubernetes/admin.conf ~/.kube/config

kubectl apply -f "https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s-1.11.yaml"
echo "Waiting 60 seconds"
sleep 60

echo "untaint controlplane node"
kubectl taint nodes --all node-role.kubernetes.io/control-plane-
kubectl get node -o wide

echo 'source <(kubectl completion bash)' >> ~/.bashrc
source ~/.bashrc

echo ".........----------------#################._.-.-Java and MAVEN-.-._.#################----------------........."
mkdir -p /usr/share/man/man1
apt install openjdk-17-jdk -y
java -version
apt install -y maven
mvn -v

echo ".........----------------#################._.-.-JENKINS-.-._.#################----------------........."
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo apt-key add -
sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
apt update
apt install -y jenkins
systemctl daemon-reload
systemctl enable jenkins
systemctl start jenkins
systemctl status jenkins --no-pager
echo "jenkins ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

echo ".........----------------#################._.-.-COMPLETED-.-._.#################----------------........."
