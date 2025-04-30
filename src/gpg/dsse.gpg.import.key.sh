#!/bin/bash
set +x
# shellcheck enable=require-variable-braces
# file name: dsse.gpg.import.key.sh
# -- Start of boilerplate --
printf "\033c"
################################################################################
# License                                                                      #
################################################################################

function license() {
    printf "${DARK_GREY}%s${RESET}\n" ""
    printf "${DARK_GREY}%s${RESET}\n" " Apache License Version 2.0, January 2004"
    printf "${DARK_GREY}%s${RESET}\n" " Copyright (c) 2025 Werkstatt 72, LLC."
    printf "${DARK_GREY}%s${RESET}\n" " Author: Volker Scheithauer"
    printf "${DARK_GREY}%s${RESET}\n" " E-Mail: "
    printf "${DARK_GREY}%s${RESET}\n" ""
    printf "${DARK_GREY}%s${RESET}\n" " http://www.apache.org/licenses/"
    printf "${DARK_GREY}%s${RESET}\n" ""
    printf "${DARK_GREY}%s${RESET}\n" " This program is distributed in the hope that it will be useful,"
    printf "${DARK_GREY}%s${RESET}\n" " but WITHOUT ANY WARRANTY; without even the implied warranty of"
    printf "${DARK_GREY}%s${RESET}\n" " MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the"
    printf "${DARK_GREY}%s${RESET}\n" " Apache License Version 2.0 for more details."
    printf "${DARK_GREY}%s${RESET}\n" ""
}
################################################################################
# End of license
################################################################################

# Logging function
log_entry() {
    local key="$1"
    local value="$2"
    local level="${PROJECT_LOG_LEVEL}"
    # shellcheck disable=SC2034 # this is intentionals
    SCRIPT_CMD_LOG=$(echo "$(date '+[%Y-%m-%d %H:%M:%S,000]') [${CLASS_NAME}] [${level}] ${key}: ${value}" | tee -a "${LOG_FILE}")

}

log_with_timestamp() {
    local level="$1"
    local message="$2"
    local header="${API_ACTION:-UNKNOWN_ACTION}"
    # shellcheck disable=SC2034 # this is intentionals
    SCRIPT_CMD_LOG=$(echo "${message}" | while IFS= read -r line; do
        echo "$(date '+[%Y-%m-%d %H:%M:%S,000]') [${CLASS_NAME}] [${level}] [${header}] ${line}"
    done | tee -a "${LOG_FILE}")
}

# Get current script folder
# shellcheck disable=SC2046 # this is intentional
DIR_NAME=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
DIR_NAME_PARENT=$(dirname "${DIR_NAME}")

# compute working dir
# check if write permission
if [ -w "${DIR_NAME_PARENT}" ]; then
    WORKING_DIR="${DIR_NAME_PARENT}/proclog"
else
    WORKING_DIR="/tmp/data"
fi

# create working directory
if [ ! -d "${WORKING_DIR}" ]; then
    mkdir -p "${WORKING_DIR}"
fi

# compute config dir
CONFIG_DIR="${DIR_NAME_PARENT}/data"

# shellcheck disable=SC2034 # this is intentional
SCRIPT_DATA_FILE="${CONFIG_DIR}/data.json"

# Reset Colors
# shellcheck disable=SC2034 # this is intentional
Color_Off='\033[0m' # Text Reset

# Regular Colors
# shellcheck disable=SC2034 # this is intentional
BLUE="\033[0;34m"
# shellcheck disable=SC2034 # this is intentional
LIGHT_BLUE="\033[0;94m"
# shellcheck disable=SC2034 # this is intentional
CYAN="\033[0;36m"
# shellcheck disable=SC2034 # this is intentional
LIGHT_CYAN="\033[0;96m"
# shellcheck disable=SC2034 # this is intentional
YELLOW="\033[0;33m"
# shellcheck disable=SC2034 # this is intentional
ORANGE="\033[0;91m"
# shellcheck disable=SC2034 # this is intentional
RESET="\033[0m"
# shellcheck disable=SC2034 # this is intentional
DARK_GREY="\033[1;30m"

# shellcheck disable=SC2034 # this is intentional
Black='\033[0;30m' # Black
# shellcheck disable=SC2034 # this is intentional
Red='\033[0;31m' # Red
# shellcheck disable=SC2034 # this is intentional
Green='\033[0;32m' # Green
# shellcheck disable=SC2034 # this is intentional
Yellow='\033[0;33m' # Yellow
# shellcheck disable=SC2034 # this is intentional
Blue='\033[0;34m' # Blue
# shellcheck disable=SC2034 # this is intentional
Purple='\033[0;35m' # Purple
# shellcheck disable=SC2034 # this is intentional
Cyan='\033[0;36m' # Cyan
# shellcheck disable=SC2034 # this is intentional
White='\033[0;37m' # White

# Bold
# shellcheck disable=SC2034 # this is intentional
BBlack='\033[1;30m' # Black
# shellcheck disable=SC2034 # this is intentional
BRed='\033[1;31m' # Red
# shellcheck disable=SC2034 # this is intentional
BGreen='\033[1;32m' # Green
# shellcheck disable=SC2034 # this is intentional
BYellow='\033[1;33m' # Yellow
# shellcheck disable=SC2034 # this is intentional
BBlue='\033[1;34m' # Blue
# shellcheck disable=SC2034 # this is intentional
BPurple='\033[1;35m' # Purple
# shellcheck disable=SC2034 # this is intentional
BCyan='\033[1;36m' # Cyan
# shellcheck disable=SC2034 # this is intentional
BWhite='\033[1;37m' # White

# High Intensity
# shellcheck disable=SC2034 # this is intentional
IBlack='\033[0;90m' # Black
# shellcheck disable=SC2034 # this is intentional
IRed='\033[0;91m' # Red
# shellcheck disable=SC2034 # this is intentional
IGreen='\033[0;92m' # Green
# shellcheck disable=SC2034 # this is intentional
IYellow='\033[0;93m' # Yellow
# shellcheck disable=SC2034 # this is intentional
IBlue='\033[0;94m' # Blue
# shellcheck disable=SC2034 # this is intentional
IPurple='\033[0;95m' # Purple
# shellcheck disable=SC2034 # this is intentional
ICyan='\033[0;96m' # Cyan
# shellcheck disable=SC2034 # this is intentional
IWhite='\033[0;97m' # White

# Script defaults
# shellcheck disable=SC2034 # this is intentional
retcode=0
# shellcheck disable=SC2034 # this is intentional
SETUP_DIR="${DIR_NAME_PARENT}"
# shellcheck disable=SC2034 # this is intentional
SUDO_STATE="false"
# shellcheck disable=SC2116 disable=SC2034 # this is intentional
SCRIPT_SHELL=$(echo "${SHELL}")

