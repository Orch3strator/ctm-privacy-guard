#!/bin/bash
set +x
# shellcheck enable=require-variable-braces
# file name: dsse.gpg.delete.key.sh
# -- Start of boilerplate --
printf "\033c"
################################################################################
# License                                                                      #
################################################################################

function license() {
    printf "${DARK_GREY}%s${RESET}\n" ""
    printf "${DARK_GREY}%s${RESET}\n" " GPL-3.0-only or GPL-3.0-or-later"
    printf "${DARK_GREY}%s${RESET}\n" " Copyright (c) 2021 BMC Software, Inc."
    printf "${DARK_GREY}%s${RESET}\n" " Author: Volker Scheithauer"
    printf "${DARK_GREY}%s${RESET}\n" " E-Mail: orchestrator@bmc.com"
    printf "${DARK_GREY}%s${RESET}\n" ""
    printf "${DARK_GREY}%s${RESET}\n" " This program is free software: you can redistribute it and/or modify"
    printf "${DARK_GREY}%s${RESET}\n" " it under the terms of the GNU General Public License as published by"
    printf "${DARK_GREY}%s${RESET}\n" " the Free Software Foundation, either version 3 of the License, or"
    printf "${DARK_GREY}%s${RESET}\n" " (at your option) any later version."
    printf "${DARK_GREY}%s${RESET}\n" ""
    printf "${DARK_GREY}%s${RESET}\n" " This program is distributed in the hope that it will be useful,"
    printf "${DARK_GREY}%s${RESET}\n" " but WITHOUT ANY WARRANTY; without even the implied warranty of"
    printf "${DARK_GREY}%s${RESET}\n" " MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the"
    printf "${DARK_GREY}%s${RESET}\n" " GNU General Public License for more details."
    printf "${DARK_GREY}%s${RESET}\n" ""
    printf "${DARK_GREY}%s${RESET}\n" " You should have received a copy of the GNU General Public License"
    printf "${DARK_GREY}%s${RESET}\n" " along with this program.  If not, see <https://www.gnu.org/licenses/>."
}

function ctmLogo() {
    printf "${BLUE}%s${RESET}\n" ""
    printf "${BLUE}%s${RESET}\n" "  @@@@@@@   @@@@@@   @@@  @@@  @@@@@@@  @@@@@@@    @@@@@@   @@@                  @@@@@@@@@@   "
    printf "${LIGHT_BLUE}%s${RESET}\n" " @@@@@@@@  @@@@@@@@  @@@@ @@@  @@@@@@@  @@@@@@@@  @@@@@@@@  @@@                  @@@@@@@@@@@  "
    printf "${LIGHT_BLUE}%s${RESET}\n" " !@@       @@!  @@@  @@!@!@@@    @@!    @@!  @@@  @@!  @@@  @@!                  @@! @@! @@!  "
    printf "${CYAN}%s${RESET}\n" " !@!       !@!  @!@  !@!!@!@!    !@!    !@!  @!@  !@!  @!@  !@!                  !@! !@! !@!  "
    printf "${LIGHT_CYAN}%s${RESET}\n" " !@!       @!@  !@!  @!@ !!@!    @!!    @!@!!@!   @!@  !@!  @!!       @!@!@!@!@  @!! !!@ @!@  "
    printf "${YELLOW}%s${RESET}\n" " !!!       !@!  !!!  !@!  !!!    !!!    !!@!@!    !@!  !!!  !!!       !!!@!@!!!  !@!   ! !@!  "
    printf "${YELLOW}%s${RESET}\n" " :!!       !!:  !!!  !!:  !!!    !!:    !!: :!!   !!:  !!!  !!:                  !!:     !!:  "
    printf "${ORANGE}%s${RESET}\n" " :!:       :!:  !:!  :!:  !:!    :!:    :!:  !:!  :!:  !:!   :!:                 :!:     :!:  "
    printf "${ORANGE}%s${RESET}\n" "  ::: :::  ::::: ::   ::   ::     ::    ::   :::  ::::: ::   :: ::::             :::     ::   "
    printf "${ORANGE}%s${RESET}\n" "  :: :: :   : :  :   ::    :      :      :   : :   : :  :   : :: : :              :      :    "
    printf "${ORANGE}%s${RESET}\n" ""
}

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

