#!/bin/bash

##Parameters:
read -p "Enter the name for a new directory: " directory
read -p "Enter the name for the app: " appname

mkdir $directory

cd $directory

git clone https://github.com/doradoe1/revature-p1

cd revature-p1

az webapp up -n $appname