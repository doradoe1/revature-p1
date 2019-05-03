#!/bin/bash

#-----------------------------------------------##Parameters.##------------------------------------------------#
read -p "Enter the resource group name: " resourcegroup
read -p "Enter the name of the vm: " vmname
read -p "Enter a name for the availability set: " as
read -p "Enter the image (UbuntuLTS commonly used): " image
read -p "Enter the size (Standard_B2s commonly used): " size

#--------------------------------------##Dummyproffing the new inputs:##--------------------------------------#

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

az vm availability-set create \
--resource-group $resourcegroup \
--name $as \
--platform-fault-domain-count 2 \
--platform-update-domain-count 2

for i in `seq 1 2 3`; do
   az vm create \
     --resource-group $resourcegroup \
     --name $vmname$i \
     --availability-set $as \
     --size $size \
     --image $image
done