#!/bin/bash

AMI_ID="ami-0220d79f3f480ecf5"
SG_ID="sg-0dc0951f043f884d8"
INSTANCES=("mongodb" "mysql" "rabitmq" "payment" "shipping" "cart" "user" "catalouge" "dispatch" "frontend")
ZONE_ID="Z05998412DIKACIE1APGQ"
DOMAIN_NAME="sabeera.online"

for instance in "${INSTANCES[@]}"; do
    Instance_ID=$(aws ec2 run-instances \
        --image-id "$AMI_ID" \
        --instance-type t3.micro \
        --security-group-ids "$SG_ID" \
        --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
        --query 'Instances[0].InstanceId' \
        --output text)

    if [ -z "$Instance_ID" ]; then
        echo "Failed to launch $instance. Skipping..."
        continue
    fi

    # Wait until instance is running
    aws ec2 wait instance-running --instance-ids "$Instance_ID"

    if [ "$instance" != "frontend" ]; then
        IP=$(aws ec2 describe-instances \
            --instance-ids "$Instance_ID" \
            --query 'Reservations[0].Instances[0].PrivateIpAddress' \
            --output text)
    else
        IP=$(aws ec2 describe-instances \
            --instance-ids "$Instance_ID" \
            --query 'Reservations[0].Instances[0].PublicIpAddress' \
            --output text)
    fi

    echo "$instance IP address: $IP"

    aws route53 change-resource-record-sets \
      --hosted-zone-id "$ZONE_ID" \
      --change-batch "$(cat <<EOF
    {
      "Changes": [{
        "Action": "UPSERT",
        "ResourceRecordSet": {
          "Name": "$instance.$DOMAIN_NAME",
          "Type": "A",
          "TTL": 300,
          "ResourceRecords": [{"Value": "$IP"}]
        }
      }]
    }
EOF
)"
done