# hostname is assumed to be a FQDN set during installation.
# shellcheck disable=SC2006 disable=SC2086 disable=SC2034 # this is intentional
HOST_FQDN=$(hostname -f)
# shellcheck disable=SC2006 disable=SC2086 disable=SC2034 # this is intentional
HOST_NAME=$(echo ${HOST_FQDN} | awk -F "." '{print $1}')
# shellcheck disable=SC2006 disable=SC2086 disable=SC2034 # this is intentional
DOMAIN_NAME=$(echo ${HOST_FQDN} | awk -F "." '{print $2"."$3}')

# CTM Agent specific variables
# shellcheck disable=SC2006 disable=SC2086 disable=SC2034 # this is intentional
ZZM_CONTROLM_PROCLOG=$(env | grep "CONTROLM_PROCLOG" | awk -F "=" '{print $2}')

# logging configuration
# requires script variables
DATE_TODAY="$(date '+%Y-%m-%d %H:%M:%S')"
# shellcheck disable=SC2116 disable=SC2034 # this is intentional
LOG_DATE=$(date +%Y%m%d)
PROJECT_LOG_LEVEL="INFO"

# Compute log folder
if [ -z "${ZZM_CONTROLM_PROCLOG}" ]; then
    LOG_DIR="${WORKING_DIR}/zzm"
else
    LOG_DIR="${ZZM_CONTROLM_PROCLOG}/zzm"
fi

if [ ! -d "${LOG_DIR}" ]; then
    mkdir -p "${LOG_DIR}"
fi

# shellcheck disable=SC2006 disable=SC2086# this is intentional
LOG_NAME=$(basename $0)

# AWS Project log
LOG_NAME="gpg"

LOG_FILE="${LOG_DIR}/${LOG_NAME}.log"
if [[ ! -f "${LOG_FILE}" ]]; then
    log_entry "Init Log File" "'${LOG_FILE}'"
fi

# Linux Distribution
OS_NAME=$(uname -s)

if [[ "$OS_NAME" == "Darwin" ]]; then
    # macOS
    DISTRIBUTION="macOS"
    DISTRIBUTION_PRETTY_NAME=$(sw_vers -productName) # This will return "Mac OS X" for older versions or "macOS" for newer versions
    USER_NAME=$(whoami)
    HOST_IPV4=$(ifconfig | grep -v "127.0.0" | grep "inet " | awk '{print $2}' | head -n 1)

