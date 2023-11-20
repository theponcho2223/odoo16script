#!/bin/bash
# Copyright 2023 odooerpcloud.com
# AVISO IMPORTANTE!!! (WARNING!!!)
# ASEGURESE DE TENER UN SERVIDOR / VPS CON AL MENOS >= 2GB DE RAM y 20GB Disco
# You must to have at least > 2GB of RAM and >= 20GB SSD
# SO Compatibles: Ubuntu 20.04 LTS, Ubuntu 22.04 LTS, Debian 11 y 12
# v3.8 Production version for Odoo 16.0
# Last updated: 2023-10-11

OS_NAME=$(lsb_release -cs)
usuario=$USER
DIR_PATH=$(pwd)
VCODE=16
VERSION=16.0
PORT=1669
DEPTH=1
SERVICE_NAME=odoo16
PROJECT_NAME=odoo16
PATHBASE=/opt/$PROJECT_NAME
PATH_LOG=$PATHBASE/log
PATHREPOS=$PATHBASE/extra-addons
PATHREPOS_OCA=$PATHREPOS/oca

wk64=""
wk32=""

if [[ $OS_NAME == "bookworm" ]];

then
	wk64="https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-3/wkhtmltox_0.12.6.1-3.bookworm_amd64.deb"

fi

if [[ $OS_NAME == "jammy" ]];

then
	wk64="https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-2/wkhtmltox_0.12.6.1-2.jammy_amd64.deb"

fi


if [[ $OS_NAME == "buster"  ||  $OS_NAME == "bionic" || $OS_NAME == "focal" ]];

then
	wk64="https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6-1/wkhtmltox_0.12.6-1."$OS_NAME"_amd64.deb"
	wk32="https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6-1/wkhtmltox_0.12.6-1."$OS_NAME"_i386.deb"

fi

if [[ $OS_NAME == "bullseye" ]];

then
	wk64="https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-2/wkhtmltox_0.12.6.1-2."$OS_NAME"_amd64.deb"
	wk32="https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-2/wkhtmltox_0.12.6.1-2."$OS_NAME"_i386.deb"
fi

echo $wk64
sudo adduser --system --quiet --shell=/bin/bash --home=$PATHBASE --gecos 'ODOO' --group $usuario
sudo adduser $usuario sudo

#add universe repository & update (Fix error download libraries)
sudo add-apt-repository universe
sudo apt-get update
sudo apt-get upgrade

#### nuevas forma instalar dependencias odoo 16
sudo apt-get update && \
sudo apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    dirmngr \
    fonts-noto-cjk \
    gnupg \
    libssl-dev \
    node-less \
    npm \
    net-tools \
    xz-utils \
    procps \
    nano \
    htop \
    zip \
    unzip \
    git \
    gcc \
    build-essential \
    libsasl2-dev \
    python3-dev \
    python3-venv \
    libxml2-dev \
    libxml2-dev \
    libxslt1-dev \
    libevent-dev \
    libpng-dev \
    libjpeg-dev \
    xfonts-base \
    xfonts-75dpi \
    libxrender1 \
    python3-pip \
    libldap2-dev \
    libpq-dev \
    libsasl2-dev

##################end python dependencies#####################

############## PG Update and install Postgresql #####################
sudo apt-get install postgresql postgresql-client -y
sudo  -u postgres  createuser -s $usuario
############## PG Update and install Postgresql #####################

sudo mkdir $PATHBASE
sudo mkdir $PATHREPOS
sudo mkdir $PATHREPOS_OCA
sudo mkdir $PATH_LOG
cd $PATHBASE
# Download Odoo from git source
sudo git clone https://github.com/odoo/odoo.git -b $VERSION --depth $DEPTH $PATHBASE/odoo
sudo git clone https://github.com/oca/web.git -b $VERSION --depth $DEPTH $PATHREPOS_OCA/web
sudo git clone https://github.com/odoo/design-themes.git -b $VERSION --depth $DEPTH $PATHREPOS/design-themes


#nodejs and less
sudo ln -s /usr/bin/nodejs /usr/bin/node
sudo npm install -g less

# Download & install WKHTMLTOPDF
sudo rm $PATHBASE/wkhtmltox*.deb

if [[ "`getconf LONG_BIT`" == "32" ]];

then
	sudo wget $wk32
else
	sudo wget $wk64
fi

sudo dpkg -i --force-depends wkhtmltox_0.12.6*.deb
sudo apt-get -f -y install
sudo ln -s /usr/local/bin/wkhtml* /usr/bin
sudo rm $PATHBASE/wkhtmltox*.deb

# install python requirements file (Odoo)
sudo rm -rf $PATHBASE/venv
sudo mkdir $PATHBASE/venv
sudo chown -R $usuario: $PATHBASE/venv
#virtualenv -q -p python3 $PATHBASE/venv
python3 -m venv $PATHBASE/venv
$PATHBASE/venv/bin/pip3 install --upgrade pip

$PATHBASE/venv/bin/pip3 install -r $PATHBASE/odoo/requirements.txt

cd $DIR_PATH

sudo mkdir $PATHBASE/config
sudo rm $PATHBASE/config/odoo$VCODE.conf
sudo touch $PATHBASE/config/odoo$VCODE.conf
echo "
[options]
; This is the password that allows database operations:
;admin_passwd =
db_host = False
db_port = False
;db_user =

;db_password =
data_dir = $PATHBASE/data
logfile= $PATH_LOG/odoo$VCODE-server.log

xmlrpc_port = $PORT
;dbfilter = odoo$VCODE
logrotate = True
limit_time_real = 6000
limit_time_cpu = 6000
proxy_mode = False

############# addons path ######################################

addons_path =
    $PATHREPOS,
    $PATHREPOS/design-themes,
    $PATHREPOS_OCA/web,
    $PATHBASE/odoo/addons

#################################################################
" | sudo tee --append $PATHBASE/config/odoo$VCODE.conf

sudo rm /etc/systemd/system/$SERVICE_NAME.service
sudo touch /etc/systemd/system/$SERVICE_NAME.service
sudo chmod +x /etc/systemd/system/$SERVICE_NAME.service
echo "
[Unit]
Description=Odoo$VCODE-$SERVICE_NAME
After=postgresql.service

[Service]
Restart=on-failure
RestartSec=5s
Type=simple
User=$usuario
ExecStart=$PATHBASE/venv/bin/python3 $PATHBASE/odoo/odoo-bin --config $PATHBASE/config/odoo$VCODE.conf

[Install]
WantedBy=multi-user.target
" | sudo tee --append /etc/systemd/system/$SERVICE_NAME.service
sudo systemctl daemon-reload
sudo systemctl enable $SERVICE_NAME.service
sudo systemctl start $SERVICE_NAME.service

sudo chown -R $usuario: $PATHBASE

## Add cron backup project folder (Todos lunes 4:30am)
sudo -u root bash << eof
cd /root
echo "Agregando crontab para backup carpeta instalacion Odoo..."

sudo crontab -l | sed -e '/zip/d; /$PROJECT_NAME/d' > temporal

echo "
30 4 * * * zip -r /opt/$PROJECT_NAME.zip $PATHBASE" >> temporal
crontab temporal
rm temporal
eof


echo "Odoo $VERSION Installation has finished!! ;) by odooerpcloud.com"
IP=$(ip route get 8.8.8.8 | head -1 | cut -d' ' -f7)
echo "You can access from: http://$IP:$PORT  or http://localhost:$PORT"
