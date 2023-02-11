#!/bin/bash -
# Jordy PROVOST - 2022

# See --help for usage.

# This script check folders in $MESA directory
# The user select the folder (=mesa version) he want to use
# The script create links in /usr/share/vulkan/icd.d/ to json in ${mesa_dir} (according to existing jsons or links)
# The script rewrite /etc/ld.so.conf.d/i386-linux-gnu.conf
# The script rewrite /etc/ld.so.conf.d/x86_64-linux-gnu.conf
# the script execute ldconfig
# the script create links to configuration files from ${mesa_dir} in /usr/share/drirc.d/
# The script display jsons links in /usr/share/vulkan/icd.d/ and their targets
# The script display content of /etc/ld.so.conf.d/i386-linux-gnu.conf
# The script display content of /etc/ld.so.conf.d/x86_64-linux-gnu.conf
# The script display content of /usr/share/drirc.d/
# The script executes "glxinfo | grep '^OpenGL' | grep version"

# Set the path of directory were you compile MESA versions (must contain one directory per compiled MESA version)
readonly mesa_dir="/usr/local/mesa"

# ----------------------------------------------------------------------------------------------------------------------------- #

# Required files to be used by the script
readonly ldso_x32_file="/etc/ld.so.conf.d/i386-linux-gnu.conf"
readonly ldso_x64_file="/etc/ld.so.conf.d/x86_64-linux-gnu.conf"
readonly arch_file="/var/lib/dpkg/arch"
readonly vulkan_icd_dir="/usr/share/vulkan/icd.d/"

# ----------------------------------------------------------------------------------------------------------------------------- #

function protect_empty_vars(){
        if [[ "${1}" == "on" ]];then
                set -o nounset
        elif [[ "${1}" == "off" ]];then
                set +o nounset
        fi
}
function exit_on_error(){
        if [[ "${1}" == "on" ]];then
                set -o errexit
                set -o pipefail
        elif [[ "${1}" == "off" ]];then
                set +o errexit
                set +o pipefail
        fi
}

# ----------------------------------------------------------------------------------------------------------------------------- #

function check_prerequisites(){
	if [[ ! -d "${mesa_dir}" ]];then
		echo "Directory ${mesa_dir} does not exist ! Exiting."
		exit 1
	fi
	if [[ ! -d "${vulkan_icd_dir}" ]];then
		echo "Directory ${vulkan_icd_dir} does not exist ! Exiting."
		exit 1
	fi
	if [[ ! -f "${arch_file}" ]];then
		echo "File ${arch_file} does not exist ! Exiting."
		exit 1
	fi
	if [[ ! -z $(grep -E "^i386$" ${arch_file}) ]];then
		if [[ ! -f "${ldso_x32_file}" ]];then
			echo "File ${ldso_x32_file} does not exist ! Exiting."
		fi
		readonly i386_arch="1"
	else
		readonly i386_arch="0"
	fi
	if [[ ! -z $(grep -E "^amd64$" ${arch_file}) ]];then
		if [[ ! -f "${ldso_x64_file}" ]];then
			echo "File ${ldso_x64_file} does not exist ! Exiting."
			exit 1
		fi
		readonly amd64_arch="1"
	else
		readonly amd64_arch="0"
	fi
	if [[ "${i386_arch}" == "0" ]]&&[[ "${amd64_arch}" == "0" ]];then
		echo "System architecture is not supported. Exiting."
		exit 1
	fi
}

function check_root(){
        if [[ "$(id -u)" != "0" ]];then
                echo "You must be root to run this script ! Exiting."
                exit 1
        fi
}

function get_mesa_versions(){
	readonly mesa_versions=$(ls ${mesa_dir} | tr ' ' '\n' | cat -n | sed 's/^ *//')
	# we dont use glxinfo because we want to display directories names !
	# if the current mesa version is not a compiled one, we dont display current version (nevermind)
	if [[ "${amd64_arch}" == "1" ]];then
		readonly current_mesa_version=$(grep -Ev '^#' ${ldso_x64_file} | head -n1 | sed "s@${mesa_dir}@@g" | awk -F'/' '{print $2}')
	elif [[ "${i386_arch}" == "1" ]];then
		readonly current_mesa_version=$(grep -Ev '^#' ${ldso_x32_file} | head -n1 | sed "s@${mesa_dir}@@g" | awk -F'/' '{print $2}')
	fi

	if [[ -z "${mesa_versions}" ]];then
		echo "There is no MESA version available. Exiting."
		exit
	fi

	if [[ ! -z "${current_mesa_version}" ]];then
		displayed_mesa_versions=$(echo "${mesa_versions}" | sed "s/${current_mesa_version}/${current_mesa_version} <-- Current Version/g" )
	else
		displayed_mesa_versions="${mesa_versions}"
	fi
	readonly mesa_versions_count=$(echo "${mesa_versions}" | wc -l)
}

