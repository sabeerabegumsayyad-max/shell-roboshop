#!/bin/bash

AMI_ID="ami-0220d79f3f480ecf5"
SG_ID="sg-0dc0951f043f884d8"
INSTANCES=("mongodb" "mysql" "rabitmq" "payment" "shipping" "cart" "user" "catalouge" "dispatch" "frontend")
ZONE_ID="Z05998412DIKACIE1APGQ"
DOMAIN_NAME="sabeera.online"

for instance in ${INSTANCES[@]}
do
    Instance_ID=$(aws ec2 run-instances \
    --image-id ami-0220d79f3f480ecf5 \  --instance-type t2.micro \  --security-group-ids sg-0dc0951f043f884d8 \  --tag-specifications "ResourseTyoe=instance,Tags=[{ key=Name, Value=$instance }]" \  --query 'Instances[0].InstanceID' \  --output text)
    if [ $instances -ne "frontend" ]
    then
        IP=$(aws ec2 describe-instances \  --instance-ids $INSTANCE_ID \  --query 'Reservations[0].Instances[0].PrivateIpAddress' \  --output text)
    else
        IP=$(aws ec2 describe-instances \  --instance-ids $INSTANCE_ID \  --query 'Reservations[0].Instances[0].PublicIpAddress' \  --output text)
    fi
    echo "$instance IP adress : $IP"
done