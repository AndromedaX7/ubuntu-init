echo "The script need root permission."

export TargetHome=$HOME

#sudo su
echo "change software sources"
sudo mv  /etc/apt/sources.list /etc/apt/sources.list.bak

sudo cat > $TargetHome/sources.list <<EOF
# deb cdrom:[Ubuntu 22.10 _Kinetic Kudu_ - Release amd64 (20221020)]/ kinetic main restricted

# See http://help.ubuntu.com/community/UpgradeNotes for how to upgrade to
# newer versions of the distribution.
deb https://mirrors.ustc.edu.cn/ubuntu/ kinetic main restricted
# deb-src http://cn.archive.ubuntu.com/ubuntu/ kinetic main restricted

## Major bug fix updates produced after the final release of the
## distribution.
deb https://mirrors.ustc.edu.cn/ubuntu/ kinetic-updates main restricted
# deb-src http://cn.archive.ubuntu.com/ubuntu/ kinetic-updates main restricted

## N.B. software from this repository is ENTIRELY UNSUPPORTED by the Ubuntu
## team. Also, please note that software in universe WILL NOT receive any
## review or updates from the Ubuntu security team.
deb https://mirrors.ustc.edu.cn/ubuntu/ kinetic universe
# deb-src http://cn.archive.ubuntu.com/ubuntu/ kinetic universe
deb https://mirrors.ustc.edu.cn/ubuntu/ kinetic-updates universe
# deb-src http://cn.archive.ubuntu.com/ubuntu/ kinetic-updates universe

## N.B. software from this repository is ENTIRELY UNSUPPORTED by the Ubuntu 
## team, and may not be under a free licence. Please satisfy yourself as to 
## your rights to use the software. Also, please note that software in 
## multiverse WILL NOT receive any review or updates from the Ubuntu
## security team.
deb https://mirrors.ustc.edu.cn/ubuntu/ kinetic multiverse
# deb-src http://cn.archive.ubuntu.com/ubuntu/ kinetic multiverse
deb https://mirrors.ustc.edu.cn/ubuntu/ kinetic-updates multiverse
# deb-src http://cn.archive.ubuntu.com/ubuntu/ kinetic-updates multiverse

## N.B. software from this repository may not have been tested as
## extensively as that contained in the main release, although it includes
## newer versions of some applications which may provide useful features.
## Also, please note that software in backports WILL NOT receive any review
## or updates from the Ubuntu security team.
deb https://mirrors.ustc.edu.cn/ubuntu/ kinetic-backports main restricted universe multiverse
# deb-src http://cn.archive.ubuntu.com/ubuntu/ kinetic-backports main restricted universe multiverse

deb https://mirrors.ustc.edu.cn/ubuntu/ kinetic-security main restricted
# deb-src http://security.ubuntu.com/ubuntu kinetic-security main restricted
deb https://mirrors.ustc.edu.cn/ubuntu/ kinetic-security universe
# deb-src http://security.ubuntu.com/ubuntu kinetic-security universe
deb https://mirrors.ustc.edu.cn/ubuntu/ kinetic-security multiverse
# deb-src http://security.ubuntu.com/ubuntu kinetic-security multiverse

# This system was installed using small removable media
# (e.g. netinst, live or single CD). The matching "deb cdrom"
# entries were disabled at the end of the installation process.
# For information about how to configure apt package sources,
# see the sources.list(5) manual.
deb https://mirrors.ustc.edu.cn/ubuntu/ kinetic-proposed multiverse main universe restricted
EOF

sudo cp $TargetHome/sources.list /etc/apt/sources.list
echo "update software"
sudo apt update -y
sudo apt upgrade -y 


echo "install based software."
sudo apt install git curl unzip wget fonts-wqy-microhei -y
echo "install rust."
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
echo "download Chrome:"
curl -o $TargetHome/Downloads/chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb

sudo dpkg -i  $TargetHome/Downloads/chrome.deb

echo "install libs"
sudo apt install libgtk-3-dev libfuse2 cmake make clang ninja-build virt-manager  openjdk-11-jdk -y
cd $TargetHome
git clone https://github.com/flutter/flutter

cat >> $TargetHome/.bashrc << EOF

export FLUTTER_HOME=\$HOME/flutter
export ANDROID_HOME=\$HOME/Android/Sdk
export PATH=\$ANDROID_HOME/platform-tools:\$FLUTTER_HOME/bin:\$PATH