function select_menu() {
	# Prompt user to select available MESA versions in ${mesa_dir}
	echo -e "\nAvailable MESA Versions :"
	echo -e "\n${displayed_mesa_versions}"
	echo -e "\nEnter the number of the MESA version you want to use (1-${mesa_versions_count}) : \c"
	read answer

	# Check if provided answer is a number
	case ${answer} in
    	''|*[!0-9]*) echo "\"${answer}\" is not a number ! Exiting."; exit 1 ;;
	esac

	# Check if provided number is in range
	if [[ "${answer}" -lt 1 ]]||[[ "${answer}" -gt "${mesa_versions_count}" ]]; then
    	echo "Selected number (${answer}) is out of range ! Exiting."
    	exit
	fi

	readonly mesa_selected=$(echo "${mesa_versions}" | sed "${answer}q;d" | awk -F' ' '{print $2}')
}

check_current_vs_new(){
	if [[ "${mesa_selected}" ==  "${current_mesa_version}" ]];then
		echo "${mesa_selected} is already the current version, nothing to do. Exiting."
		exit 0
	fi
}

function check_mesa_dir(){
	# check if directory exists
	if [[ ! -d "${mesa_dir}/${mesa_selected}" ]];then
		echo "Directory ${mesa_dir}/${mesa_selected} does not exist ! Exiting."
    	exit 1
	fi
	# check if ${mesa_dir}/${mesa_selected}/lib/x86_64-linux-gnu exist
	if [[ "${amd64_arch}" == "1" ]]&&[[ ! -d "${mesa_dir}/${mesa_selected}/lib/x86_64-linux-gnu" ]];then
		echo "Directory ${mesa_dir}/${mesa_selected}/lib/x86_64-linux-gnu does not exist ! Exiting."
    	exit 1
	fi
	# check if ${mesa_dir}/${mesa_selected}/lib/i386-linux-gnu exist
	if [[ "${i386_arch}" == "1" ]]&&[[ ! -d "${mesa_dir}/${mesa_selected}/lib/i386-linux-gnu" ]];then
		echo "${mesa_dir}/${mesa_selected}/lib/i386-linux-gnu does not exist ! Exiting."
    	exit 1
	fi
	# check if ${mesa_dir}/${mesa_selected}/share/vulkan/icd.d/ contains .json files
	if [[ -z $(find ${mesa_dir}/${mesa_selected}/share/vulkan/icd.d/ -type f -iname '*.json') ]];then
		echo "${mesa_dir}/${mesa_selected}/share/vulkan/icd.d/ does not contain any .json file. Exiting."
		exit 1
	fi
	# Check if ${mesa_dir}/${mesa_selected}/lib/i386-linux-gnu contains .so files
	if [[ "${i386_arch}" == "1" ]]&&[[ -z $(find ${mesa_dir}/${mesa_selected}/lib/i386-linux-gnu/ -maxdepth 1 \( -type l -o -type f \) -iname '*.so') ]];then
		echo "${mesa_dir}/${mesa_selected}/lib/i386-linux-gnu does not contain any .so file. Exiting."
		exit 1
	fi
	# Check if ${mesa_dir}/${mesa_selected}/lib/x86_64-linux-gnu contains .so files
	if [[ "${amd64_arch}" == "1" ]]&&[[ -z $(find ${mesa_dir}/${mesa_selected}/lib/x86_64-linux-gnu/ -maxdepth 1 \( -type l -o -type f \) -iname '*.so') ]];then
		echo "${mesa_dir}/${mesa_selected}/lib/x86_64-linux-gnu does not contain any .so file. Exiting."
		exit 1
	fi
}

function prompt_confirmation(){
	# Prompt user for confirmation
	echo -e "\nDo you want to activate MESA version ${mesa_selected} (y/n) : \c"
	read answer
	if [[ "${answer}" != "y" ]];then
		echo "Change canceled. Exiting."
		exit 0
	fi
}

function setup_icd(){
	# Create links in /usr/share/vulkan/icd.d/
	echo -e "\nCreating links from ${mesa_dir}/${mesa_selected}/share/vulkan/icd.d/ jsons in ${vulkan_icd_dir}."
	cd "${vulkan_icd_dir}"
	for json in $(ls "${vulkan_icd_dir}" | tr ' ' '\n' | grep -E '.json$');do
		if [[ -f "${mesa_dir}/${mesa_selected}/share/vulkan/icd.d/${json}" ]];then
			rm -f ${json}
			ln -snf ${mesa_dir}/${mesa_selected}/share/vulkan/icd.d/${json}
		else
			echo "ERROR : ${mesa_dir}/${mesa_selected}/share/vulkan/icd.d/${json} not found."
		fi
	done
}

