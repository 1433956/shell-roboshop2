#!/bin/bash

source ./common.sh
app_name=catalogue

check_root
app_setup
nodejs_setup
system_setup

cp $SYS_DIR/mongo.repo /etc/yum.repos.d/mongo.repo

dnf install mongodb-mongosh -y &>>$LOG_FILE
VALIDATE $? "installing mongodb"

STATUS=$(mongosh --host mongodb.devops73.site --eval 'db.getMongo().getDBNames().indexOf("catalogue")')

if [ $STATUS -lt 0 ]
then
    mongosh --host mongodb.devosp73.site </app/db/master-data.js &>>$LOG_FILE
    VALIDATE $?"loading data"
else
    echo -e "Data is already loaded ... $Y SKIPPING $N"
fi

print_time



