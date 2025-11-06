#!/bin/sh


root=$(sh ~/smart_pio.nvim/FindPioIni.sh)

if [[ $root == '/' ]]; then
	echo "platformio.ini not found"
	exit 1
fi


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
