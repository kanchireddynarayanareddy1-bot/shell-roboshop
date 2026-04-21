#!/bin/bash

UserId=$(id -u) 
R="\e[031m"
G="\e[032m"
Y="\e[033m"
N="\e[0m"   
Folder="/var/log/shell-roboshop"
ScriptName=$(echo $0 | cut -d'.' -f1)
SCRIPT_DIR=$PWD
LogFile="$Folder/$ScriptName.log"   
mkdir -p $Folder
echo "Script execution started at: $(date)" | tee -a $LogFile       
if [ $UserId -ne 0 ]; then
    echo "you can give sudo access to this script to run as root user" | tee -a $LogFile
    exit 1
fi
 VALIDATE (){
    if [$1 -ne 0]; then
        echo -e " $2 $R FAILURE $N" | tee -a $LogFile
        exit 1
    else
        echo -e "$2 $G SUCCESS $N" | tee -a $LogFile
    fi
 }

dnf module disable nodejs -y &>>$LogFile
VALIDATE $? "Disable NodeJS module"

dnf module enable nodejs:20 -y &>>$LogFile
VALIDATE $? "Enable NodeJS 20 module"

dnf install nodejs -y &>>$LogFile
VALIDATE $? "Installing NodeJS"

useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
VALIDATE $? "Adding roboshop user"

mkdir -p /app &>>$LogFile
VALIDATE $? "Creating application directory"    

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip
VALIDATE $? "Downloading application code"

cd /app
VALIDATE $? "Changing directory to /app"   

rm -rf /app/* &>>$LogFile
VALIDATE $? "Cleaning old application content"

unzip /tmp/catalogue.zip &>>$LogFile
VALIDATE $? "Extracting application code"

npm install &>>$LogFile
VALIDATE $? "Installing NodeJS dependencies"

cp $SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service
VALIDATE $? "Copying systemd service file"

systemctl daemon-reload &>>$LogFile

dnf install mongodb-mongosh -y &>>$LOG_FILE
VALIDATE $? "Install MongoDB client"

INDEX=$(mongosh mongodb.chandrahasa.online --quiet --eval "db.getMongo().getDBNames().indexOf('catalogue')")
if [ $INDEX -le 0 ]; then
    mongosh --host $MONGODB_HOST </app/db/master-data.js &>>$LOG_FILE
    VALIDATE $? "Load catalogue products"
else
    echo -e "Catalogue products already loaded ... $Y SKIPPING $N"
fi

systemctl restart catalogue
VALIDATE $? "Restarted catalogue"