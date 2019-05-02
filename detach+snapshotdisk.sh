#!/bin/bash

##Parameters.##
read -p "Enter the disk name: " diskname
read -p "Enter the resource group name: " resourcegroup
read -p "Enter the name of the vm: " vmname
osDiskId=$(az vm show \
-g $resourcegroup \
-n $vmname \
--query "storageProfile.osDisk.managedDisk.id" \
-o tsv)
ssname=$diskname.snapshot

##Verify that the disk name is valid/existent:##
verifydisk=$(az disk list \
--resource-group $resourcegroup \
--query [].name \
| grep -E $diskname)

if [ -z $verifydisk ]; then
echo "Invalid Disk name. Verify your input and try again."
exit 1
else
exit 0
fi

##Verify that the VM is valid:##
verifyvm=$(az vm list \
--resource-group $resourcegroup \
-d \
--query [].name \
| grep -E $vmname)

if [ -z $verifyvm ]; then
echo "Invalid VM. Enter the name of an existing VM and try again."
exit 1
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

##Verify that the snapshot does not exist:##
verifyss=$(az snapshot list \
--resource-group $resourcegroup \
--query [].name \
| grep -E $ssname)

if [ -z $verifyss ]; then
exit 0
else
echo "Snapshot name already in use. Enter a different name and try again" 1>&2
exit 1
fi

##Detach the disk from the VM:##
az vm disk detach \
-resource-group $resourcegroup \
--vm-name $vmname \
--name $diskname

##Creating the snapshot:##
az snapshot create \
--name $ssname 
--resource-group $resourcegroup \
--source $osDiskId

##Wait five seconds before verifying the creation of the snapshot:##
sleep 5s

##Vefifying that the snapshot was created:##
az snapshot list \
--resource-group $resourcegroup \
--output table