function list_keys() {
    # shellcheck disable=SC2317 # this is intentionals
    API_ACTION="gpg --batch --list-keys --with-colons"
    # shellcheck disable=SC2317 # this is intentionals
    echo -e " ${LIGHT_BLUE} > API Action   : ${Red}${API_ACTION}${Color_Off}"
    # shellcheck disable=SC2317 # this is intentionals
    API_RESULT=$(gpg --batch --list-keys --with-colons 2>/dev/null | awk -F: '/^uid/{split($10,a,"<|>"); print a[1]}')
    # shellcheck disable=SC2317 # this is intentionals
    log_with_timestamp "${PROJECT_LOG_LEVEL}" "${API_RESULT}"
    # shellcheck disable=SC2317 # this is intentionals
    GPG_KEY_LIST_FINAL="${API_RESULT}"

    # shellcheck disable=SC2317 # this is intentionals
    API_ACTION="sed"
    # shellcheck disable=SC2317 # this is intentionals
    API_RESULT=$(echo "${GPG_KEY_LIST_FINAL}" | tr '\n' ',' | sed 's/,$//')
    # shellcheck disable=SC2317 # this is intentionals
    log_with_timestamp "${PROJECT_LOG_LEVEL}" "${API_RESULT}"
    # shellcheck disable=SC2317 # this is intentionals
    GPG_KEY_LIST_FINAL_CSV="${API_RESULT}"
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
    echo -e "${Cyan}./$(basename "$0")${Yellow} --name${Color_Off} orchestrator"
}

# Extract the script arguments
for arg in "$@"; do
    shift
    case "${arg}" in
    '--name') set -- "$@" '-n' ;;
    '--folder') set -- "$@" '-f' ;;
    '--help') set -- "$@" '-h' ;;
    *) set -- "$@" "${arg}" ;;
    esac
done

while getopts ":f:l:n:h" OPTION; do
    case "${OPTION}" in
    f)
        GPG_KEY_WORKING_FOLDER="${OPTARG}"
        ;;
    n)
        GPG_KEY_NAME="${OPTARG}"
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

