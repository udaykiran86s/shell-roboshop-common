#!/bin/bash
app_name="mongo"
source ./common.sh
check_root

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo

dnf install mongodb-org -y &>>$LOG_FILE

systemctl enable mongod &>>$LOG_FILE
systemctl start mongod &>>$LOG_FILE

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf

systemctl restart mongod &>>$LOG_FILE

echo "MongoDB setup completed successfully" | tee -a $LOG_FILE

app_restart
print_total_time