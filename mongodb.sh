#!/bin/bash

userid=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

logs_folder="/var/log/shallscript-logs"
scriptname=$(echo $0 | cut -d "." -f1)
log_file="$logs_folder/$scriptname.log"

mkdir -p $logs_folder
echo -e "script starting executing at :$G $(date)$N"| tee -a $log_file
if [ $userid -ne 0 ]
then
    echo "please run this script with root access "&>>$log_file
    exit 1
else
    echo -e "running this script with $G root access $N" | tee -a $log_file
fi

VALIDATE(){
    if [ $1 -eq 0 ] 
    then
        echo -e " $2 is $G success $N" | tee -a $log_file
    else
        echo -e " $2 is $R failure $N" | tee -a $log_file
        exit 1
    fi
}

cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "copying mongo repo"

dnf install mongodb-org -y &>>$log_file
VALIDATE $? "mongobd installation"

systemctl enable mongod &>>$log_file
VALIDATE $? "mongodb enabling"

systemctl start mongod &>>$log_file
VALIDATE $? "mongodb starting"

sed -i "s/127.0.0.1/0.0.0.0/g" /etc/mongod.conf &>>$log_file
VALIDATE $? "editing the mongodb conf for remote connectins"

systemctl restart mongod &>>$log_file
VALIDATE $? "mongodb restarting"