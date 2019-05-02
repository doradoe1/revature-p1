#!bin/bash

##Script to create a brand new VM##

##Parameters.##
read -p "Enter the resource group: " resourcegroup
read -p "Enter a location for resource group: " location
read -p "Enter a name for the VM: " vmname
read -p "Enter the image (UbuntuLTS commonly used): " image
read -p "Enter the size (Standard_B2s commonly used): " size
read -p "Enter the disk name: " diskname
read -p "Enter the os type (Linux or Windows): " os
read -p "Enter the size (read in gb) for the disk: "  sizegb
read -p "Enter a name for the image: " imagename
ssname=$vmname.snapshot

##Create a resource group. Check if resource group already exists. If so, skip.##
verifyrg=$(az group exists \
--name $resourcegroup \
| grep -E true)

if [ $verifyvrg=true ]; then
echo "Resource group Valid." 0>&2
else
echo "Creating new resource group. Please wait."
az group create --name $resourcegroup --location $location
exit 0
fi

##Creating the Disk:##
az disk create \
--name $diskname \
--resource-group $resourcegroup \         
--os-type $os \
--size-gb $sizegb

##Create a VM.##
##Verify that there are no duplicates for the VM.##
##ssh keys are stored in /.ssh directory.##
##Since no location is asked for, it defaults to the location given in the resource group.##
verifyvm=$(az vm list \
--resource-group $resourcegroup \
-d \
--query [].name \
| grep -E $vmname)

if [ -z $verifyvm ]; then
az vm create \
--resource-group $resourcegroup \
--name $vmname \
--image $image \
--size $size \
--generate-ssh-keys \
--custom-data ./cloudconfig.txt
echo "VM created. Thank you for using Azure."
sleep 10s
az vm show \
--resource-group $resourcegroup \
--name $vmname \
--show-details \
--output table
else
echo "VM name already in use. Please choose a different name and try again." \
1>&2
fi

##Attaching the Disk to the VM:##
az vm disk attach \
--resource-group $resourcegroup \
--vm-name $vmname \
--name $diskname

##Open the port:##
az vm open-port \
--port 8080 \
--resource-group $resourcegroup \
--name $vmname

##Detach the disk from the VM:##
az vm disk detach \
-resource-group $resourcegroup \
--vm-name $vmname \
--name $diskname

##Creating the snapshot:##
az snapshot create \
--name $ssname 
--resource-group $resourcegroup \
--source $diskname

##Wait five seconds before verifying the creation of the snapshot:##
sleep 5s

##Vefifying that the snapshot was created:##
az snapshot list \
--resource-group $resourcegroup \
--output table

##Verify that image does not exist, else exit:##
verifyimage=$(az image list \
--resource-group $resourcegroup \
--output table \
| grep -E $imagename)

if [ -z $verifyimage ]; then
echo "Valid Image name." 0>&2
else
echo "Image name in use. Please choose another name for the image."
exit 1
fi 

##You need to be signed-in into the VM that you want to image capture.##
##Deprovision the VM and sign out:##
sudo waagent -deprovision+user -y
exit

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
--resource-group $resourcegroup\
--source $vmname

az image list \
--resource-group $resourcegroup \
--output table 