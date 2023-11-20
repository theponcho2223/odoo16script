# (Odoo v16.0 script installer v3.8)

## v3.8 (Debian 12 or 11 | ubuntu 22.04 | ubuntu 20.04 lts) 

(Copyright 2023 - OdooERPCloud)

Last Update 2023-10-11

https://www.odooerpcloud.com

Odoo Deploy Tools

## odoo.service

This file is used from odooxx.sh for to install Odoo Start Service

## odooxx.sh
This script install Odoo in Your Server

## Requirements Hardware and SO
* 2GB RAM, 20GB SSD
* Debian 11 y 12 (Probado)
* Ubuntu 20.04 LTS Probado
* Ubuntu 22.04 LTS Probado


## VPS Providers
    * OVH
    * Google Cloud
    * Amazon AWS
    * IONOS
    * Digital Ocean
    * Hetzner
    * CONTABO

## How to install

### Ubuntu Desktop

1. Copy this Folder in your System (Desktop, Downloads, etc.)
2. Go to Directory and open a terminal
3. chmod +x  *.sh
4. Execute: ./odooxx.sh
5. Enjoy

### Ubuntu Server (VPS)

1. Copy this Folder in your User Home Directory using Filezilla or WinSCP OR SCP command)
2. Go to this Folder by terminal
3. chmod +x  *.sh
4. Execute: ./odooxx.sh
5. Enjoy

### Odoo Service Manager

* sudo systemctl status odooxx (shows state Odoo service)
* sudo systemctl start odooxx (start service)
* sudo systemctl stop odooxx (stop service)
* sudo systemctl restart odooxx (restart service)
* sudo tail -f /opt/odoo16/log/ (Shows Live Odoo Log)


### Source or extructure location

* /opt/odoo16 (All Source)
* /opt/odoo16/extra-addons (Extra Addons)
* /opt/odoo16/extra-addons/oca (Put here your OCA Extra Addons)
* /opt/odoo16/data (Filestore)
* /opt/odoo16/log/ (Log file)


### Changelog
* v3.8 Octubre  2023
  * Actualización con muchas mejoras para optimizar la instalación, eliminar librerías no necesarias
* v3.7 Agosto  2023
  * Compatible con Debian 12 BookWorm
  * Nueva forma de instalar dependencias mas estable y eficiente
* v3.6 Julio  2023 
  * Compatibilidad con Debian 11 Ubuntu 20.04 LTSy 22.04 LTS Actualizados
  * Agregados varios temas gratis para el website (Odoo SA)
  * Agregado Theme backend backed theme para Community (OCA) (modulo web_responsive)

* 2022-09-16
  * Add automatic restart Odoo service on failure
  * Fix pyopenssl pip3 library error version (new ubuntu debian versions)
  * Add Odoo service name parameter (yo can set specific odoo service name now)
