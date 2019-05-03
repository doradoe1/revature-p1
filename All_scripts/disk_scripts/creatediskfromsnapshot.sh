#!/bin/bash

##Parameters.##
read -p "Enter a name for the new disk: " newdisk
read -p "Enter the resource group name: " resourcegroup
read -p "Enter the name of the source disk (snapshot): " snapshotdisk

##Verify that the disk name is valid/existent:##
verifydisk=$(az disk list \
--resource-group $resourcegroup \
--query [].name \
| grep -E $diskname)

if [ -z $verifydisk ]; then
echo 0
else
echo "Invalid/Existing Disk name. Verify your input and try again."
exit 1
fi

##Create a managed disk by copying an existing disk or snapshot.##
az disk create \
--resource-group $resourcegroup \
--name $newdisk \
--source $snapshotdisk