#!/bin/bash

read -p "enter  Artist and I will find all the songs: " artist

if [ -z "$artist" ]
    then
    printf "Come back when you have something, dumbass.\n"
    exit;
fi

cd "/home/scott/Music"

find "${PWD}" -iname "*$artist*" -type d -print |  while read filename; 

do
# printf "\n$filename\n"
   find "$filename" -not -path '*/\.*' -type f -print 
 done

