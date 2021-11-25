#!/bin/bash

####### Colours

green="\e[0;32m\033[1m"
red="\e[0;31m\033[1m"
blue="\e[0;34m\033[1m"
end="\033[0m\e[0m"

####### Input message

read -p "Enter client to delete: " NUM

read -p "Are you sure? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1

####### Delete client containers

if [[ $NUM == [aA] ]]; then
    sleep 0.2
    echo -e "${blue}[+]${end} Deleting containers..."
    sleep 0.2
    for i in $(docker ps -aq -f "name=client" | tail -n +1); do
	docker stop $i && docker rm $i
	sleep 0.2
    done
    echo -e "${green}[+]${end} Deleting client folders..."
    rm -rf ./clients_nextcloud/client*

####### Error message

elif [[ $NUM == [b-zB-Z] ]]; then
    echo -e "${red}[+]${end} Not a valid option"
    sleep 0.2
    exit 1

####### Delete specific container

else
    echo -e "${blue}[+]${end} Deleting container..."
    docker stop client_nextcloud$NUM && docker rm client_nextcloud$NUM
    docker stop client_db$NUM && docker rm client_db$NUM
    sleep 0.2
    echo -e "${green}[+]${end} Deleting client folder..."
    sleep 0.2
    rm -rf ./clients_nextcloud/client$NUM
fi
