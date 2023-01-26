cd $HOME 
curl -o ubuntu-init.zip https://raw.githubusercontent.com/AndromedaX7/ubuntu-init/main/ubuntu-init.zip
unzip ubuntu-init.zip 
chmod a+x ubuntu-init-software-sc.sh
rm -rf ubuntu-init.zip
rm -rf startup.sh
./ubuntu-init-software-sc.sh
