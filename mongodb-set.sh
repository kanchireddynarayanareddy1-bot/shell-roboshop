#!/bin/bash
set -euo pipefail
trap 'echo "There is an error in $LINENO, Command is: $BASH_COMMAND"' ERR
UserId=$(id -u) 
R="\e[031m"
G="\e[032m"
Y="\e[033m"
N="\e[0m"

Folder="/var/log/shell-roboshop"
ScriptName=$(echo $0 | cut -d'.' -f1)
LogFile="$Folder/$ScriptName.log"  
 
mkdir -p $Folder
echo "Script execution started at: $(date)" | tee -a $LogFile   

if [ $UserId -ne 0 ]; then
    echo "you can give sudo access to this script to run as root user" | tee -a $LogFile
fi


cp mongo.repo /etc/yum.repos.d/mongo.repo
dnf install mongodb-org -y &>>$LogFile
echo -e "Installing MongoDB ... $G SUCCESS $N"
systemctl enable mongod &>>$LogFile
systemctl start mongod 
sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
systemctl restart mongod &>>$LogFile
echo -e "MongoDB setup ... $G SUCCESS $N"



