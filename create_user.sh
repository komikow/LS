#!/bin/bash
 
name=$1
surname=$2
group_name=$3

first_letter=$(echo "${name:0:1}" | tr '[:upper:]' '[:lower:]')			#Берёт первую букву имени (в нижнем регистре)
second_letter=$(echo "${surname}" | tr '[:upper:]' '[:lower:]')		#Прибавляет фамилию в нижнем регистре
login="${first_letter}${second_letter}"												#создание логина

uid=$RANDOM																				# генерация  uuid

sudo useradd -m $login -u $uid -g $group_name -c "$name $surname"

echo "Login: $login"
echo "Shell: $(getent passwd "$login" | cut -d: -f7)"
echo "Home dir: $(getent passwd "$login" | cut -d: -f6)"
echo "Groups: $(id -nG "$login")"
echo "UID: $(id -u "$login")"