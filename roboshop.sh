#!/bin/bash

AMI_ID="ami-0220d79f3f480ecf5"
SG_ID="sg-08bc7d23acfac1667"
ZONE_ID="Z03710831AO6BKS1FD2S7"
DOMAIN_NAME="udaykiran.site"


for instance in "$@"
do 
    echo "processing : $instance"
    # CHECK IF INSTANCE EXISTS
    # -----------------------------
    INSTANCE_ID=$(aws ec2 describe-instances \
        --filters "Name=tag:Name,Values=$instance" \
                  "Name=instance-state-name,Values=running,pending,stopped" \
        --query 'Reservations[0].Instances[0].InstanceId' \
        --output text 2>/dev/null)

    if [ "$INSTANCE_ID" == "None" ] || [ -z "$INSTANCE_ID" ]; then
        echo "Creating instance: $instance"
    


        INSTANCE_ID=$(aws ec2 run-instances \
        --image-id $AMI_ID \
        --instance-type t3.micro \
        --security-group-ids $SG_ID \
        --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
        --query 'Instances[0].InstanceId' \
        --output text) 

   

    # Wait until instance is running
    aws ec2 wait instance-running --instance-ids $INSTANCE_ID
    else
        echo "Instance already exists: $INSTANCE_ID"
    fi

    echo "Instance ID: $INSTANCE_ID"
    # Get IP
    if [ "$instance" != "frontend" ]; then
        IP=$(aws ec2 describe-instances \
            --instance-ids $INSTANCE_ID \
            --query 'Reservations[0].Instances[0].PrivateIpAddress' \
            --output text)
    else
        IP=$(aws ec2 describe-instances \
            --instance-ids $INSTANCE_ID \
            --query 'Reservations[0].Instances[0].PublicIpAddress' \
            --output text)
    fi

    echo "$instance : $IP"


# ZONE_ID=$(aws route53 create-hosted-zone \
#   --name udaykiran.site \
#   --caller-reference "$(date +%s)" \
#   --hosted-zone-config Comment="Public Hosted Zone",PrivateZone=false \
#   --query 'HostedZone.Id' \
#   --output text | cut -d'/' -f3)

# echo $ZONE_ID




RECORD_NAME="${instance}.${DOMAIN_NAME}"
aws route53 change-resource-record-sets \
  --hosted-zone-id $ZONE_ID \
  --change-batch '{
    "Changes": [
      {
        "Action": "UPSERT",
        "ResourceRecordSet": {
          "Name": "'$RECORD_NAME'",
          "Type": "A",
          "TTL": 1,
          "ResourceRecords": [
            {
              "Value": "'$IP'"
            }
          ]
        }
      }
    ]
  }'

  
done