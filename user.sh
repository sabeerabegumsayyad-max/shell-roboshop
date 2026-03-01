#!/bin/bash

userid=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

logs_folder="/var/log/shallscript-logs"
scriptname=$(echo $0 | cut -d "." -f1)
log_file="$logs_folder/$scriptname.log"
script_dir=$PWD

mkdir -p $logs_folder
echo -e "script starting executing at :$G $(date)$N"| tee -a $log_file

if [ $userid -ne 0 ]
then
    echo -e "$R please run this script with root access $N"&>>$log_file
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

dnf module disable nodejs -y &>>$log_file
VALIDATE $? "Disabling nodejs"

dnf module enable nodejs:20 -y &>>$log_file
VALIDATE $? "enabling noejs"

dnf install nodejs -y &>>$log_file
VALIDATE $? "installing nodejs"

id roboshop
if [ $? -ne 0 ]
then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$log_file
    VALIDATE $? "creating roboshop system user"
else
    echo "system user already created"
fi


mkdir -p /app 
VALIDATE $? "creating app directory"

curl -L -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip &>>$log_file
VALIDATE $? "Downloading user"

rm -rf /app/*
cd /app
unzip /tmp/user.zip &>>$log_file
VALIDATE $? "unzippinng user"

npm install &>>$log_file
VALIDATE $? "node packages intallation"

cp $script_dir/user.service /etc/systemd/system/catalogue.service 
VALIDATE $? "copying user service"

systemctl daemon-reload &>>$log_file
systemctl enable catalogue &>>$log_file
systemctl start catalogue &>>$log_file
VALIDATE $? "starting user"


END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME ))

echo -e "ecript execution completed successfully, $Y takentime : $TOTAL_TIME seconds $N" | tee -a $log_file