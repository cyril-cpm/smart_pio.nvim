#!/bin/sh

pioInitFound=false

while  ! $pioInitFound ;
do
	if [ $PWD == '/' ]; then
		echo "/"
		exit 1
	fi

	if [ -f "platformio.ini" ]; then
		pioInitFound=true
	else
		cd ..
	fi
done

echo "$PWD"
