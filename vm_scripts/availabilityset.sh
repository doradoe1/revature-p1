#!/bin/bash

#-----------------------------------------------##Parameters.##------------------------------------------------#
read -p "Enter the resource group name: " resourcegroup
read -p "Enter the name of the vm: " vmname
read -p "Enter a name for the availability set: " as
read -p "Enter the image (UbuntuLTS commonly used): " image
read -p "Enter the size (Standard_B2s commonly used): " size
read -p "Enter the custom data txt file: " cloudinit

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

##Verify for valid VM name:##
verifyvm=$(az vm list \
    --resource-group $resourcegroup \
    -d \
    --query [].name \
| grep -E $vmname)
if [ -z $verifyvm ]; then
    exit 0
else
    echo "VM name already in use. Please check your input and try again."
    1>&2
fi

#-------------------------------------##Create the VM's and the Avaib. Set:##----------------------------------#
##Create the availability set:##
az vm availability-set create \
--resource-group $resourcegroup \
--name $as \
--platform-fault-domain-count 2 \
--platform-update-domain-count 2

##Creating the Disk:##
for i in `seq 1 2 3 4`; do
    az disk create \
    --name $diskname$i \
    --resource-group $resourcegroup \
    --os-type $os \
    --size-gb $sizegb
done

##Create the VM:##
for i in `seq 1 2 3 4`; do
    az vm create \
    --resource-group $resourcegroup \
    --name $vmname$i \
    --availability-set $as \
    --size $size \
    --image $image \
    --disk-attach $diskname$i \
    --custom-data $cloudinit
done

##Open the ports for the VMs:##
for i in `seq 1 2 3 4` do
    az vm open-port /
    --port 8080 /
    --resource-group $resourcegroup /
    --name $vmname$i
done
