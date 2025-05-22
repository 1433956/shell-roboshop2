#!/bin/bash
start_time=$(date +%s)
userid=$(id -u)
#status_codes
R="\e[31m"
Y="\e[33m"
G="\e[32m"
N="\e[0m"

#default paths
LOG_FOLDER="/usr/log/roboshop-logs"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE=$LOG_FOLDER/$SCRIPT_NAME.log

#Folder creation
mkdir -p $LOG_FOLDER
SYS_DIR=$PWD
#script execution time
echo -e "$G Script started at :: $(date) $N" | tee -a $LOG_FILE

#app_setup and project_setup
 app_setup() {
 id roboshop

 if [ $? -ne 0 ]
 then
      echo -e "$R initiated system user creation $N " &>>$LOG_FILE
      useradd --system --home /app --shell /sbin/nologin --comment "creating sysytem user" roboshop
       VALIDATE $? "created system user"
else
     echo -e "$G System user is created $N"&>>$LOG_FILE
fi

mkdir -p /app
VALIDATE $? "creating app directory"
 
 curl -o /tmp/$app_name.zip https://roboshop-artifacts.s3.amazonaws.com/$app_name-v3.zip &>>$LOG_FILE
 VALIDATE $? "Downloading project"

rm -rf /app/*

cd /app

unzip /tmp/$app_name.zip &>> $LOG_FILE 
VALIDATE $? "extracting $app_name project"

}

#nodejs_setup

nodejs_setup() {

    dnf module disable nodejs -y &>>$LOG_FILE
    VALIDATE $? "disabling Nodejs"

    dnf module enable nodejs:20 -y &>>$LOG_FILE
    VALIDATE $? "enabling version:nodejs-20"
    dnf install nodejs -y &>>$LOG_FILE
    VALIDATE $? "installing nodejs"
    npm install &>>$LOG_FILE
    VALIDATE $? "installing nodejs depedencies"

}
#maven_setup
maven_setup() {
    dnf install maven -y &>>$LOG_FILE
    VALIDATE $? "installing maven"
    mvn clean package &>>$LOG_FILE
    VALIDATE $? "minstalling maven depdedencies"
    mv /target/shipping-1.0.jar shipping.jar &>>$LOG_FILE
    VALIDATE $? "renaming jar file"
}
#python_setup

python_setup() {

   dnf install python3 gcc python3-devel -y &>>$LOG_FILE
   VALIDATE $? "installing python 3"
   pip3 install requirements.txt &>>$LOG_FILE
   VALIDATE $? "Installing dependencies"
   cp $SYS_DIR/payment.service /etc/systemd/system/payment.service &>>$LOG_FILE
   VALIDATE $? "copying payment service" 

}

#system-setup

system_setup() {

    cp $SYS_DIR/$app_name.service /etc/systemd/system/$app_name.service &>>$LOG_FILE
    VALIDATE $? "copying $app_name service"

    systemctl daemon-reload &>> $LOG_FILE
    systemctl enable $app_name &>>$LOG_FILE
    VALIDATE $? "enabling $app_name service" 
    systemctl start $app_name &>> $LOG_FILE

}

#check Root

check_root() {

    if [ $userid -ne 0 ]
    then 
        echo -e "$R ERROR:: Please run this script with root access $N" | tee -a $LOG_FILE
        exit 1

    else 
        echo -e "$G  Logged as as root user" | tee -a $LOG_FILE
    fi
}

VALIDATE() {

    if [ $1 -eq 0 ]
    then 
         echo -e "$2 is ... $G SUCCESS $N" | tee -a $LOG_FILE
    else
         echo -e " $2 is .. $R Failed $N" | tee -a $LOG_FILE 
         exit 1
    fi
}

print_time() {

    end_time=$(date +%s)
    total_time=$(($end_time - $start_time))

    echo -e "Script executed successfully, $Y Time taken: $total_time seconds $N "
}