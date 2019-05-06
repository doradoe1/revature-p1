#!/bin/bash

##Parameters:
read -p "Enter the name for a new directory: " directory
read -p "Enter the name for the app: " appname
read -p "Enter a name for the mysql server: " server
read -p "Enter the administrator username for the mysql server: " admin
read -p "Enter a password for the mysql server (8 char. min): " password
read -p "Enter a name for the mysql database: " mysql
read -p "Enter the number of workers (3 to 4): " workers
read -p "Enter a name for the scale set: " scaleset

mkdir $directory

cd $directory

git clone https://github.com/doradoe1/revature-p1

cd revature-p1

az webapp up -n $appname

##Create a mysql database server:
az mysql server create \
--resource-group doradoe1_asp_Linux_centralus \
--name $server \
--admin-user $admin \
--admin-password $password \
--sku-name B_Gen5_1

##Create a mysql database:
az mysql db create \
--name $mysql \
--resource-group doradoe1_asp_Linux_centralus \
--server-name $server

##Link database to app:
az group deployment create \
--resource-group doradoe1_asp_Linux_centralus \
--template-uri https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/101-webapp-linux-managed-mysql/azuredeploy.json

##Update the app service plan (Sets a defaul for the servers):
az appservice plan update \
--name $appname \
--number-of-workers $workers \
--resource-group doradoe1_asp_Linux_centralus \
--sku S1

##Create a scale set (allows for redundancy):
az vmss create \
--resource-group doradoe1_asp_Linux_centralus \
--name $scaleset \
--image UbuntuLTS \
--upgrade-policy-mode automatic \
--instance-count $workers \
--admin-username $appname \
--generate-ssh-keys

##Create an autoscale rule:
az monitor autoscale create \
--resource-group doradoe1_asp_Linux_centralus \
--resource $scaleset \
--resource-type Microsoft.Compute/virtualMachineScaleSets \
--name autoscale \
--min-count $workers \
--max-count 4 \
--count $workers

sleep 10s

##Display the information for the instances:
az vmss list-instance-connection-info \
--resource-group doradoe1_asp_Linux_centralus \
--name $scaleset \
--output table