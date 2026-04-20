#!/bin/bash

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
VALIDATE (){
   if [ $1 -ne 0 ]; then
    echo -e " $2 $R FAILURE $N" | tee -a $LogFile
else
    echo -e "$2 $G SUCCESS $N" | tee -a $LogFile
fi 
}

cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Adding Mongo repo" 

dnf install mongodb-org -y &>>$LogFile
VALIDATE $? "Installing MongoDB"

systemctl enable mongod &>>$LogFile
VALIDATE $? "Enable MongoDB"

systemctl start mongod 
VALIDATE $? "Start MongoDB"

sed -i '120.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "Allowing remote connection to MongoDB" 

systemctl restart mongod &>>$LogFile
VALIDATE $? "Restarting MongoDB"
