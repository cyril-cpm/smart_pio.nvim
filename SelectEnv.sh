#!/bin/sh

pioInitFound=false

while  ! $pioInitFound ;
do
	if [ $PWD == '/' ]; then
		echo "Not in a platformio porject."
		exit
	fi

	if [ -f "platformio.ini" ]; then
		pioInitFound=true
	else
		cd ..
	fi
done

echo "platformio.ini found in $PWD"

root=$PWD

if [[ $(~/smart_pio.nvim/GetPioEnvList.sh | grep -wc "$1") -eq 1 ]]
then
	if [ ! -d "${root}/.smart_pio" ]; then
		echo "Creating .smart_pio folder"
		mkdir "${root}/.smart_pio"
	fi

	if [ ! -d "${root}/.smart_pio/${1}" ]; then
		mkdir "${root}/.smart_pio/${1}"
	fi

	if [ ! -f "$root}/.smart_pio/${1}/srcList" ]; then
		echo "$(ls ${root}/src ${root}/include)" > "${root}/.smart_pio/${1}/srcList.txt"
	fi

	if [ ! -f "${root}/.smart_pio/${1}/compile_commands.json" ]; then
		platformio run -t compiledb -e ${1} -d "${root}"
		mv "${root}/compile_commands.json" "${root}/.smart_pio/${1}/compile_commands.json"
	fi

	ln -f "${root}/.smart_pio/${1}/compile_commands.json" "${root}/compile_commands.json"
	echo "${1}" > "${root}/.smart_pio/envName.txt"
else
	echo "env $1 not found, see the list below :"
	echo $(~/smart_pio.nvim/GetPioEnvList.sh)
fi
