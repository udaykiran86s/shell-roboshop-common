#!/bin/bash

#set -e
set -euo pipefail
source ./common.sh
app_name=shipping

check_root
app_setup
java_setup
systemd_setup
MYSQL_HOST=mysql.udaykiran.site
dnf install mysql -y  &>>$LOG_FILE
 
MYSQL_HOST=${MYSQL_HOST:-mysql.udaykiran.site}
MYSQL_PASS="RoboShop@1"

if mysql -h $MYSQL_HOST -uroot -p"$MYSQL_PASS" -e "use cities" &>>$LOG_FILE; then
    echo -e "Shipping data is already loaded ... $y SKIPPING $n"
else
    mysql -h $MYSQL_HOST -uroot -p"$MYSQL_PASS" < /app/db/schema.sql &>>$LOG_FILE
    mysql -h $MYSQL_HOST -uroot -p"$MYSQL_PASS" < /app/db/app-user.sql &>>$LOG_FILE
    mysql -h $MYSQL_HOST -uroot -p"$MYSQL_PASS" < /app/db/master-data.sql &>>$LOG_FILE
fi
# mysql -h $MYSQL_HOST -uroot -pRoboShop@1 -e 'use cities' &>>$LOG_FILE
# if mysql -h $MYSQL_HOST -uroot -p"$MYSQL_PASS" -e "use cities" &>>$LOG_FILE; then
# if [ $? -ne 0 ]; then
#     mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/schema.sql &>>$LOG_FILE
#     mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/app-user.sql  &>>$LOG_FILE
#     mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/master-data.sql &>>$LOG_FILE
# else
#     echo -e "Shipping data is already loaded ... $Y SKIPPING $N"
# fi

app_restart
print_total_time