else
    # Assuming Linux for other cases
    # shellcheck disable=SC2116 disable=SC2034 # this is intentional
    DISTRIBUTION=$(cat /etc/*-release | uniq -u | grep "^NAME" | awk -F "=" '{ gsub("\"", "",$2); print $2}')
    DISTRIBUTION_PRETTY_NAME=$(cat /etc/*-release | uniq -u | grep "^PRETTY_NAME" | awk -F "=" '{ gsub("\"", "",$2); print $2}')
    # shellcheck disable=SC2116 # this is intentionals
    USER_NAME=$(whoami)
    # shellcheck disable=SC2034 # this is intentionals
    USER_HOME=$(getent passwd "${USER_NAME}" | cut -d: -f6)
    USER_GROUP=$(id -gn "${USER_NAME}")
    USER_GROUPS=$(groups "${USER_NAME}")
    HOST_IPV4=$(ip address | grep -v "127.0.0" | grep "inet " | awk '{print $2}' | awk -F "/" '{print $1}' | head -n 1)
fi

# CTM default OS group name
CTM_ADMIN_GROUP="controlm"

# check if CTM admin group exists and user is a member of
if echo "${USER_GROUPS}" | grep -q "\b${CTM_ADMIN_GROUP}\b"; then
    CTM_GROUP="${CTM_ADMIN_GROUP}"
else
    # shellcheck disable=SC2034 # this is intentionals
    CTM_GROUP="${USER_GROUP}"
fi

# JAVA version
JAVA_HOME=$(sh -c "java -XshowSettings:properties -version 2>&1 > /dev/null | grep 'java.home'" | awk -F "= " '{print $2}')
JAVA_VERSION=$(sh -c "java -XshowSettings:properties -version 2>&1 > /dev/null | grep 'java.runtime.version'" | awk -F "= " '{print $2}')
JAVA_RUNTIME=$(sh -c "java -XshowSettings:properties -version 2>&1 > /dev/null | grep 'java.runtime.name'" | awk -F "= " '{print $2}')

# call script:
usage() {
    echo -e "  "
    echo -e "${Purple}Example:${Color_Off} "
    # echo -e "${Cyan}./$(basename "$0")${Yellow} --public${Color_Off} 'dsse.gpg.pub.asc' ${Yellow} --private${Color_Off} 'dsse.gpg.priv.asc'${Yellow} --passphrase${Color_Off} ''"
    # echo -e "${Cyan}./$(basename "$0")${Yellow} --public${Color_Off} 'dsse.gpg.pub.asc' ${Yellow} --private${Color_Off} 'dsse.gpg.priv.asc'${Yellow} --passphrase${Color_Off} ''"
    # echo -e "${Cyan}./$(basename "$0")${Yellow} --private${Color_Off} 'dsse.gpg.priv.asc'${Yellow} --passphrase${Color_Off} ''"
    echo -e "${Cyan}./$(basename "$0")${Yellow} --file${Color_Off} mftuser.dsse.gpg.info.json ${Yellow} --directory${Color_Off} /tmp/dsse"
    echo -e "${Cyan}./$(basename "$0")${Yellow} --file${Color_Off} dsse.gpg.info.json ${Yellow} --directory${Color_Off} /mnt/client/pgp/mftuser"
}

# Extract the script arguments
for arg in "$@"; do
    shift
    case "${arg}" in
    '--file') set -- "$@" '-f' ;;
    '--directory') set -- "$@" '-d' ;;
    '--public') set -- "$@" '-o' ;;
    '--private') set -- "$@" '-p' ;;
    '--passphrase') set -- "$@" '-q' ;;
    '--help') set -- "$@" '-h' ;;
    *) set -- "$@" "${arg}" ;;
    esac
done

while getopts ":d:f:h" OPTION; do
    case "${OPTION}" in
    d)
        GPG_KEY_WORKING_FOLDER="${OPTARG}"
        ;;
    f)
        GPG_KEY_IMPORT_FILE_INFO="${OPTARG}"
        ;;
    ?)
        usage
        exit 1
        ;;
    esac

done

shift "$((OPTIND - 1))"

# Sleep Time for AWS API calls
# shellcheck disable=SC2116 disable=SC2034 # this is intentional
SLEEP_TIME="15"

function display_info() {
    # Define colors
    DARK_BLUE="\033[0;34m"
    LIGHT_CYAN="\033[1;36m"
    RESET="\033[0m"

    # Calculate the length of the variable and the number of '-' characters
    LENGTH=${#JAVA_HOME}
    TOTAL_LENGTH=$((LENGTH + 24)) # 24 is the length of " - Source File   : " string
    # shellcheck disable=SC2183 # this is intentional
    SEPARATOR=$(printf '%*s' "$TOTAL_LENGTH" | tr ' ' '-')

    printf "\n"
    printf "${LIGHT_CYAN} - %s - ${RESET}\n" "${SCRIPT_PURPOSE}"
    printf " -----------------------------------------------\n"
    printf "${DARK_BLUE} Date           :${RESET}${LIGHT_CYAN} %s${RESET}\n" "${DATE_TODAY}"
    printf "${DARK_BLUE} Distribution   :${RESET}${LIGHT_CYAN} %s${RESET}\n" "${DISTRIBUTION_PRETTY_NAME}"
    printf "${DARK_BLUE} User Name      :${RESET}${LIGHT_CYAN} %s${RESET}\n" "${USER}"
    printf "${DARK_BLUE} User Group     :${RESET}${LIGHT_CYAN} %s${RESET}\n" "${CTM_GROUP}"

    printf "${DARK_BLUE} Sudo Mode      :${RESET}${LIGHT_CYAN} %s${RESET}\n" "${SUDO_STATE}"
    printf "${DARK_BLUE} Domain Name    :${RESET}${LIGHT_CYAN} %s${RESET}\n" "${DOMAIN_NAME}"
    printf "${DARK_BLUE} Host FDQN      :${RESET}${LIGHT_CYAN} %s${RESET}\n" "${HOST_FQDN}"
    printf "${DARK_BLUE} Host Name      :${RESET}${LIGHT_CYAN} %s${RESET}\n" "${HOST_NAME}"
    printf "${DARK_BLUE} Host IPv4      :${RESET}${LIGHT_CYAN} %s${RESET}\n" "${HOST_IPV4}"
    printf "${DARK_BLUE} Agent Folder   :${RESET}${LIGHT_CYAN} %s${RESET}\n" "${DIR_NAME_PARENT}"
    printf "${DARK_BLUE} Script Folder  :${RESET}${LIGHT_CYAN} %s${RESET}\n" "${DIR_NAME}"
    printf "${DARK_BLUE} Working Folder :${RESET}${LIGHT_CYAN} %s${RESET}\n" "${WORKING_DIR}"
    printf "${DARK_BLUE} Config Folder  :${RESET}${LIGHT_CYAN} %s${RESET}\n" "${CONFIG_DIR}"
    printf "${DARK_BLUE} Log Folder     :${RESET}${LIGHT_CYAN} %s${RESET}\n" "${LOG_DIR}"
    printf " ---------------------\n"
    printf "${DARK_BLUE} Data File      :${RESET}${LIGHT_CYAN} %s${RESET}\n" "${SCRIPT_DATA_FILE}"
    printf "${DARK_BLUE} Data Folder    :${RESET}${LIGHT_CYAN} %s${RESET}\n" "${CONFIG_DIR}"
    printf "${DARK_BLUE} JAVA Version   :${RESET}${LIGHT_CYAN} %s${RESET}\n" "${JAVA_VERSION}"
    printf "${DARK_BLUE} JAVA RunTime   :${RESET}${LIGHT_CYAN} %s${RESET}\n" "${JAVA_RUNTIME}"
    printf "${DARK_BLUE} JAVA Home      :${RESET}${LIGHT_CYAN} %s${RESET}\n" "${JAVA_HOME}"
    printf " %s\n" "${SEPARATOR}"

    log_entry "Script Purpose" "${SCRIPT_PURPOSE}"
    log_entry "Date" "${DATE_TODAY}"
    log_entry "Distribution" "${DISTRIBUTION_PRETTY_NAME}"
    log_entry "User Name" "${USER}"
    log_entry "User Group" "${CTM_GROUP}"
    log_entry "Sudo Mode" "${SUDO_STATE}"
    log_entry "Domain Name" "${DOMAIN_NAME}"
    log_entry "Host FDQN" "${HOST_FQDN}"
    log_entry "Host Name" "${HOST_NAME}"
    log_entry "Host IPv4" "${HOST_IPV4}"
    log_entry "Agent Folder" "'${DIR_NAME_PARENT}'"
    log_entry "Script Folder" "'${DIR_NAME}'"
    log_entry "Working Folder" "'${WORKING_DIR}'"
    log_entry "Config Folder" "'${CONFIG_DIR}'"
    log_entry "Log Folder" "'${LOG_DIR}'"
    log_entry "Data File" "'${SCRIPT_DATA_FILE}'"
    log_entry "Data Folder" "'${CONFIG_DIR}'"
    log_entry "JAVA Version" "${JAVA_VERSION}"
    log_entry "JAVA RunTime" "${JAVA_RUNTIME}"
    log_entry "JAVA Home" "'${JAVA_HOME}'"
}

# Show license, logo and info
license
display_info

function display_project_details() {
    # Define colors
    CYAN="\033[0;36m"
    BLUE="\033[0;34m"
    RESET="\033[0m"

    # Calculate the length of the variable and the number of '-' characters
    LENGTH=${#GPG_KEY_FINGERPRINTS_PUBLIC_CSV}
    TOTAL_LENGTH=$((LENGTH + 28)) # 24 is the length of " - Source File   : " string
    # shellcheck disable=SC2183 # this is intentional
    SEPARATOR=$(printf '%*s' "$TOTAL_LENGTH" | tr ' ' '-')

    printf "\n"
    # shellcheck disable=SC2059 # this is intentional
    printf "${RESET} ---- ${CYAN}Project Details${RESET} ----\n"
    printf "${CYAN} - Mode                 :${RESET}${BLUE} %s${RESET}\n" "${PROJECT_MODE}"
    printf "${CYAN} - Debug Status         :${RESET}${BLUE} %s${RESET}\n" "${PROJECT_DEBUG}"
    printf "${CYAN} - Name                 :${RESET}${BLUE} %s${RESET}\n" "${PROJECT_NAME}"
    printf "${CYAN} - Code                 :${RESET}${BLUE} %s${RESET}\n" "${PROJECT_CODE}"
    printf " %s\n" "${SEPARATOR}"
    printf "${CYAN} - GPG Binary           :${RESET}${BLUE} %s${RESET}\n" "${GPG_BIN}"
    printf "${CYAN} - GPG Key Name         :${RESET}${BLUE} %s${RESET}\n" "${GPG_KEY_NAME}"
    printf "${CYAN} - GPG Key Passphrase   :${RESET}${BLUE} %s${RESET}\n" "${GPG_KEY_PASSPHRASE}"
    printf "${CYAN} - GPG Key List         :${RESET}${BLUE} %s${RESET}\n" "${GPG_KEY_LIST_CSV}"
    printf " %s\n" "${SEPARATOR}"
    printf "${CYAN} - GPG Data Folder      :${RESET}${BLUE} %s${RESET}\n" "${GPG_KEY_WORKING_FOLDER}"
    printf "${CYAN} - GPG Key Pub Path     :${RESET}${BLUE} %s${RESET}\n" "${GPG_KEY_IMPORT_PATH_PUBLIC}"
    printf "${CYAN} - GPG Key Priv Path    :${RESET}${BLUE} %s${RESET}\n" "${GPG_KEY_IMPORT_PATH_PRIVATE}"
    printf "${CYAN} - GPG Key Pub File     :${RESET}${BLUE} %s${RESET}\n" "${GPG_KEY_IMPORT_FILE_PUBLIC}"
    printf "${CYAN} - GPG Key Priv File    :${RESET}${BLUE} %s${RESET}\n" "${GPG_KEY_IMPORT_FILE_PRIVATE}"
    printf " %s\n" "${SEPARATOR}"
    printf "${CYAN} - GPG Key Info File    :${RESET}${BLUE} %s${RESET}\n" "${GPG_KEY_IMPORT_FILE_INFO}"
    printf "${CYAN} - GPG Pub Key File     :${RESET}${BLUE} %s${RESET}\n" "${GPG_KEY_IMPORT_FILE_PUBLIC}"
    printf "${CYAN} - GPG Fingerprints     :${RESET}${BLUE} %s${RESET}\n" "${GPG_KEY_FINGERPRINTS_PUBLIC_CSV}"
    printf "${CYAN} - GPG Pub Key Name     :${RESET}${BLUE} %s${RESET}\n" "${GPG_KEY_NAME_PUBLIC}"
    printf "${CYAN} - GPG Pub Key List     :${RESET}${BLUE} %s${RESET}\n" "${GPG_KEY_LIST_CSV}"

    if [[ "${GPG_KEY_STATUS_PUBLIC}" == "TRUE" ]]; then
        printf "${CYAN} - GPG Pub Key Status   :${RESET}${Green} %s${RESET}\n" "${GPG_KEY_STATUS_PUBLIC}"
    else
        printf "${CYAN} - GPG Pub Key Status   :${RESET}${Red} %s${RESET}\n" "${GPG_KEY_STATUS_PUBLIC}"
    fi

    printf " %s\n" "${SEPARATOR}"
    printf "${CYAN} - GPG Key Info File    :${RESET}${BLUE} %s${RESET}\n" "${GPG_KEY_IMPORT_FILE_INFO}"
    printf "${CYAN} - GPG Pri Key File     :${RESET}${BLUE} %s${RESET}\n" "${GPG_KEY_IMPORT_FILE_PRIVATE}"
    printf "${CYAN} - GPG Fingerprints     :${RESET}${BLUE} %s${RESET}\n" "${GPG_KEY_FINGERPRINTS_PRIVATE_CSV}"
    printf "${CYAN} - GPG Pri Key Name     :${RESET}${BLUE} %s${RESET}\n" "${GPG_KEY_NAME_PRIVATE}"
    printf "${CYAN} - GPG Pri Key List     :${RESET}${BLUE} %s${RESET}\n" "${GPG_KEY_LIST_CSV}"
    printf "${CYAN} - GPG Key ID in File   :${RESET}${BLUE} %s${RESET}\n" "${GPG_KEY_ID_PRIVATE_FROM_FILE}"
    printf "${CYAN} - GPG Key ID           :${RESET}${BLUE} %s${RESET}\n" "${GPG_KEY_ID_PRIVATE}"
    printf "${CYAN} - GPG Processed Total  :${RESET}${BLUE} %s${RESET}\n" "${GPG_PRIVATE_KEY_TOTAL_PROCESSED}"
    printf "${CYAN} - GPG Unchanged        :${RESET}${BLUE} %s${RESET}\n" "${GPG_PRIVATE_KEY_UNCHANGED}"
    printf "${CYAN} - GPG Secret Read      :${RESET}${BLUE} %s${RESET}\n" "${GPG_PRIVATE_KEY_SECRET_READ}"
    printf "${CYAN} - GPG Secret Unchanged :${RESET}${BLUE} %s${RESET}\n" "${GPG_PRIVATE_KEY_SECRET_UNCHANGED}"
    printf "${CYAN} - GPG Secret Imported  :${RESET}${BLUE} %s${RESET}\n" "${GPG_PRIVATE_KEY_SECRET_IMPORTED}"

    if [[ "${GPG_KEY_STATUS_PRIVATE}" == "TRUE" ]]; then
        printf "${CYAN} - GPG Priv Status      :${RESET}${Green} %s${RESET}\n" "${GPG_KEY_STATUS_PRIVATE}"
    else
        printf "${CYAN} - GPG Priv Status      :${RESET}${Red} %s${RESET}\n" "${GPG_KEY_STATUS_PRIVATE}"

    fi

    if [[ "${GPG_KEY_TRUST_STATUS}" == "TRUE" ]]; then
        printf "${CYAN} - GPG Trust Status     :${RESET}${Green} %s${RESET}\n" "${GPG_KEY_TRUST_STATUS}"
    else
        printf "${CYAN} - GPG Trust Status     :${RESET}${Red} %s${RESET}\n" "${GPG_KEY_TRUST_STATUS}"

    fi

    printf " %s\n" "${SEPARATOR}"
    printf "${CYAN} - GPG Known List       :${RESET}${BLUE} %s${RESET}\n" "${GPG_KEY_LIST_FINAL_CSV}"
}

# -- End of boilerplate --

# -- Start of project logic --
SCRIPT_PURPOSE="generate gpg keys and export public key"
CLASS_NAME="gpg-generate"
PROJECT_LOG_LEVEL="DEBUG"

# Assign GPG binary
GPG_BIN=$(which gpg)

# Assign default working folder
if [ -z "${GPG_KEY_WORKING_FOLDER}" ]; then
    GPG_KEY_WORKING_FOLDER="${WORKING_DIR}/gpg/default"
fi

# Assign default import file
if [ -z "${GPG_KEY_IMPORT_FILE_INFO}" ]; then
    GPG_KEY_IMPORT_FILE_INFO="dsse.gpg.info.json"
fi

GPG_KEY_IMPORT_PATH_INFO="${GPG_KEY_WORKING_FOLDER}/${GPG_KEY_IMPORT_FILE_INFO}"

# Exit script if no import file
if [[ -f "${GPG_KEY_IMPORT_PATH_INFO}" ]]; then
    GPG_KEY_IMPORT_INFO=$(jq '.' "${GPG_KEY_IMPORT_PATH_INFO}")
    GPG_UPDATE_DATA="${GPG_KEY_IMPORT_INFO}"
else
    usage
    exit 1
fi

API_ACTION="Extract GPG details from the GPG info file"
echo " "
echo -e " ${LIGHT_BLUE} # Stage       -> ${LIGHT_CYAN}${API_ACTION}${Color_Off}"
log_with_timestamp "INFO" "Start"

# Extract GPG details from the GPG info file
GPG_KEY_NAME=$(echo "${GPG_KEY_IMPORT_INFO}" | jq -r '.name')
GPG_KEY_PASSPHRASE=$(echo "${GPG_KEY_IMPORT_INFO}" | jq -r '.passphrase')
GPG_KEY_IMPORT_FILE_PUBLIC=$(echo "${GPG_KEY_IMPORT_INFO}" | jq -r '.public')
GPG_KEY_IMPORT_FILE_PRIVATE=$(echo "${GPG_KEY_IMPORT_INFO}" | jq -r '.private')

GPG_KEY_IMPORT_PATH_PUBLIC="${GPG_KEY_WORKING_FOLDER}/${GPG_KEY_IMPORT_FILE_PUBLIC}"
GPG_KEY_IMPORT_PATH_PRIVATE="${GPG_KEY_WORKING_FOLDER}/${GPG_KEY_IMPORT_FILE_PRIVATE}"

# start gpg deamon if not running
GPG_DAEMON_STATUS=$(gpgconf --list-dirs agent-socket)
if [[ -z ${GPG_DAEMON_STATUS} ]]; then
    # shellcheck disable=SC2006 disable=SC2086 disable=SC2034 # this is intentional
    GPG_DAEMON=$(gpg-agent --daemon)
    GPG_DAEMON_STATUS=$(gpgconf --list-dirs agent-socket)
fi

printf "\n"
printf "${CYAN} - GPG Data Folder    :${RESET}${BLUE} %s${RESET}\n" "${GPG_KEY_WORKING_FOLDER}"
printf "${CYAN} - GPG Info File      :${RESET}${BLUE} %s${RESET}\n" "${GPG_KEY_IMPORT_FILE_INFO}"
printf "${CYAN} - GPG Daemon Status  :${RESET}${BLUE} %s${RESET}\n" "${GPG_DAEMON_STATUS}"
printf " -----------------------------------------------\n"
printf "${CYAN} - GPG Key Name       :${RESET}${BLUE} %s${RESET}\n" "${GPG_KEY_NAME}"
printf "${CYAN} - GPG Key Passphrase :${RESET}${BLUE} %s${RESET}\n" "${GPG_KEY_PASSPHRASE}"

printf " -----------------------------------------------\n"
printf "${CYAN} - GPG Pri Key File   :${RESET}${BLUE} %s${RESET}\n" "${GPG_KEY_IMPORT_FILE_PRIVATE}"
printf "${CYAN} - GPG Pub Key File   :${RESET}${BLUE} %s${RESET}\n" "${GPG_KEY_IMPORT_FILE_PUBLIC}"
printf "\n"

# # Process GPG requests

API_ACTION="Process GPG requests for public key"
echo " "
echo -e " ${LIGHT_BLUE} # Stage       -> ${LIGHT_CYAN}${API_ACTION}${Color_Off}"
log_with_timestamp "INFO" "Start"

if [[ -f "${GPG_KEY_IMPORT_PATH_PUBLIC}" ]]; then

    API_ACTION="gpg --with-colons --import-options show-only --import --fingerprint"
    echo -e " ${LIGHT_BLUE} > API Action   : ${Red}${API_ACTION}${Color_Off}"
    API_RESULT=$(gpg --with-colons --import-options show-only --import --fingerprint "${GPG_KEY_IMPORT_PATH_PUBLIC}" 2>&1 | grep '^fpr' | cut -d':' -f10 | tr '\n' ',' | sed 's/,$//')
    log_with_timestamp "${PROJECT_LOG_LEVEL}" "${API_RESULT}"
    GPG_KEY_FINGERPRINTS_PUBLIC="${API_RESULT}"

    API_ACTION="gpg --with-colons --import-options show-only --import --fingerprint"
    echo -e " ${LIGHT_BLUE} > API Action   : ${Red}${API_ACTION}${Color_Off}"
    API_RESULT=$(gpg --with-colons --import-options show-only --import --fingerprint "${GPG_KEY_IMPORT_PATH_PUBLIC}" 2>&1)
    log_with_timestamp "${PROJECT_LOG_LEVEL}" "${API_RESULT}"
    GPG_KEY_INFO="${API_RESULT}"

    API_ACTION="awk"
    API_RESULT=$(echo "${GPG_KEY_INFO}" | awk -F: '/^uid/{split($10,a,"<|>"); print a[1]}')
    log_with_timestamp "${PROJECT_LOG_LEVEL}" "${API_RESULT}"
    GPG_KEY_NAME_PUBLIC_TEMP="${API_RESULT}"

    API_ACTION="gpg --batch --list-keys --with-colons"
    echo -e " ${LIGHT_BLUE} > API Action   : ${Red}${API_ACTION}${Color_Off}"
    API_RESULT=$(gpg --batch --list-keys --with-colons 2>/dev/null | awk -F: '/^uid/{split($10,a,"<|>"); print a[1]}')
    log_with_timestamp "${PROJECT_LOG_LEVEL}" "${API_RESULT}"
    GPG_KEY_LIST="${API_RESULT}"

    API_ACTION="sed"
    API_RESULT=$(echo "${GPG_KEY_LIST}" | tr '\n' ',' | sed 's/,$//')
    log_with_timestamp "${PROJECT_LOG_LEVEL}" "${API_RESULT}"
    GPG_KEY_LIST_CSV="${API_RESULT}"

    API_ACTION="sed"
    API_RESULT=$(echo "${GPG_KEY_NAME_PUBLIC_TEMP}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
    log_with_timestamp "${PROJECT_LOG_LEVEL}" "${API_RESULT}"
    GPG_KEY_NAME_PUBLIC="${API_RESULT}"

    API_ACTION="Remove any public key"
    echo " "
    echo -e " ${LIGHT_BLUE} # Stage       -> ${LIGHT_CYAN}${API_ACTION}${Color_Off}"
    log_with_timestamp "INFO" "Start"

    # remove any existing keys
    for GPG_KEY in ${GPG_KEY_LIST}; do

        if [[ "${GPG_KEY}" == *"${GPG_KEY_NAME_PUBLIC}"* ]]; then

            API_ACTION="gpg key:*"
            echo -e " ${LIGHT_BLUE} > API Action   : ${Red}${API_ACTION}${Color_Off}"
            API_RESULT=${GPG_KEY%%:*}
            log_with_timestamp "${PROJECT_LOG_LEVEL}" "${API_RESULT}"
            GPG_FINGERPRINT="${API_RESULT}"

            API_ACTION="gpg --batch --list-secret-keys --with-colons"
            echo -e " ${LIGHT_BLUE} > API Action   : ${Red}${API_ACTION}${Color_Off}"
            API_RESULT=$(gpg --batch --list-secret-keys --with-colons "${GPG_FINGERPRINT}" 2>/dev/null)
            log_with_timestamp "${PROJECT_LOG_LEVEL}" "${API_RESULT}"
            GPG_SECRET_KEYS="${API_RESULT}"

            # shellcheck disable=SC2006 disable=SC2086 disable=SC2034 # this is intentional
            if [[ -n "${GPG_SECRET_KEYS}" ]]; then
                # shellcheck disable=SC2006 disable=SC2086 disable=SC2034 # this is intentional

                API_ACTION="gpg --list-keys --with-fingerprint --with-colons"
                echo -e " ${LIGHT_BLUE} > API Action   : ${Red}${API_ACTION}${Color_Off}"
                API_RESULT=$(gpg --list-keys --with-fingerprint --with-colons ${GPG_KEY_NAME} 2>/dev/null | grep '^fpr' | cut -d':' -f10)
                log_with_timestamp "${PROJECT_LOG_LEVEL}" "${API_RESULT}"
                GPG_KEY_FINGERPRINTS_PUBLIC="${API_RESULT}"

                API_ACTION="sed"
                API_RESULT=$(echo "${GPG_KEY_FINGERPRINTS_PUBLIC}" | tr '\n' ',' | sed 's/,$//')
                log_with_timestamp "${PROJECT_LOG_LEVEL}" "${API_RESULT}"
                GPG_KEY_FINGERPRINTS_PUBLIC_CSV="${API_RESULT}"

                # Loop through all the fingerprints and delete the corresponding key(s)
                # shellcheck disable=SC1072 disable=SC1073 # this is intentionals
                for GPG_KEY_FINGERPRINT in ${GPG_KEY_FINGERPRINTS_PUBLIC}; do

                    API_ACTION="gpg --batch --yes --delete-secret-keys"
                    echo -e " ${LIGHT_BLUE} > API Action   : ${Red}${API_ACTION}${Color_Off}"
                    API_RESULT=$(gpg --batch --yes --delete-secret-keys ${GPG_KEY_FINGERPRINT} 2>/dev/null)
                    log_with_timestamp "${PROJECT_LOG_LEVEL}" "${API_RESULT}"
                    GPG_KEY_RESULT="${API_RESULT}"

                    API_ACTION="gpg --batch --yes --delete-key"
                    echo -e " ${LIGHT_BLUE} > API Action   : ${Red}${API_ACTION}${Color_Off}"
                    API_RESULT=$(gpg --batch --yes --delete-key ${GPG_KEY_FINGERPRINT} 2>/dev/null)
                    log_with_timestamp "${PROJECT_LOG_LEVEL}" "${API_RESULT}"
                    GPG_KEY_RESULT="${API_RESULT}"
                done
            else
                API_ACTION="gpg --batch --yes --delete-keys"
                echo -e " ${LIGHT_BLUE} > API Action   : ${Red}${API_ACTION}${Color_Off}"
                API_RESULT=$(gpg --batch --yes --delete-keys ${GPG_FINGERPRINT} 2>/dev/null)
                log_with_timestamp "${PROJECT_LOG_LEVEL}" "${API_RESULT}"
                GPG_KEY_RESULT="${API_RESULT}"
            fi
        fi
    done

    # add only public key
    API_ACTION="Add public key"
    echo " "
    echo -e " ${LIGHT_BLUE} # Stage       -> ${LIGHT_CYAN}${API_ACTION}${Color_Off}"
    log_with_timestamp "INFO" "Start"

    API_ACTION="gpg --batch --yes --import"
    echo -e " ${LIGHT_BLUE} > API Action   : ${Red}${API_ACTION}${Color_Off}"
    API_RESULT=$(gpg --batch --yes --import "${GPG_KEY_IMPORT_PATH_PUBLIC}" 2>&1)
    log_with_timestamp "${PROJECT_LOG_LEVEL}" "${API_RESULT}"

    API_ACTION="gpg --batch --list-keys --with-colons"
    echo -e " ${LIGHT_BLUE} > API Action   : ${Red}${API_ACTION}${Color_Off}"
    API_RESULT=$(gpg --batch --list-keys --with-colons "${GPG_KEY_NAME_PUBLIC}" 2>&1 | grep '^fpr' | cut -d':' -f10 | tr '\n' ',' | sed 's/,$//')
    log_with_timestamp "${PROJECT_LOG_LEVEL}" "${API_RESULT}"
    GPG_KEY_LIST="${API_RESULT}"

    API_ACTION="gpg --batch --list-keys --with-colons"
    echo -e " ${LIGHT_BLUE} > API Action   : ${Red}${API_ACTION}${Color_Off}"
    API_RESULT=$(gpg --batch --list-keys --with-colons "${GPG_KEY_NAME_PUBLIC}" 2>&1 | grep '^fpr' | cut -d':' -f10 | tr '\n' ',' | sed 's/,$//')
    log_with_timestamp "${PROJECT_LOG_LEVEL}" "${API_RESULT}"
    GPG_KEY_LIST="${API_RESULT}"

    # trust key
    API_ACTION="gpg --list-keys --with-fingerprint --with-colons"
    echo -e " ${LIGHT_BLUE} > API Action   : ${Red}${API_ACTION}${Color_Off}"
    # shellcheck disable=SC2086 # this is intentionals
    API_RESULT=$(gpg --list-keys --with-fingerprint --with-colons ${GPG_KEY_NAME} 2>/dev/null | grep '^fpr' | cut -d':' -f10)
    log_with_timestamp "${PROJECT_LOG_LEVEL}" "${API_RESULT}"
    GPG_KEY_FINGERPRINTS_PUBLIC="${API_RESULT}"

    API_ACTION="sed"
    API_RESULT=$(echo "${GPG_KEY_FINGERPRINTS_PUBLIC}" | tr '\n' ',' | sed 's/,$//')
    log_with_timestamp "${PROJECT_LOG_LEVEL}" "${API_RESULT}"
    GPG_KEY_FINGERPRINTS_PUBLIC_CSV="${API_RESULT}"

    for GPG_KEY_FINGERPRINT in ${GPG_KEY_FINGERPRINTS_PUBLIC}; do
        GPG_KEY_FINGERPRINT_TEMP="${GPG_KEY_FINGERPRINT}:6:"

        API_ACTION="gpg --batch --yes --import-ownertrust"
        echo -e " ${LIGHT_BLUE} > API Action   : ${Red}${API_ACTION}${Color_Off}"
        API_RESULT=$(echo "${GPG_KEY_FINGERPRINT_TEMP}" | gpg --batch --yes --import-ownertrust 2>&1)
        log_with_timestamp "${PROJECT_LOG_LEVEL}" "${API_RESULT}"
        # shellcheck disable=SC2034 # this is intentionals
        GPG_CMD_RESULT="${API_RESULT}"
    done

    # get key id
    API_ACTION="gpg --list-keys --with-fingerprint --with-colons"
    echo -e " ${LIGHT_BLUE} > API Action   : ${Red}${API_ACTION}${Color_Off}"
    # shellcheck disable=SC2086 # this is intentionals
    API_RESULT=$(gpg --list-keys --with-fingerprint --with-colons ${GPG_KEY_NAME} 2>/dev/null | awk -F: '/^pub:/ {print $5}' 2>&1)
    log_with_timestamp "${PROJECT_LOG_LEVEL}" "${API_RESULT}"

    API_ACTION="grep, awk"
    API_RESULT=$(echo "${API_RESULT}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
    log_with_timestamp "${PROJECT_LOG_LEVEL}" "${API_RESULT}"
    GPG_KEY_ID_PUBLIC="${API_RESULT}"

    UPDATED_DATA=$(echo "${GPG_UPDATE_DATA}" | jq --arg keyid "${GPG_KEY_ID_PUBLIC}" '.keyid += {"public": $keyid}')

    # Write the updated data to the specified variable
    GPG_UPDATE_DATA="${UPDATED_DATA}"

    if echo "${GPG_KEY_LIST}" | grep -Eq '^[^,]+,[^,]+$'; then
        GPG_KEY_STATUS_PUBLIC="TRUE"
    else
        GPG_KEY_STATUS_PUBLIC="FALSE"
    fi
fi

API_ACTION="Process GPG requests for private key"
echo " "
echo -e " ${LIGHT_BLUE} # Stage       -> ${LIGHT_CYAN}${API_ACTION}${Color_Off}"
log_with_timestamp "INFO" "Start"

# shellcheck disable=SC1073 # this is intentionals
if [[ -f "${GPG_KEY_IMPORT_PATH_PRIVATE}" ]]; then

    API_ACTION="gpg --with-colons --import-options show-only --import --fingerprint"
    echo -e " ${LIGHT_BLUE} > API Action   : ${Red}${API_ACTION}${Color_Off}"
    API_RESULT=$(gpg --with-colons --import-options show-only --import --fingerprint "${GPG_KEY_IMPORT_PATH_PRIVATE}")
    log_with_timestamp "${PROJECT_LOG_LEVEL}" "${API_RESULT}"
    GPG_KEY_INFO="${API_RESULT}"

    API_ACTION="awk"
    API_RESULT=$(echo "${GPG_KEY_INFO}" | awk -F: '/^uid/{split($10,a,"<|>"); print a[1]}' | awk '{print $NF}')
    log_with_timestamp "${PROJECT_LOG_LEVEL}" "${API_RESULT}"
    GPG_KEY_NAME_PRIVATE="${API_RESULT}"

    API_ACTION="gpg --batch --yes --passphrase --import"
    echo -e " ${LIGHT_BLUE} > API Action   : ${Red}${API_ACTION}${Color_Off}"
    GPG_CMD="gpg --batch --yes --passphrase ${GPG_KEY_PASSPHRASE} --import ${GPG_KEY_IMPORT_PATH_PRIVATE}"
    API_RESULT=$(${GPG_CMD} 2>&1)
    log_with_timestamp "${PROJECT_LOG_LEVEL}" "${API_RESULT}"
    GPG_CMD_RESULT="${API_RESULT}"

    API_ACTION="grep"
    API_RESULT=$(echo "${GPG_CMD_RESULT}" | grep "Total number processed" | awk '{print $NF}')
    log_with_timestamp "${PROJECT_LOG_LEVEL}" "${API_RESULT}"
    GPG_PRIVATE_KEY_TOTAL_PROCESSED="${API_RESULT}"

    API_ACTION="grep"
    API_RESULT=$(echo "${GPG_CMD_RESULT}" | grep "  unchanged" | awk '{print $NF}')
    log_with_timestamp "${PROJECT_LOG_LEVEL}" "${API_RESULT}"
    GPG_PRIVATE_KEY_UNCHANGED="${API_RESULT}"

    API_ACTION="grep"
    API_RESULT=$(echo "${GPG_CMD_RESULT}" | grep "secret keys read" | awk '{print $NF}')
    log_with_timestamp "${PROJECT_LOG_LEVEL}" "${API_RESULT}"
    GPG_PRIVATE_KEY_SECRET_READ="${API_RESULT}"

    API_ACTION="grep"
    API_RESULT=$(echo "${GPG_CMD_RESULT}" | grep "secret keys imported" | awk '{print $NF}')
    log_with_timestamp "${PROJECT_LOG_LEVEL}" "${API_RESULT}"
    GPG_PRIVATE_KEY_SECRET_IMPORTED="${API_RESULT}"

    API_ACTION="grep"
    API_RESULT=$(echo "${GPG_CMD_RESULT}" | grep "secret keys unchanged" | awk '{print $NF}')
    log_with_timestamp "${PROJECT_LOG_LEVEL}" "${API_RESULT}"
    GPG_PRIVATE_KEY_SECRET_UNCHANGED="${API_RESULT}"

    API_ACTION="awk"
    API_RESULT=$(echo "${GPG_KEY_INFO}" | awk -F: '/^sec:/ { print $5 }')
    log_with_timestamp "${PROJECT_LOG_LEVEL}" "${API_RESULT}"
    GPG_KEY_ID_PRIVATE_FROM_FILE="${API_RESULT}"

    API_ACTION="gpg --list-secret-keys --with-colons"
    echo -e " ${LIGHT_BLUE} > API Action   : ${Red}${API_ACTION}${Color_Off}"
    API_RESULT=$(gpg --list-secret-keys --with-colons "${GPG_KEY_NAME_PRIVATE}" 2>&1 | awk -F: '/^sec:/ { print $5 }')
    log_with_timestamp "${PROJECT_LOG_LEVEL}" "${API_RESULT}"
    GPG_KEY_ID_PRIVATE="${API_RESULT}"

    UPDATED_DATA=$(echo "${GPG_UPDATE_DATA}" | jq --arg keyid "${GPG_KEY_ID_PRIVATE}" '.keyid += {"private": $keyid}')

    # Write the updated data to the specified variable
    GPG_UPDATE_DATA="${UPDATED_DATA}"

    API_ACTION="gpg --list-secret-keys --with-fingerprint --with-colons"
    echo -e " ${LIGHT_BLUE} > API Action   : ${Red}${API_ACTION}${Color_Off}"
    API_RESULT=$(gpg --list-secret-keys --with-fingerprint --with-colons "${GPG_KEY_NAME_PRIVATE}" | grep '^fpr' | cut -d':' -f10)
    log_with_timestamp "${PROJECT_LOG_LEVEL}" "${API_RESULT}"
    GPG_KEY_FINGERPRINTS_PRIVATE="${API_RESULT}"

    API_ACTION="sed"
    API_RESULT=$(echo "${GPG_KEY_FINGERPRINTS_PRIVATE}" | tr '\n' ',' | sed 's/,$//')
    log_with_timestamp "${PROJECT_LOG_LEVEL}" "${API_RESULT}"
    GPG_KEY_FINGERPRINTS_PRIVATE_CSV="${API_RESULT}"

    API_ACTION="Loop through all the fingerprints and trust the corresponding key(s)"
    echo " "
    echo -e " ${LIGHT_BLUE} # Stage       -> ${LIGHT_CYAN}${API_ACTION}${Color_Off}"
    log_with_timestamp "INFO" "Start"

    for GPG_KEY_FINGERPRINT in ${GPG_KEY_FINGERPRINTS_PRIVATE}; do
        GPG_KEY_FINGERPRINT_TEMP="${GPG_KEY_FINGERPRINT}:6:"

        API_ACTION="gpg --batch --yes --import-ownertrust"
        echo -e " ${LIGHT_BLUE} > API Action   : ${Red}${API_ACTION}${Color_Off}"
        API_RESULT=$(echo "${GPG_KEY_FINGERPRINT_TEMP}" | gpg --batch --yes --import-ownertrust 2>&1)
        log_with_timestamp "${PROJECT_LOG_LEVEL}" "${API_RESULT}"
        GPG_CMD_RESULT="${API_RESULT}"
    done

    API_ACTION="gpg --list-secret-keys"
    echo -e " ${LIGHT_BLUE} > API Action   : ${Red}${API_ACTION}${Color_Off}"
    # API_RESULT=$(gpg --list-secret-keys ${GPG_KEY_NAME_PRIVATE} | grep -oP 'uid\s+.*$' | sed 's/^uid\s*//' | cut -d'<' -f1 | sed 's/\s*$//')
    API_RESULT=$(gpg --list-secret-keys "${GPG_KEY_NAME_PRIVATE}" 2>&1 | grep -o 'uid.*' | sed 's/^uid\s*//' | cut -d'<' -f1 | sed 's/\s*$//')
    GPG_KEY_TRUST_RESULT="${API_RESULT}"

    # get key id
    API_ACTION="gpg --list-secret-keys --with-fingerprint --with-colons"
    echo -e " ${LIGHT_BLUE} > API Action   : ${Red}${API_ACTION}${Color_Off}"
    # shellcheck disable=SC2086 # this is intentionals
    API_RESULT=$(gpg --list-secret-keys --with-fingerprint --with-colons ${GPG_KEY_NAME_PRIVATE} 2>/dev/null | awk -F: '/^pub:/ {print $5}' 2>&1)
    log_with_timestamp "${PROJECT_LOG_LEVEL}" "${API_RESULT}"

    UPDATED_DATA=$(echo "${GPG_UPDATE_DATA}" | jq --arg keyid "${GPG_KEY_ID_PRIVATE}" '.keyid += {"private": $keyid}')

    # Write the updated data to the specified variable
    GPG_UPDATE_DATA="${UPDATED_DATA}"

    if [[ "${GPG_KEY_TRUST_RESULT}" == *"ultimate"* ]]; then
        GPG_KEY_TRUST_STATUS="TRUE"
    else
        GPG_KEY_TRUST_STATUS="FALSE"
    fi

    if [[ "${GPG_PRIVATE_KEY_TOTAL_PROCESSED}" =~ ^[0-9]+$ ]] && [[ "${GPG_PRIVATE_KEY_TOTAL_PROCESSED}" -gt 0 ]]; then
        GPG_KEY_STATUS_PRIVATE="TRUE"
    else
        GPG_KEY_STATUS_PRIVATE="FALSE"
    fi
fi

API_ACTION="Final Report"
echo " "
echo -e " ${LIGHT_BLUE} # Stage       -> ${LIGHT_CYAN}${API_ACTION}${Color_Off}"
log_with_timestamp "INFO" "Start"

API_ACTION="gpg --batch --list-keys --with-colons"
echo -e " ${LIGHT_BLUE} > API Action   : ${Red}${API_ACTION}${Color_Off}"
API_RESULT=$(gpg --batch --list-keys --with-colons 2>/dev/null | awk -F: '/^uid/{split($10,a,"<|>"); print a[1]}')
log_with_timestamp "${PROJECT_LOG_LEVEL}" "${API_RESULT}"
GPG_KEY_LIST_FINAL="${API_RESULT}"

API_ACTION="sed"
API_RESULT=$(echo "${GPG_KEY_LIST_FINAL}" | tr '\n' ',' | sed 's/,$//')
log_with_timestamp "${PROJECT_LOG_LEVEL}" "${API_RESULT}"
GPG_KEY_LIST_FINAL_CSV="${API_RESULT}"

echo -e " ${Cyan} - Data File    : ${Color_Off}${AWS_PROJECT_DATA_CONFIG_FILE}"
# shellcheck disable=SC2034 # this is intentionals
CMD_RESULT=$(echo "${GPG_UPDATE_DATA}" | tee "${GPG_KEY_IMPORT_PATH_INFO}")

display_project_details
