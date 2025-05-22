#!/bin/bash
 source ./common.sh
app_name=mongodb
check_root
cp mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOG_FILE
VALIDATE $? "copying mongodb repos"
dnf install mongodb-org -y &>> $LOG_FILE
VALIDATE $? "installing mongoDB"

systemctl enable mongod &>> $LOG_FILE
VALIDATE $? "enabling mongo service"
systemctl start mongod &>> $LOG_FILE
VALIDATE $? "starting mongo service"
sed -i 's/127.0.0.1/0.0.0.0/g' /etc//mongod.conf
systemctl restart mongod &>> $LOG_FILE
VALIDATE $? "re starting monogoDB service"
print_time