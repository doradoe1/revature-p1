#!/bin/bash

##Parameters:
read -p "Enter a name for the cosmosdb account: " cosmosdbaccount
read -p "Enter a name for the database account: " database

##Create a cosmos database account:
az cosmosdb create \
--name $cosmosdbaccount \
--resource-group doradoe1_asp_Linux_centralus \
--enable-automatic-failover true

##Create a cosmos database:
az cosmosdb database create \
--db-name $database \
--name $cosmosdbaccount \
--resource-group doradoe1_asp_Linux_centralus

##Show the database:
az cosmosdb database show --db-name
--db-name $database \
--name $cosmosdbaccount \
--resource-group doradoe1_asp_Linux_centralus