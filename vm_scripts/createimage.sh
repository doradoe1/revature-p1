#!/bin/bash

##Parameters.##
read -p "Enter the name of the vm: " vmname
read -p "Enter the resource group: " resourcegroup
read -p "Enter a name for the image: " imagename

##Verify for valid VM:##
verifyvm=$(az vm list \
--resource-group $resourcegroup \
-d \
--query [].name \
| grep -E $vmname)

if [ -z $verifyvm ]; then
echo "Invalid/non-existent VM. Please check your input and try again."
1>&2
else
exit 0
fi


##Verify for valid Resource Group:##
verifyrg=$(az group exists \
--name $resourcegroup \
| grep -E true)

if [ $verifyvrg=true ]; then
exit 0
else
echo "Invalid/non-existent Resource group. Please check your input and try again."
exit 1
fi

##Verify for valid Image name:##
verifyimage=$(az image list \
--resource-group $resourcegroup \
--query [].name \
| grep -E $imagename)

if [ -z $verifyimage ]; then
exit 0
else
echo "Image name in use. Please choose another name for the image."
exit 1
fi 

##Create the image:##
az vm stop \
--name $vmname \
--resource-group $resourcegroup

az vm deallocate \
--resource-group $resourcegroup \
--name $vmname

az vm generalize \
--resource-group $resourcegroup \
--name $vmname

az image create \
--name $imagename \
--resource-group $resourcegroup \
--source $vmname

az image list \
--resource-group $resourcegroup \
--output table 

