#!/bin/bash

##Parameters:
read -p "Enter the name for a new directory: " directory
read -p "Enter the name for the app: " appname
read -p "Enter the number of workers (3 to 4): " workers
read -p "Enter a name for the scale set: " scaleset

mkdir $directory

cd $directory

git clone https://github.com/doradoe1/revature-p1

cd revature-p1

az webapp up -n $appname

az appservice plan update \
--name $appname \
--number-of-workers $workers \
--resource-group doradoe1_asp_Linux_centralus

az vmss create \
--resource-group doradoe1_asp_Linux_centralus \
--name $scaleset \
--image UbuntuLTS \
--upgrade-policy-mode automatic \
--instance-count $workers \
--admin-username $appname \
--generate-ssh-keys

az monitor autoscale create \
--resource-group doradoe1_asp_Linux_centralus \
--resource $scaleset \
--resource-type Microsoft.Compute/virtualMachineScaleSets \
--name autoscale \
--min-count $workers \
--max-count 4 \
--count $workers

sleep 5s

az vmss list-instance-connection-info \
--resource-group doradoe1_asp_Linux_centralus \
--name $scaleset \
--output table