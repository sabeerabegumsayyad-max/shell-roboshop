#!/bin/bash

START_TIME=$(date +%S)
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
    echo "please run this script with root access " &>>$log_file
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

dnf module disable redis -y &>>$log_file
VALIDATE $? "disabling redis"

dnf module enable redis:7 -y &>>$log_file
VALIDATE $? "enabling redis"

dnf install redis -y &>>$log_file
VALIDATE $? "installing redis"

sed -i -e 's/127.0.0.1/0.0.0.0/g' -e 'protected-mode/ c protected-mode no' /etc/redis/redis.conf 
VALIDATE $? "editing redis.repo file "

systemctl enable redis &>>$log_file
VALIDATE $? "enabling redis"

systemctl start redis &>>$log_file
VALIDATE $? "starting redis"

END_TIME=$(date +%s)
TOTAL_TIME=$(($END_TIME - $START_TIME))

echo -e "ecript execution completed successfully, $Y takentime : $TOTAL_TIME seconds $N" | tee -a $log_file