function list_keys() {

    API_ACTION="gpg --list-keys --with-fingerprint --with-colons"
    API_RESULT=$(gpg --list-keys --with-fingerprint --with-colons 2>/dev/null | grep '^uid:' | cut -d':' -f10 | awk -F'<' '{print $1}')
    log_with_timestamp "${PROJECT_LOG_LEVEL}" "${API_RESULT}"
    GPG_KEY_LIST="${API_RESULT}"

    API_ACTION="sed"
    API_RESULT=$(echo "${GPG_KEY_LIST}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr '\n' ',' | sed 's/,$//')
    log_with_timestamp "${PROJECT_LOG_LEVEL}" "${API_RESULT}"
    GPG_KEY_LIST_CSV="${API_RESULT}"
}

# Show license, logo and info
license
ctmLogo
display_info

function display_project_details() {
    # Define colors
    CYAN="\033[0;36m"
    BLUE="\033[0;34m"
    RESET="\033[0m"

    # Calculate the length of the variable and the number of '-' characters
    LENGTH=${#GPG_KEY_WORKING_FOLDER}
    TOTAL_LENGTH=$((LENGTH + 24)) # 24 is the length of " - Source File   : " string
    # shellcheck disable=SC2183 # this is intentional
    SEPARATOR=$(printf '%*s' "$TOTAL_LENGTH" | tr ' ' '-')

    printf "\n"
    # shellcheck disable=SC2059 # this is intentional
    printf "${RESET} ---- ${CYAN}Project Details${RESET} ----\n"
    printf "${CYAN} - Mode          :${RESET}${BLUE} %s${RESET}\n" "${PROJECT_MODE}"
    printf "${CYAN} - Debug Status  :${RESET}${BLUE} %s${RESET}\n" "${PROJECT_DEBUG}"
    printf "${CYAN} - Name          :${RESET}${BLUE} %s${RESET}\n" "${PROJECT_NAME}"
    printf "${CYAN} - Code          :${RESET}${BLUE} %s${RESET}\n" "${PROJECT_CODE}"
    printf " %s\n" "${SEPARATOR}"
    printf "${CYAN} - GPG Binary         :${RESET}${BLUE} %s${RESET}\n" "${GPG_BIN}"
    printf "${CYAN} - GPG Data Folder    :${RESET}${BLUE} %s${RESET}\n" "${GPG_KEY_WORKING_FOLDER}"
    printf "${CYAN} - GPG Key Name       :${RESET}${BLUE} %s${RESET}\n" "${GPG_KEY_NAME}"
    printf " %s\n" "${SEPARATOR}"
    printf "${CYAN} - GPG Start List     :${RESET}${BLUE} %s${RESET}\n" "${GPG_KEY_LIST_START_CSV}"
    printf "${CYAN} - GPG End List       :${RESET}${BLUE} %s${RESET}\n" "${GPG_KEY_LIST_FINAL_CSV}"
    printf "${CYAN} - GPG Status         :${RESET}${BLUE} %s${RESET}\n" "${GPG_KEY_STATUS}"
    printf " %s\n" "${SEPARATOR}"
}

# -- End of boilerplate --

SCRIPT_PURPOSE="delete gpg private and public keys"

# exit script if no ctm orderid provided
if [ -z "${GPG_KEY_NAME}" ]; then
    usage
    list_keys
    GPG_KEY_LIST_FINAL_CSV="${GPG_KEY_LIST_CSV}"
    printf "\n"
    # shellcheck disable=SC2059 # this is intentional
    printf "${Purple}Environment:${Color_Off}\n"
    printf "${CYAN}GPG Known List = ${RESET}${BLUE}'%s'${RESET}\n" "${GPG_KEY_LIST_FINAL_CSV}"
    exit 1
fi

# Assign GPG binary
GPG_BIN=$(which gpg)

# Replace " " with "_"
# shellcheck disable=SC2006 disable=SC2001 # this is intentional
GPG_KEY_NAME=$(echo "${GPG_KEY_NAME}" | sed 's/ /_/g')
GPG_KEY_NAME_LCASE=$(echo "${GPG_KEY_NAME}" | tr '[:upper:]' '[:lower:]')

# Assign default working folder
if [ -z "${GPG_KEY_WORKING_FOLDER}" ]; then
    GPG_KEY_WORKING_FOLDER="${WORKING_DIR}/gpg/${GPG_KEY_NAME_LCASE}"
fi

API_ACTION="Delete working folder"
echo " "
echo -e " ${LIGHT_BLUE} # Stage       -> ${LIGHT_CYAN}${API_ACTION}${Color_Off}"
log_with_timestamp "INFO" "Start"

# Delete old files
if [ -d "${GPG_KEY_WORKING_FOLDER}" ]; then
    API_ACTION="rm"
    API_RESULT=$(rm -rf "${GPG_KEY_WORKING_FOLDER}")
    log_with_timestamp "${PROJECT_LOG_LEVEL}" "${API_RESULT}"
fi

API_ACTION="Delete OpenPGP key"
echo " "
echo -e " ${LIGHT_BLUE} # Stage       -> ${LIGHT_CYAN}${API_ACTION}${Color_Off}"
log_with_timestamp "INFO" "Start"

# Get current key(s)
list_keys
GPG_KEY_LIST_START_CSV="${GPG_KEY_LIST_CSV}"

# Process GPG requests
# remove any existing keys
API_ACTION="gpg --list-keys --with-fingerprint --with-colons"
echo -e " ${LIGHT_BLUE} > API Action   : ${Red}${API_ACTION}${Color_Off}"
API_RESULT=$(gpg --list-keys --with-fingerprint --with-colons "${GPG_KEY_NAME}" 2>/dev/null | grep '^fpr' | cut -d':' -f10)
log_with_timestamp "${PROJECT_LOG_LEVEL}" "${API_RESULT}"
GPG_KEY_FINGERPRINTS="${API_RESULT}"

API_ACTION="gpg --batch --list-keys --with-colons"
echo -e " ${LIGHT_BLUE} > API Action   : ${Red}${API_ACTION}${Color_Off}"
API_RESULT=$(gpg --batch --list-keys --with-colons 2>/dev/null | awk -F: '/^uid/{split($10,a,"<|>"); print a[1]}')
log_with_timestamp "${PROJECT_LOG_LEVEL}" "${API_RESULT}"
GPG_KEY_LIST="${API_RESULT}"

# remove any existing keys
# for GPG_KEY in ${GPG_KEY_LIST}; do

#     if [[ "${GPG_KEY}" == *"${GPG_KEY_NAME_PUBLIC}"* ]]; then

#         API_ACTION="gpg key:*"
#         echo -e " ${LIGHT_BLUE} > API Action   : ${Red}${API_ACTION}${Color_Off}"
#         API_RESULT=${GPG_KEY%%:*}
#         log_with_timestamp "${PROJECT_LOG_LEVEL}" "${API_RESULT}"
#         GPG_FINGERPRINT="${API_RESULT}"

#         API_ACTION="gpg --batch --list-secret-keys --with-colons"
#         echo -e " ${LIGHT_BLUE} > API Action   : ${Red}${API_ACTION}${Color_Off}"
#         API_RESULT=$(gpg --batch --list-secret-keys --with-colons ${GPG_FINGERPRINT} 2>/dev/null)
#         log_with_timestamp "${PROJECT_LOG_LEVEL}" "${API_RESULT}"
#         GPG_SECRET_KEYS="${API_RESULT}"

#         if [[ -n "${GPG_SECRET_KEYS}" ]]; then
#             API_ACTION="gpg --list-keys --with-fingerprint --with-colons"
#             echo -e " ${LIGHT_BLUE} > API Action   : ${Red}${API_ACTION}${Color_Off}"
#             API_RESULT=$(gpg --list-keys --with-fingerprint --with-colons ${GPG_KEY_NAME} 2>/dev/null | grep '^fpr' | cut -d':' -f10)
#             log_with_timestamp "${PROJECT_LOG_LEVEL}" "${API_RESULT}"
#             GPG_KEY_FINGERPRINTS_PUBLIC="${API_RESULT}"

#             API_ACTION="sed"
#             API_RESULT=$(echo "${GPG_KEY_FINGERPRINTS_PUBLIC}" | tr '\n' ',' | sed 's/,$//')
#             log_with_timestamp "${PROJECT_LOG_LEVEL}" "${API_RESULT}"
#             GPG_KEY_FINGERPRINTS_PUBLIC_CSV="${API_RESULT}"

#             # Loop through all the fingerprints and delete the corresponding key(s)
#             for GPG_KEY_FINGERPRINT in ${GPG_KEY_FINGERPRINTS_PUBLIC}; do

#                 API_ACTION="gpg --batch --yes --delete-secret-keys"
#                 echo -e " ${LIGHT_BLUE} > API Action   : ${Red}${API_ACTION}${Color_Off}"
#                 API_RESULT=$(gpg --batch --yes --delete-secret-keys ${GPG_KEY_FINGERPRINT} 2>/dev/null)
#                 log_with_timestamp "${PROJECT_LOG_LEVEL}" "${API_RESULT}"
#                 GPG_KEY_RESULT="${API_RESULT}"

#                 API_ACTION="gpg --batch --yes --delete-key"
#                 echo -e " ${LIGHT_BLUE} > API Action   : ${Red}${API_ACTION}${Color_Off}"
#                 API_RESULT=$(gpg --batch --yes --delete-key ${GPG_KEY_FINGERPRINT} 2>/dev/null)
#                 log_with_timestamp "${PROJECT_LOG_LEVEL}" "${API_RESULT}"
#                 GPG_KEY_RESULT="${API_RESULT}"
#             done
#         else
#             API_ACTION="gpg --batch --yes --delete-keys"
#             echo -e " ${LIGHT_BLUE} > API Action   : ${Red}${API_ACTION}${Color_Off}"
#             API_RESULT=$(gpg --batch --yes --delete-keys ${GPG_FINGERPRINT} 2>/dev/null)
#             log_with_timestamp "${PROJECT_LOG_LEVEL}" "${API_RESULT}"
#             GPG_KEY_RESULT="${API_RESULT}"
#         fi
#     fi
# done

API_ACTION="gpg --list-keys --with-fingerprint --with-colons"
echo -e " ${LIGHT_BLUE} > API Action   : ${Red}${API_ACTION}${Color_Off}"
API_RESULT=$(gpg --list-keys --with-fingerprint --with-colons "${GPG_KEY_NAME}" 2>/dev/null | grep '^fpr' | cut -d':' -f10)
log_with_timestamp "${PROJECT_LOG_LEVEL}" "${API_RESULT}"
GPG_KEY_FINGERPRINTS="${API_RESULT}"

# GPG_KEY_FINGERPRINTS=$(gpg --list-keys --with-fingerprint --with-colons "${GPG_KEY_NAME}" 2>/dev/null | grep '^fpr' | cut -d':' -f10)

# Loop through all the fingerprints and delete the corresponding key(s)
for GPG_KEY_FINGERPRINT in ${GPG_KEY_FINGERPRINTS}; do

    API_ACTION="gpg --batch --yes --delete-secret-keys"
    echo -e " ${LIGHT_BLUE} > API Action   : ${Red}${API_ACTION}${Color_Off}"
    API_RESULT=$(gpg --batch --yes --delete-secret-keys "${GPG_KEY_FINGERPRINT}" 2>/dev/null)
    log_with_timestamp "${PROJECT_LOG_LEVEL}" "${API_RESULT}"

    API_ACTION="gpg --batch --yes --delete-key"
    echo -e " ${LIGHT_BLUE} > API Action   : ${Red}${API_ACTION}${Color_Off}"
    API_RESULT=$(gpg --batch --yes --delete-key "${GPG_KEY_FINGERPRINT}" 2>/dev/null)
    log_with_timestamp "${PROJECT_LOG_LEVEL}" "${API_RESULT}"

done

API_ACTION="Final Report"
echo " "
echo -e " ${LIGHT_BLUE} # Stage       -> ${LIGHT_CYAN}${API_ACTION}${Color_Off}"
log_with_timestamp "INFO" "Start"

# Get current key(s)
list_keys
GPG_KEY_LIST_FINAL_CSV="${GPG_KEY_LIST_CSV}"

# GPG_KEY_LIST=$(gpg --batch --list-keys --with-colons "${GPG_KEY_NAME}" | grep '^fpr' | cut -d':' -f10 | tr '\n' ',' | sed 's/,$//')
# GPG_KEY_LIST_CSV=$(echo "${GPG_KEY_LIST}" | tr '\n' ',' | sed 's/,$//')

GPG_KEY_STATUS="Error"
if [ "${GPG_KEY_LIST_FINAL_CSV}" != "${GPG_KEY_LIST_START_CSV}" ]; then
    GPG_KEY_STATUS="OK"
fi

if [[ "${GPG_KEY_LIST_FINAL_CSV}" != *"${GPG_KEY_NAME}"* ]]; then
    GPG_KEY_STATUS="OK"
fi

display_project_details

# Clean Up
