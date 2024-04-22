#!/bin/bash

echo ".........----------------#################._.-.-INSTALL-.-._.#################----------------........."
PS1='\[\e[01;36m\]\u\[\e[01;37m\]@\[\e[01;33m\]\H\[\e[01;37m\]:\[\e[01;32m\]\w\[\e[01;37m\]\$\[\033[0;37m\] '
echo "PS1='\[\e[01;36m\]\u\[\e[01;37m\]@\[\e[01;33m\]\H\[\e[01;37m\]:\[\e[01;32m\]\w\[\e[01;37m\]\$\[\033[0;37m\] '" >> ~/.bashrc
sed -i '1s/^/force_color_prompt=yes\n/' ~/.bashrc
source ~/.bashrc

# Don't ask to restart services after apt update, just do it.
[ -f /etc/needrestart/needrestart.conf ] && sed -i 's/#\$nrconf{restart} = \x27i\x27/$nrconf{restart} = \x27a\x27/' /etc/needrestart/needrestart.conf

apt-get autoremove -y  #removes the packages that are no longer needed
apt-get update
systemctl daemon-reload

KUBE_LATEST=$(curl -L -s https://dl.k8s.io/release/stable.txt | awk 'BEGIN { FS="." } { printf "%s.%s", $1, $2 }')
mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/${KUBE_LATEST}/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/${KUBE_LATEST}/deb/ /" >> /etc/apt/sources.list.d/kubernetes.list

apt-get update
KUBE_VERSION=$(apt-cache madison kubeadm | head -1 | awk '{print $3}')
apt-get install -y docker.io vim build-essential jq python3-pip kubelet kubectl kubernetes-cni kubeadm containerd
pip3 install jc

### UUID of VM
### comment below line if this Script is not executed on Cloud based VMs
jc dmidecode | jq .[1].values.uuid -r

systemctl enable kubelet

echo ".........----------------#################._.-.-KUBERNETES-.-._.#################----------------........."
rm -f /root/.kube/config
kubeadm reset -f

mkdir -p /etc/containerd
containerd config default | sed 's/SystemdCgroup = false/SystemdCgroup = true/' > /etc/containerd/config.toml
systemctl restart containerd

# uncomment below line if your host doesnt have minimum requirement of 2 CPU
# kubeadm init --pod-network-cidr '10.244.0.0/16' --service-cidr '10.96.0.0/16' --ignore-preflight-errors=NumCPU --skip-token-print
kubeadm init --pod-network-cidr '10.244.0.0/16' --service-cidr '10.96.0.0/16'  --skip-token-print

mkdir -p ~/.kube
cp -i /etc/kubernetes/admin.conf ~/.kube/config

kubectl apply -f "https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s-1.11.yaml"
kubectl rollout status daemonset weave-net -n kube-system --timeout=90s
sleep 5

echo "untaint controlplane node"
node=$(kubectl get nodes -o=jsonpath='{.items[0].metadata.name}')
for taint in $(kubectl get node $node -o jsonpath='{range .spec.taints[*]}{.key}{":"}{.effect}{"-"}{end}')
do
    kubectl taint node $node $taint
done
kubectl get nodes -o wide

echo ".........----------------#################._.-.-Docker-.-._.#################----------------........."

cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "storage-driver": "overlay2"
}
EOF
mkdir -p /etc/systemd/system/docker.service.d

systemctl daemon-reload
systemctl restart docker
systemctl enable docker


echo ".........----------------#################._.-.-Java and MAVEN-.-._.#################----------------........."
apt install openjdk-11-jdk maven -y
java -version
mvn -v

echo ".........----------------#################._.-.-JENKINS-.-._.#################----------------........."
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | gpg --dearmor -o /usr/share/keyrings/jenkins.gpg
echo 'deb [signed-by=/usr/share/keyrings/jenkins.gpg] http://pkg.jenkins.io/debian-stable binary/' > /etc/apt/sources.list.d/jenkins.list
apt update
apt install -y jenkins
systemctl daemon-reload
systemctl enable jenkins
systemctl start jenkins
usermod -a -G docker jenkins
echo "jenkins ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

echo ".........----------------#################._.-.-COMPLETED-.-._.#################----------------........."
