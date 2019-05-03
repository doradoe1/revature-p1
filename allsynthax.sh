#-----------------------------------------------##Parameters.##------------------------------------------------#
read -p "Enter the disk name: " diskname
read -p "Enter the resource group name: " resourcegroup
read -p "Enter the os type (Linux or Windows): " os
read -p "Enter the size (read in gb) for the disk: "  sizegb
read -p "Enter the name of the vm: " vmname
read -p "Enter a name for the new disk: " newdisk
read -p "Enter the resource group name: " resourcegroup
read -p "Enter the name of the source disk (snapshot): " snapshotdisk
read -p "Enter a name for the image: " imagename
read -p "Enter a location for resource group: " location
read -p "Enter the image (UbuntuLTS commonly used): " image
read -p "Enter the size (Standard_B2s commonly used): " size
read -p "Enter the custom data script name:" cloudinit
osDiskId=$(az vm show \
    -g $resourcegroup \
    -n $vmname \
    --query "storageProfile.osDisk.managedDisk.id" \
-o tsv)
ssname=$diskname.snapshot

#--------------------------------------##Dummyproffing the new inputs:##--------------------------------------#
##Verify that the disk name is not taken:##
verifydisk=$(az disk list \
    --resource-group $resourcegroup \
    --query [].name \
| grep -E $diskname)
if [ -z $verifydisk ]; then
    exit 0
else
    echo "Disk name already in use. Please choose another name for the disk and try again." 1>&2
    exit 1
fi

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

#----------------------------------------------##Commamd Synthax:##----------------------------------------------#
##Open the 8080 port:##
az vm open-port \
--resource-group $resourcegroup \
--name $vmname \
--port 8080

##Creating the Disk:##
az disk create \
--name $diskname \
--resource-group $resourcegroup \
--os-type $os \
--size-gb $sizegb

##Attaching the Disk to the VM:##
az vm disk attach \
--resource-group $resourcegroup \
--vm-name $vmname \
--name $diskname

##Create a managed disk by copying an existing disk or snapshot:##
az disk create \
--resource-group $resourcegroup \
--name $newdisk \
--source $snapshotdisk

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

##Vefifying that the snapshot was created:##
az snapshot list \
--resource-group $resourcegroup \
--output table

##Create VM without custom data:##
az vm create \
--resource-group $resourcegroup \
--name $vmname \
--image $image \
--size $size \
--generate-ssh-keys

##Create VM with custom data:##
az vm create \
--resource-group $resourcegroup \
--name $vmname \
--image $image \
--size $size \
--generate-ssh-keys \
--custom-data ./$cloudinit