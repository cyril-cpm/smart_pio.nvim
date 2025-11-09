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

	idedata=$(platformio run -t idedata -e ${1} | jq --raw-input '. | fromjson?')
	toolchainPath=$(dirname $(dirname $(echo $idedata | jq '.cxx_path' | grep -Po '[^"]*')))
	echo $toolchainPath
	target="xtensa-esp32-elf"
	sysroot="-isysroot=/home/cpm/.platformio/packages/toolchain-xtensa-esp-elf/xtensa-esp-elf"
	echo $sysroot
	toolchain=$(echo $idedata | jq --arg sysroot $sysroot '
								[$sysroot]
								+ ["-isystem" + .includes.toolchain.[]]
								+ ["-I" + .includes.build.[]]
								')
	includes=$(echo $idedata | jq '["-I" + .includes.build.[]]')
	includes=$(echo $includes)
	echo -e "
Diagnostics:
	Suppress: [
		\"-Wvla-cxx-extension\",
		\"member_function_call_bad_type\",
		\"unknown_typename\",
		\"redefinition_different_typedef\",
		\"pp_file_not_found\",
		\"init_conversion_failed\",
		\"typecheck_convert_incompatible_pointer\"
		]
	UnusedIncludes: None

CompileFlags:
	CompilationDatabase: \"${root}/.pio/build/${1}\"
	Add: $toolchain
	Remove: [\"-fno-shrink-wrap\", \"-fno-tree-switch-conversion\", \"-fstrict-volatile-bitfields\", \"-mlongcalls\"]
" > "${root}/.clangd"

if [[ ! -z $PLATFORMIO_INSTALL_ROOT ]]; then
	
	echo -e "
Diagnostics:
	Suppress: [\"*\"]
	UnusedIncludes: None

CompileFlags:
	CompilationDatabase: \"${root}/.pio/build/${1}\"
	Add: $toolchain
	Remove: [\"-fno-shrink-wrap\", \"-fno-tree-switch-conversion\", \"-fstrict-volatile-bitfields\", \"-mlongcalls\"]
" > "${PLATFORMIO_INSTALL_ROOT}/.clangd"
fi

else
	echo "env $1 not found, see the list below :"
	echo $(~/smart_pio.nvim/GetPioEnvList.sh)
fi