function setup_ldso_x64(){
	# Rewrite /etc/ld.so.conf.d/x86_64-linux-gnu.conf
	echo -e "\nInstalling amd64 MESA ${mesa_selected} in ${ldso_x64_file}"
	cat > "${ldso_x64_file}"<< EOF
# Generated by $(basename ${0})
${mesa_dir}/${mesa_selected}/lib/x86_64-linux-gnu
/usr/local/lib/x86_64-linux-gnu
/lib/x86_64-linux-gnu
/usr/lib/x86_64-linux-gnu
EOF
}

function setup_ldso_x32(){
	# Rewrite /etc/ld.so.conf.d/i386-linux-gnu.conf
	echo -e "\nInstalling i386 MESA ${mesa_selected} in ${ldso_x32_file}"
	cat > "${ldso_x32_file}"<< EOF
# Generated by $(basename ${0})
${mesa_dir}/${mesa_selected}/lib/i386-linux-gnu
/usr/local/lib/i386-linux-gnu
/lib/i386-linux-gnu
/usr/lib/i386-linux-gnu
/usr/local/lib/i686-linux-gnu
/lib/i686-linux-gnu
/usr/lib/i686-linux-gnu
EOF
}

function setup_ld(){
	if [[ "${amd64_arch}" == "1" ]];then setup_ldso_x64 ;fi
	if [[ "${i386_arch}" == "1" ]];then setup_ldso_x32 ;fi
	ldconfig
}

function setup_drirc(){
	echo -e "\nCopying drirc configuration files from MESA ${mesa_selected} in /usr/share/drirc.d/"
	find /usr/share/drirc.d/ -maxdepth 1 \( -type l -o -type f \) -exec rm -f {} \;
	readonly mesa_drirc_dir="${mesa_dir}/${mesa_selected}/share/drirc.d"
	for file in $(ls ${mesa_drirc_dir});do ln -snf ${mesa_drirc_dir}/${file} /usr/share/drirc.d/${file} ;done
}

function display_config(){
	echo -e "\n########################## Summary ##########################"

	echo -e "\nFile ${ldso_x64_file} :"
	cat ${ldso_x64_file}

	echo -e "\nFile ${ldso_x32_file} :"
	cat "${ldso_x32_file}"

	echo -e "\nFolder ${vulkan_icd_dir} (.json only) :"
	for json in $(ls "${vulkan_icd_dir}" | tr ' ' '\n' | grep -E '.json$');do
		echo "${json} -> $(readlink ${json})"
	done

	echo -e "\nDrirc configuration files in /usr/share/drirc.d/ :"
	ls -l /usr/share/drirc.d/ | grep -E '.conf$'

	echo -e "\nMESA Version"
	glxinfo | grep '^OpenGL' | grep version
	echo -e "\n"
}

function display_help(){
cat << EOHD
Usage: $(basename ${0}) [OPTION]...
This tool is intended to switch from compiled MESA versions from ${mesa_dir} on a i386/amd64 Debian system.
Versions of MESA are not build versions, but the name of sudirectories you put under ${mesa_dir}.

Options which require arguments take their arguments immediately following the option, separated by white space.

Arguments:
	-f, --force                 dont ask for confirmation
	-h, --help                  print Help (this message) and exit
	-m, --mesa                  indicate Mesa version to use (must be the name of a directory under ${mesa_dir})
	-u, --update                force the change even if you have selected the same version as the current one
	-v, --version               print version information and exit

EOHD
exit
}

function main(){
	protect_empty_vars on
	exit_on_error on
	check_root
	check_prerequisites
	get_mesa_versions
	if [[ -z "${mesa_selected}" ]];then select_menu ;fi
	if [[ "${force_update}" == "0" ]];then check_current_vs_new ;fi
	check_mesa_dir
	if [[ "${confirmation_needed}" == "1" ]];then prompt_confirmation ;fi
	setup_icd
	setup_ld
	setup_drirc
	display_config
}

# We dont want to be abused by malicious PATH
PATH="/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin"

# handle arguments passed to script (without using getopts for compatibility purposes)
readonly script_path="${0}"
readonly script_version="0.1"
confirmation_needed="1"
force_update="0"
mesa_selected=""

if [ -z "${1}" ];then main && exit;fi

while [[ "${#}" -ge 1 ]]
do
key="${1}"
case "${key}" in
	-m|--mesa)
		mesa_selected="${2}"
		shift 2
		;;
	-f|--force)
		confirmation_needed="0"
		shift 1
		;;
	-h|--help)
		display_help && exit
		shift 1
		;;
	-u|--update)
		force_update="1"
		shift 1
 		;;
	-v|--version)
		echo "$(basename ${script_path}) version ${script_version}" && exit
		shift 1
 		;;
	*)
		echo -e "Unknown option \"$key\". Use \"$(basename ${0}) -h\" or \"$(basename ${0}) --help\" for more information.\n"
		display_help
		exit
		;;
esac
done

