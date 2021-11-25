#!/bin/bash

####### Number of nextcloud containers

num = $(docker ps | awk '{print $2}' | tail -n +2 | grep "nextcloud" | wc -l)

####### Input data

read -p "Enter port to expose: " PORT

read -p "Confirm port $PORT? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1

read -p "Enter database port: " DB

read -p "Confirm port $DB? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1

echo "Number of Nextcloud containers: $num"

nownum = $(echo $num + 1 | bc)

####### Output message

sleep 0.2

echo "[+] Creating docker-compose.yaml..."

####### Creation of docker-compose.yaml file

cat << EOF > /tmp/docker-compose.yaml
version: '2'

volumes:
  nextcloud$nownum:
  db$nownum:

services:
  db_$nownum:
    image: mariadb
    container_name: client_db$nownum
    restart: always
    command: --transaction-isolation=READ-COMMITTED --binlog-format=ROW
    volumes:
      - ./clients_nextcloud/client$nownum/db$nownum:/var/lib/mysql
    ports:
      - $DB:3306
    environment:
      - MYSQL_ROOT_PASSWORD=<password>
      - MYSQL_PASSWORD=<password>
      - MYSQL_DATABASE=db_nextcloud
      - MYSQL_USER=root

  app_$nownum:
    image: nextcloud
    container_name: client_nextcloud$nownum
    restart: always
    ports:
      - $PORT:80
      - 8743:443
    links:
      - db_$nownum
    volumes:
      - ./clients_nextcloud/client$nownum/nextcloud$nownum:/var/www/html
      - ./clients_nextcloud/apache_conf:/etc/apache2/sites-available         #### Apache2 config (not necessary)
      - ./clients_nextcloud/certs/letsencrypt:/etc/letsencrypt               #### Copy the letsencrypt folder from your host to your clients folder
      - ./clients_nextcloud/certs/script:/root/script                        #### Script for letsencrypt certificate
    environment:
      - MYSQL_PASSWORD=<password>
      - MYSQL_DATABASE=db_nextcloud
      - MYSQL_USER=root
      - MYSQL_HOST=db_$nownum
EOF

####### Output message

sleep 0.2

echo "[+] Setting up nextcloud..."

####### Set up containers

docker-compose -f /tmp/docker-compose.yaml up -d
