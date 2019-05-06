#!/bin/bash

##Parameters:
read -p "Enter a name for the storage account: " storage
read -p "Enter the type of storage account (FileStorage or BlobStorage): " type 


##Create the storage account:
az storage account create \
--name storagequickstart \
--resource-group doradoe1_asp_Linux_centralus \
--sku Standard_GRS \
--kind $type