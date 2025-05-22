#!/bin/bash
source ./common.sh
app_name=mysql

check_root

dnf install mysql-server -y &>> $LOG_FILE
VALIDATE $? "installing my sql server"

systemctl enable mysqld &>> $LOG_FILE
VALIDATE $? "enable sql server"

systemctl start mysqld &>> $LOG_FILE
VALIDATE $? "starting my sql server"

echo -e "$G please enter mysql Password: $N"
read -s $MYSQL_ROOT_PASSWORD 

mysql_secure_installation --set-root-pass $MYSQL_ROOT_PASSWORD &>>$LOG_FILE
print_time