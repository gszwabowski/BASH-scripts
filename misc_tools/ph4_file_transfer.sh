#!/bin/bash

i=0

while [ $i -le 9 ]

do 
	read -p "Enter the ph4 number you would like to move: " arg1
	cp $arg1.ph4 ..
	let i=i+1
	
if [ $i -eq 10 ]
    then
    echo Done.
fi

done