export GTK_IM_MODULE=ibus
export XMODIFIERS=@im=ibus
export QT_IM_MODULE=ibus

EOF
echo "install wineHQ"
sudo dpkg --add-architecture i386 
mkdir -pm755 /etc/apt/keyrings
sudo wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key

sudo wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/kinetic/winehq-kinetic.sources
sudo apt update -y

sudo apt install --install-recommends winehq-stable  winetricks -y
 
echo "install docker" 
sudo apt-get update -y
sudo apt-get install -y  \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
    
sudo mkdir -p /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg |sudo  gpg --dearmor -o /etc/apt/keyrings/docker.gpg
 
sudo echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo  tee /etc/apt/sources.list.d/docker.list > /dev/null
 
sudo apt-get update -y
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y 

curl -o $TargetHome/Downloads/toolbox.tar.gz https://download-cdn.jetbrains.com/toolbox/jetbrains-toolbox-1.27.2.13801.tar.gz
tar -xvf $TargetHome/Downloads/toolbox.tar.gz 
$PWD/jetbrains-toolbox-1.27.2.13801/jetbrains-toolbox

sudo snap remove firefox
source $TargetHome/.bashrc

echo "install k8s"
sudo curl -fsSLo /etc/apt/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update -y
sudo apt-get install -y kubectl kubeadm kubelet 

sudo systemctl stop docker && sudo systemctl disable docker 

echo "==========================================================================="
echo "转发 IPv4 并让 iptables 看到桥接流量
执行下述指令：

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# 设置所需的 sysctl 参数，参数在重新启动后保持不变
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# 应用 sysctl 参数而不重新启动
sudo sysctl --system"
echo "==========================================================================="
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
sudo modprobe overlay
sudo modprobe br_netfilter

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sudo sysctl --system

lsmod | grep br_netfilter
lsmod | grep overlay
echo "==========================================================================="

echo "结合 runc 使用 systemd cgroup 驱动，在 /etc/containerd/config.toml 中设置：

[plugins.\"io.containerd.grpc.v1.cri\".containerd.runtimes.runc]
  ...
  [plugins.\"io.containerd.grpc.v1.cri\".containerd.runtimes.runc.options]
    SystemdCgroup = true"
echo "==========================================================================="
sudo containerd config default >  $TargetHome/config.toml 
sed -i "s/SystemdCgroup = false/SystemdCgroup = true/"  $TargetHome/config.toml 
sudo systemctl stop containerd
sudo cp $TargetHome/config.toml /etc/containerd/config.toml 
sudo systemctl daemon-reload
sudo systemctl start containerd



sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker

export nvidia="$(lspci | grep VGA | grep NVIDIA)"

if [ ${#nvidia} != 0 ];then
	sudo apt install nvidia-driver-525 -y
fi

sudo apt install qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils -y

sudo timedatectl set-local-rtc true
mv 28.jpg $TargetHome/Pictures/wrappaper.jpg
$TargetHome/flutter/bin/flutter doctor -v 
cd $TargetHome

pic_url=$TargetHome/Pictures/wrappaper.jpg
gsettings set org.gnome.desktop.background picture-uri $pic_url

echo "Dock...."
gsettings set org.gnome.shell.extensions.dash-to-dock show-mounts true
gsettings set org.gnome.shell.extensions.dash-to-dock show-mounts-network false
gsettings set org.gnome.shell.extensions.dash-to-dock show-mounts-only-mounted true
gsettings set org.gnome.shell.extensions.dash-to-dock show-trash true
echo " gsettings set org.gnome.shell.extensions.dash-to-dock autohide-in-fullscreen false"
gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 36

gsettings set org.gnome.shell.extensions.dash-to-dock dock-position BOTTOM


chmod a+x  ./Vimix-1080p/install.sh
cd Vimix-1080p
sudo ./install.sh
cd ..
echo "clean"
sudo apt autoremove -y

sudo rm -rfd $PWD/jetbrains-toolbox-1.27.2.13801
sudo rm -rf $PWD/sources.list
sudo rm -rf $PWD/config.toml
sudo rm -rf $PWD/ubuntu-init-software-sc.sh
sudo rm -rf $PWD/Vimix-1080p
sudo reboot



