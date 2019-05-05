#!/bin/bash

#parameters:
read -p "Enter the name for the app: " appname
read -p "Enter the ip address: " ip
read -p "Enter the port number: " port

##login into the first VM instance:
ssh $appname@$ip -p $port
