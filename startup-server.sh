echo "The script need root permission."

export TargetHome=$HOME

#sudo su
echo "change software sources"
sudo mv  /etc/apt/sources.list /etc/apt/sources.list.bak

sudo cat > $TargetHome/sources.list <<EOF
deb https://mirrors.ustc.edu.cn/ubuntu/ jammy main restricted universe multiverse
deb-src https://mirrors.ustc.edu.cn/ubuntu/ jammy main restricted universe multiverse

deb https://mirrors.ustc.edu.cn/ubuntu/ jammy-security main restricted universe multiverse
deb-src https://mirrors.ustc.edu.cn/ubuntu/ jammy-security main restricted universe multiverse

deb https://mirrors.ustc.edu.cn/ubuntu/ jammy-updates main restricted universe multiverse
deb-src https://mirrors.ustc.edu.cn/ubuntu/ jammy-updates main restricted universe multiverse

deb https://mirrors.ustc.edu.cn/ubuntu/ jammy-backports main restricted universe multiverse
deb-src https://mirrors.ustc.edu.cn/ubuntu/ jammy-backports main restricted universe multiverse

## Not recommended
# deb https://mirrors.ustc.edu.cn/ubuntu/ jammy-proposed main restricted universe multiverse
# deb-src https://mirrors.ustc.edu.cn/ubuntu/ jammy-proposed main restricted universe multiverse
EOF

sudo cp $TargetHome/sources.list /etc/apt/sources.list
echo "update software"
sudo apt update -y
sudo apt upgrade -y 


echo "install based software."
sudo apt install ssh unzip wget fonts-wqy-microhei -y

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

sudo mkdir -p /datastore/mysql
sudo cp -r $TargetHome/nginx-1.23.3 /datastore

cat  > README.md  << EOF
# Nginx
install dir: /datastore/nginx-1.23.3
EOF
export MYSQL_ROOT=/datastore/mysql

sudo mkdir -p $MYSQL_ROOT/conf
sudo mkdir -p $MYSQL_ROOT/logs
sudo mkdir -p $MYSQL_ROOT/data

sudo docker stop mysql57 && sudo docker rm mysql57
sudo docker run -dit -p 3306:3306 \
--name mysql57 --restart=always \
-e MYSQL_ROOT_PASSWORD=123456 \
-v $MYSQL_ROOT/conf:/etc/mysql/conf.d \
-v $MYSQL_ROOT/logs:/logs \
-v $MYSQL_ROOT/data:/var/lib/mysql \
mysql:5.7

cat >> README.md << EOF
# Mysql5.7
> datastore dir: $MYSQL_ROOT
> root passwd:123456
run on shell:
\`\`\`shell
docker run -dit -p 3306:3306 \
--name mysql57 --restart=always \
-e MYSQL_ROOT_PASSWORD=123456 \
-v $MYSQL_ROOT/conf:/etc/mysql/conf.d \
-v $MYSQL_ROOT/logs:/logs \
-v $MYSQL_ROOT/data:/var/lib/mysql \
mysql:5.7
\`\`\`
EOF

export REDIS_ROOT=/datastore/redis

sudo mkdir -p $REDIS_ROOT/conf
sudo mkdir -p $REDIS_ROOT/data
sudo touch $REDIS_ROOT/conf/redis.conf

sudo docker stop redis && sudo docker rm redis
sudo docker run -itd -p 6379:6379 --name redis \
-v $REDIS_ROOT/conf/redis.conf:/etc/redis.conf \
-v $REDIS_ROOT/data:/data \
redis:latest

cat >> README.md << EOF
# Redis
datastore dir : $REDIS_ROOT
no password:yes
run on shell :
\`\`\`shell
sudo docker run -itd -p 6379:6379 --name redis \
-v $REDIS_ROOT/conf/redis.conf:/etc/redis.conf \
-v $REDIS_ROOT/data:/data \
redis:latest
\`\`\`
EOF

echo "clean"
sudo apt autoremove -y

sudo rm -rf $PWD/sources.list
#sudo rm -rf $PWD/startup-server.sh
#sudo reboot


