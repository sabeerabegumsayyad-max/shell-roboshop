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

dnf module disable nginx -y &>>$log_file
VALIDATE $? "disabling nginx"

dnf module enable nginx:1.24 -y &>>$log_file
VALIDATE $? "enabling nginx"

dnf install nginx -y &>>$log_file
VALIDATE $? "installing nginx"

systemctl enable nginx &>>$log_file
systemctl start nginx 
VALIDATE $? "starting nginx"

rm -rf /usr/share/nginx/html/* &>>$log_file
VALIDATE $? "removing existing data"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>>$log_file
VALIDATE $? "downloading code"

cd /usr/share/nginx/html
unzip /tmp/frontend.zip &>>$log_file
VALIDATE $? "unzipping code"
#there will have some defaulut contetnt tyt that one we need to remove
rm -rf /etc/nginx/nginx.conf &>>$log_file
VALIDATE $? "remove default nginx"

cp $script_dir/nginx.conf /etc/nginx/nginx.conf &>>$log_file
VALIDATE $? "copying nginx.conf"

systemctl restart nginx &>>$log_file
VALIDATE $? "restarting nginx"