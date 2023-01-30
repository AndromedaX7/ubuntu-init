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
sudo apt install  unzip wget fonts-wqy-microhei -y

echo "Download nginx"
curl -o $TargetHome/Downloads/nginx-1.23.3.tar.gz https://nginx.org/download/nginx-1.23.3.tar.gz
tar -xvf $TargetHome/Downloads/nginx-1.23.3.tar.gz



echo "install jdk"
sudo apt install openjdk-8-jdk -y

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

sudo docker pull mysql:5.7
sudo docker pull redis

echo "clean"
sudo apt autoremove -y

sudo rm -rf $PWD/sources.list
sudo rm -rf $PWD/ubuntu-init-software-sc.sh
sudo reboot



