#!/bin/sh

root=$(sh ~/smart_pio.nvim//FindPioIni.sh)

if [ $root = '/' ]; then
	echo -n "platformio.ini not found"
	exit 1
fi

if [ -f "${root}/.smart_pio/envName.txt" ]; then
	echo -n $(cat "${root}/.smart_pio/envName.txt")
else
	echo -n "No env selected"
fi
