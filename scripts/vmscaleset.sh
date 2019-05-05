#!/bin/bash

##Parameters:
read -p "Enter the name for a new resource group: " rg
read -p "Enter a location for the resource group: " location
read -p "Enter the name for the scale set: " ss


##Create a brand new resource group: 
##The image is defaulted to UbuntuLTS, but it can be changed depending on it.
az group create --name $rg --location $location

##Create a scale set for the vm's:
az vmss create \
  --resource-group $rg \
  --name $ss \
  --image UbuntuLTS \
  --upgrade-policy-mode automatic \
  --admin-username azure$ss \
  --generate-ssh-keys

##Deploy the application on the VM's of the scale set:
az vmss extension set \
  --publisher Microsoft.Azure.Extensions \
  --version 2.0 \
  --name CustomScript \
  --resource-group $rg \
  --vmss-name $ss \
  --settings '{"fileUris":["https://raw.githubusercontent.com/doradoe1/revature-p1/master/app.js"],"commandToExecute":"./automate_nginx.sh"}'

##Create a rule for the load balancer:
  az network lb rule create \
  --resource-group $rs \
  --name $lbr \
  --lb-name ($ss)LB \
  --backend-pool-name ($ss)LBBEPool \
  --backend-port 8080 \
  --frontend-ip-name $feipn \
  --frontend-port 8080 \
  --protocol tcp

##Display ip address:
  deploy=(az network public-ip show \
  --resource-group myResourceGroup \
  --name myScaleSetLBPublicIP \
  --query '[ipAddress]' \
  --output tsv)

  $deploy