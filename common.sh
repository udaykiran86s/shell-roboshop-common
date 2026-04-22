#!/bin/bash
#set -euo pipefail
# trap 'echo "there is an erro in $LINED ,command is $bash_command"' ERR
USERID=$(id -u)
r="\e[31m"
g="\e[32m"
y="\e[33m"
n="\e[0m"

LOGS_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1)
SCRIPT_DIR=$PWD
START_TIME=$(date +%s)
MONGO_HOST=mongo.udaykiran.site
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
mkdir -p $LOGS_FOLDER

echo "Script started executed at: $(date)"  | tee -a $LOG_FILE

check_root(){

if [ $USERID -ne 0 ];then
     echo "please run with root user"
     exit 1
fi
}

VALIDATE() {
    if [ $1 -ne 0 ]; then
        echo -e "$2..... $r failed $n" | tee -a $LOG_FILE
        exit 1
    else 
        echo -e "$2 is....   $g success $n" | tee -a $LOG_FILE
    fi
}

nodejs_setup(){

### NodeJS ####
    dnf module disable nodejs -y &>>$LOG_FILE
    VALIDATE $? "Disabling NodeJS"

    dnf module enable nodejs:20 -y&>>$LOG_FILE
    VALIDATE $? "Enabling NodeJS 20"

    dnf install nodejs -y
    VALIDATE $? "Installing NodeJS"

    npm install &>>$LOG_FILE
    VALIDATE $? "Install dependencies"

}

app_setup(){


    id roboshop &>>$LOG_FILE
    if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    VALIDATE $? "Creating system user"
    else
        echo -e "User already exist ... $Y SKIPPING $N"
    fi
    
    mkdir /app 
    VALIDATE $? "Creating app directory"

    curl -o /tmp/$app_name.zip https://roboshop-artifacts.s3.amazonaws.com/$app_name-v3.zip 
    VALIDATE $? "Downloading $app_name application"

    cd /app 
    VALIDATE $? "Changing to app directory"

    rm -rf /app/*
    VALIDATE $? "Removing existing code"

    unzip /tmp/$app_name.zip
    VALIDATE $? "unzip $app_name"
    
}

systemd_setup(){


    cp $SCRIPT_DIR/$app_name.service /etc/systemd/system/$app_name.service
    VALIDATE $? "Copy systemctl service"

    systemctl daemon-reload

    systemctl enable $app_name  &>>$LOG_FILE
    VALIDATE $? "Enable $app_name"
}

app_restart(){
systemctl restart $app_name
VALIDATE $? "Restarted $app_name"

}


print_total_time=(){
    END_TIME=$(date +%s)
    TOTAL_TIME=(( $END_TIME - $START_TIME))
    echo -e "script executed in :  $y $TOTAL_TIME Seconds $n"