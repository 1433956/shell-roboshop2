#!/bin/bash
 source ./common.sh
 app_name=shipping

 check_root
 app_setup
 maven_setup
 system_setup

 dnf install mysql -y &>>$LOG_FILE
 echo "Please enter root password to setup"
 read -s MYSQL_ROOT_PASSWORD
 VALIDATE $? "installing my sql"

 
mysql -h mysql.devops73.site -uroot -p$MYSQL_ROOT_PASSWORD -e 'use cities' &>>$LOG_FILE
if [ $? -ne 0 ]
then
    mysql -h mysql.devops73.site -uroot -p$MYSQL_ROOT_PASSWORD < /app/db/schema.sql &>>$LOG_FILE
    mysql -h mysql.devops73.site -uroot -p$MYSQL_ROOT_PASSWORD < /app/db/app-user.sql  &>>$LOG_FILE
    mysql -h mysql.devops73.site -uroot -p$MYSQL_ROOT_PASSWORD < /app/db/master-data.sql &>>$LOG_FILE
    VALIDATE $? "Loading data into MySQL"
else
    echo -e "Data is already loaded into MySQL ... $Y SKIPPING $N"
fi

systemctl restart shipping &>>$LOG_FILE
VALIDATE $? "Restart shipping"

print_time