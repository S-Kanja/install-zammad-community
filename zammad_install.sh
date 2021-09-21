#!/bin/bash
# Descrição: ZAMMAD COMMUNITY INSTALL
# Criado por: Erick Almeida
# Data de Criacao: 19/08/2020
# Ultima Modificacao: 26/08/2020
# Compativél com o Ubuntu 18.04 (Homologado)

echo -e "\e[01;31m             INSTALLATION SCRIPT FOR THE ZAMMAD COMMUNITY - INTERACTIVE - UBUNTU SERVER 18.04     \e[00m"
echo -e "\e[01;31m                                       Tecle <ENTER> para iniciar...                             \e[00m"
read #pausa até que o ENTER seja pressionado

# ATUALIZAR REPOSITÓRIOS,PACOTES E A DISTRIBUIÇÃO DO SISTEMA OPERACIONAL

echo -e "\e[01;31m                  PROVIDING REPOSITORS AND OPERATIONAL SYSTEM DISTRIBUTION       \e[00m"
echo -e "\e[01;31m                                       Tecle <ENTER> para continuar...                           \e[00m"
read #pausa até que o ENTER seja pressionado

apt update -y
apt upgrade -y
apt dist-upgrade -y

# INSTALAR DE DEPENDENCIAS INICIAIS

echo -e "\e[01;31m                                     INSTALLING INITIAL DEPENDENCIES                         \e[00m"
echo -e "\e[01;31m                                       Tecle <ENTER> para continuar...                           \e[00m"
read #pausa até que o ENTER seja pressionado

apt-get install apt-transport-https wget -y

# ADICIONAR REPOSITORIO E INSTALANDO ELASTICSEARCH E OPENJDK8

echo -e "\e[01;31m                         ADICIONANDO REPOSITORIO E INSTALANDO ELASTICSEARCH E OPENJDK8          \e[00m"
echo -e "\e[01;31m                                       Tecle <ENTER> para continuar...                          \e[00m"
read #pausa até que o ENTER seja pressionado

sudo echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-7.x.list
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -

sudo apt-get update
sudo apt-get install openjdk-8-jre elasticsearch -y
sudo /usr/share/elasticsearch/bin/elasticsearch-plugin install ingest-attachment

# ATUALIZAR O SERVIÇO DO ELASTICSEARCH   

echo -e "\e[01;31m                          ADDING REPOSITORY AND INSTALLING ELASTICSEARCH AND OPENJDK8                    \e[00m"
echo -e "\e[01;31m                                       Tecle <ENTER> para continuar...                         \e[00m"
read #pausa até que o ENTER seja pressionado

sudo systemctl restart elasticsearch
sudo systemctl enable elasticsearch

# ADICIONAR REPOSITORIOS DO ZAMMAD COMMUNITY   

echo -e "\e[01;31m                              ADDING THE ZAMMAD COMMUNITY REPOSITORIES
echo -e "\e[01;31m                                       Tecle <ENTER> para continuar...                         \e[00m"
read #pausa até que o ENTER seja pressionado


wget -qO- https://dl.packager.io/srv/zammad/zammad/key | sudo apt-key add -
sudo wget -O /etc/apt/sources.list.d/zammad.list https://dl.packager.io/srv/zammad/zammad/stable/installer/ubuntu/18.04.repo


echo -e "\e[01;31m                         UPDATING REPOSITORY AND INSTALLING ZAMMAD COMMUNITY              \e[00m"
echo -e "\e[01;31m                                       Tecle <ENTER> para continuar...                         \e[00m"
read #pausa até que o ENTER seja pressionado

sudo apt-get update
sudo apt-get install zammad -y

# AJUSTES DE REDE

echo -e "\e[01;31m                                        MAKING NETWORK ADJUSTMENTS                            \e[00m"
echo -e "\e[01;31m                                       Tecle <ENTER> para continuar...                         \e[00m"
read #pausa até que o ENTER seja pressionado
# shis Should Be Tested

sed -i 's/server_name localhost;/server_name localhost;/g' /etc/nginx/sites-enabled/zammad.conf

sed -i 's/server_name localhost;/server_name localhost;/g' /etc/nginx/sites-available/zammad.conf

sudo systemctl reload nginx

# CRIAR SERVIÇO DE REDUDANCIA PARA O ELASTICSERVICE

echo -e "\e[01;31m                             CRIANDO SERVIÇO DE REDUDANCIA PARA O ELASTICSERVICE               \e[00m"
echo -e "\e[01;31m                                       Tecle <ENTER> para continuar...                         \e[00m"
read #pausa até que o ENTER seja pressionado

cd /
mkdir services
chmod 777 /services
cd /services
touch elasticforce.sh
chmod +x elasticforce.sh

echo "#!/bin/bash
# Descrição: Manuteção
# Criado por: Erick Almeida
# Data de Criacao: 24/08/2020
# Ultima Modificacao: 24/08/2020

# Forçando inicialização do serviço

systemctl start elasticsearch.service
sleep 180
systemctl start elasticsearch.service" >> /services/elasticforce.sh


cd /etc/systemd/system/
touch elasticforce.service

echo "[Unit]
Description=elasticforce.service
After=network.target
StartLimitIntervalSec=0
[Service]
Type=simple
User=root
ExecStart=/services/elasticforce.sh
[Install]
WantedBy=multi-user.target" >> /etc/systemd/system/elasticforce.service

systemctl daemon-reload
systemctl enable elasticforce.service
systemctl start elasticforce.service

# INSTALAR DE PLUGINS PARA O ZAMMAD COMMUNITY 

echo -e "\e[01;31m                                ZAMMAD COMMUNITY PLUGINS WILL BE INSTALLED             \e[00m"
echo -e "\e[01;31m                                       Tecle <ENTER> para continuar...                        \e[00m"
read #pausa até que o ENTER seja pressionado

sudo zammad run rails r "Setting.set('es_url', 'http://localhost:9200')"
sudo zammad run rake searchindex:rebuild

# EFETUAR AJUSTE DE FIREWALL

echo -e "\e[01;31m                                                  FIREWALL                               \e[00m"
echo -e "\e[01;31m                                       Tecle <ENTER> para continuar...                        \e[00m"
read #pausa até que o ENTER seja pressionado

systemctl enable ufw
ufw allow 22
ufw allow 80
ufw allow 443
ufw allow 70

echo -e "\e[01;31m            THE INSTALLATION HAPPENED WELL, YOUR SERVER WILL BE RESTARTED AND YOU WILL BE ABLE TO USE THE ZAMMAD COMMUNITY     \e[00m"
echo -e "\e[01;31m                                 IN YOUR BROWSER ACCESS http: //  http://IPDOSEUSERVIDOR                            \e[00m"
echo -e "\e[01;31m                                           Tecle <ENTER> para encerrar...                                      \e[00m"
read #pausa até que o ENTER seja pressionado

reboot
