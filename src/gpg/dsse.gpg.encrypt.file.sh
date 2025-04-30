#!/bin/bash
set +x
# shellcheck enable=require-variable-braces
# file name: dsse.gpg.encrypt.file.sh
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
# shellcheck disable=SC2034 # this is intentionals
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
    CHECKSUM_SHA_CMD="sha3sum"

else
    # Assuming Linux for other cases
    # shellcheck disable=SC2034 # this is intentionals
    DISTRIBUTION=$(cat /etc/*-release | uniq -u | grep "^NAME" | awk -F "=" '{ gsub("\"", "",$2); print $2}')
    DISTRIBUTION_PRETTY_NAME=$(cat /etc/*-release | uniq -u | grep "^PRETTY_NAME" | awk -F "=" '{ gsub("\"", "",$2); print $2}')
    # shellcheck disable=SC2116 # this is intentionals
    USER_NAME=$(whoami)
    # shellcheck disable=SC2034 # this is intentionals
    USER_HOME=$(getent passwd "${USER_NAME}" | cut -d: -f6)
    USER_GROUP=$(id -gn "${USER_NAME}")
    USER_GROUPS=$(groups "${USER_NAME}")
    HOST_IPV4=$(ip address | grep -v "127.0.0" | grep "inet " | awk '{print $2}' | awk -F "/" '{print $1}' | head -n 1)
    CHECKSUM_SHA_CMD="sha512sum"
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
    printf "\n"
    # shellcheck disable=SC2059 # this is intentionals
    printf "${Purple}Example:${Color_Off}\n"
    # shellcheck disable=SC2059 # this is intentionals
    printf "${Cyan}./$(basename "$0")${Yellow} --passphrase${Color_Off} abcd1234 ${Yellow}--recipient${Color_Off} orchestrator ${Yellow}--file${Color_Off} /tmp/zzm/data.log\n"
    # shellcheck disable=SC2059 # this is intentionals
    printf "${Cyan}./$(basename "$0")${Yellow} --recipient${Color_Off} mftuser@trybmc.local ${Yellow}--file${Color_Off} /mnt/client/pgp/data/data.txt\n"
}

# Extract the script arguments
for arg in "$@"; do
    shift
    case "${arg}" in
    '--file') set -- "$@" '-f' ;;
    '--passphrase') set -- "$@" '-p' ;;
    '--recipient') set -- "$@" '-r' ;;
    '--help') set -- "$@" '-h' ;;
    *) set -- "$@" "${arg}" ;;
    esac
done

while getopts ":f:p:r:h" OPTION; do
    case "${OPTION}" in
    f)
        GPG_FILE_IN="${OPTARG}"
        ;;
    p)
        GPG_KEY_PASSPHRASE="${OPTARG}"
        ;;
    r)
        GPG_KEY_RECIPIENT="${OPTARG}"
        ;;
    ?)
        usage
        exit 1
        ;;
    esac

done

shift "$((OPTIND - 1))"

# Sleep Time for AWS API calls
# shellcheck disable=SC2034 # this is intentionals
SLEEP_TIME="15"

function display_info() {
    # Define colors
    DARK_BLUE="\033[0;34m"
    LIGHT_CYAN="\033[1;36m"
    RESET="\033[0m"

    # Calculate the length of the variable and the number of '-' characters
    LENGTH=${#JAVA_HOME}
    TOTAL_LENGTH=$((LENGTH + 24)) # 24 is the length of " - Source File   : " string
    # shellcheck disable=SC2183 # this is intentionals
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
    LENGTH=${#DATA_PATH_OUT}
    TOTAL_LENGTH=$((LENGTH + 28)) # 24 is the length of " - Source File   : " string
    # shellcheck disable=SC2183 # this is intentionals
    SEPARATOR=$(printf '%*s' "$TOTAL_LENGTH" | tr ' ' '-')

    printf "\n"
    # shellcheck disable=SC2059 # this is intentionals
    printf "${RESET} ---- ${CYAN}Project Details${RESET} ----\n"
    printf "${CYAN} - Mode          :${RESET}${BLUE} %s${RESET}\n" "${PROJECT_MODE}"
    printf "${CYAN} - Debug Status  :${RESET}${BLUE} %s${RESET}\n" "${PROJECT_DEBUG}"
    printf "${CYAN} - Name          :${RESET}${BLUE} %s${RESET}\n" "${PROJECT_NAME}"
    printf "${CYAN} - Code          :${RESET}${BLUE} %s${RESET}\n" "${PROJECT_CODE}"
    printf "${CYAN} - Log File      :${RESET}${BLUE} %s${RESET}\n" "${LOG_FILE}"
    printf " %s\n" "${SEPARATOR}"
    printf "${CYAN} - GPG Binary           :${RESET}${BLUE} %s${RESET}\n" "${GPG_BIN}"
    printf " %s\n" "${SEPARATOR}"
    printf "${CYAN} - GPG Recipient        :${RESET}${BLUE} %s${RESET}\n" "${GPG_KEY_RECIPIENT}"
    printf "${CYAN} - GPG Recipient ID     :${RESET}${BLUE} %s${RESET}\n" "${GPG_RECIPIENT_ID}"
    printf "${CYAN} - GPG Recipient Key    :${RESET}${BLUE} %s${RESET}\n" "${GPG_KEY_NAME}"
    printf "${CYAN} - GPG Recipient E-Mail :${RESET}${BLUE} %s${RESET}\n" "${GPG_KEY_EMAIL}"
    printf " %s\n" "${SEPARATOR}"
    printf "${CYAN} - GPG Passphrase       :${RESET}${BLUE} %s${RESET}\n" "${GPG_KEY_PASSPHRASE}"
    printf "${CYAN} - GPG Data Folder      :${RESET}${BLUE} %s${RESET}\n" "${DATA_FOLDER}"
    printf "${CYAN} - GPG File In          :${RESET}${BLUE} %s${RESET}\n" "${DATA_FILE_IN}"
    printf "${CYAN} - GPG File Out         :${RESET}${BLUE} %s${RESET}\n" "${DATA_FILE_OUT}"
    printf "${CYAN} - GPG Path In          :${RESET}${BLUE} %s${RESET}\n" "${DATA_PATH_IN}"
    printf "${CYAN} - GPG Path Out         :${RESET}${BLUE} %s${RESET}\n" "${DATA_PATH_OUT}"
    printf "${CYAN} - GPG Content Lenght   :${RESET}${BLUE} %s${RESET}\n" "${GPG_CONTENT_LENGHT}"
    printf " %s\n" "${SEPARATOR}"
    printf "${CYAN} - GPG Status           :${RESET}${BLUE} %s${RESET}\n" "${GPG_STATUS}"
    printf " %s\n" "${SEPARATOR}"
    printf "${CYAN} - File Checksum MD5    :${RESET}${BLUE} %s${RESET}\n" "${CHECKSUM_MD5}"
    printf "${CYAN} - File Checksum SHA    :${RESET}${BLUE} %s${RESET}\n" "${CHECKSUM_SHA512}"
    printf " %s\n" "${SEPARATOR}"

}

# -- End of boilerplate --

# Exit script if no import file
if [[ -z "${GPG_KEY_RECIPIENT}" ]]; then
    usage
    exit 1
fi

# Assign GPG binary
GPG_BIN=$(which gpg)

# Process GPG requests
# Compute Folder and PAth names for encrypted files
DATA_PATH_IN="${GPG_FILE_IN}"
DATA_FOLDER=$(dirname "${DATA_PATH_IN}")
DATA_FILE_IN=$(basename "${DATA_PATH_IN}")

if [ -z "${GPG_FILE_OUT}" ]; then
    DATA_FILE_OUT="$(basename "${DATA_PATH_IN}").gpg.asc"
    DATA_PATH_OUT="${DATA_FOLDER}/${DATA_FILE_OUT}"
fi

API_ACTION="Get OpenPGP key details"
printf " ${LIGHT_BLUE} # Stage       -> ${RESET}${LIGHT_CYAN} %s${RESET}\n" "${API_ACTION}"
log_with_timestamp "INFO" "Start"

API_ACTION="gpg --batch --list-keys --with-colons"
printf " ${LIGHT_BLUE} > API Action   : ${RESET}${Red} %s${RESET}\n" "${API_ACTION}"
# shellcheck disable=SC2086 # this is intentionals
API_RESULT=$(gpg --batch --list-keys --with-colons ${GPG_KEY_RECIPIENT} 2>/dev/null)
log_with_timestamp "${PROJECT_LOG_LEVEL}" "${API_RESULT}"
GPG_KEY_LIST="${API_RESULT}"

API_ACTION="grep, cut"
API_RESULT=$(echo "${GPG_KEY_LIST}" | grep "^pub" | cut -d ":" -f 5)
log_with_timestamp "${PROJECT_LOG_LEVEL}" "${API_RESULT}"
GPG_RECIPIENT_ID="${API_RESULT}"

API_ACTION="gpg --list-keys --with-fingerprint --with-colons"
printf " ${LIGHT_BLUE} > API Action   : ${RESET}${Red} %s${RESET}\n" "${API_ACTION}"
# shellcheck disable=SC2086 # this is intentionals
API_RESULT=$(gpg --list-keys --with-fingerprint --with-colons ${GPG_KEY_RECIPIENT} 2>/dev/null)
log_with_timestamp "${PROJECT_LOG_LEVEL}" "${API_RESULT}"
GPG_KEY_DETAILS="${API_RESULT}"

API_ACTION="grep, cut, awk"
# shellcheck disable=SC2086 # this is intentionals
API_RESULT=$(echo ${GPG_KEY_DETAILS} | grep '^uid:' | cut -d':' -f10 | awk -F'<' '{print $1}')
log_with_timestamp "${PROJECT_LOG_LEVEL}" "${API_RESULT}"
GPG_KEY_NAME_TEMP="${API_RESULT}"

API_ACTION="sed"
# shellcheck disable=SC2086 # this is intentionals
API_RESULT=$(echo ${GPG_KEY_NAME_TEMP} | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr '\n' ',' | sed 's/,$//')
log_with_timestamp "${PROJECT_LOG_LEVEL}" "${API_RESULT}"
GPG_KEY_NAME="${API_RESULT}"

API_ACTION="grep, cut, awk"
# shellcheck disable=SC2086 # this is intentionals
API_RESULT=$(echo ${GPG_KEY_DETAILS} | grep '^uid:' | cut -d':' -f10 | awk -F'<' '{print $2}')
log_with_timestamp "${PROJECT_LOG_LEVEL}" "${API_RESULT}"
GPG_KEY_EMAIL_TEMP="${API_RESULT}"

API_ACTION="sed"
# shellcheck disable=SC2086 # this is intentionals
API_RESULT=$(echo ${GPG_KEY_EMAIL_TEMP} | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr '\n' ',' | sed 's/,$//' | sed 's/>//')
log_with_timestamp "${PROJECT_LOG_LEVEL}" "${API_RESULT}"
GPG_KEY_EMAIL="${API_RESULT}"

# shellcheck disable=SC2236 # this is intentional
if [ ! -z "${GPG_RECIPIENT_ID}" ]; then
    if [[ -f "${DATA_PATH_IN}" ]]; then

        # Encrypt the file
        API_ACTION="Encrypt File"
        printf " ${LIGHT_BLUE} # Stage       -> ${RESET}${LIGHT_CYAN} %s${RESET}\n" "${API_ACTION}"
        log_with_timestamp "INFO" "Start"

        if [ -z "${GPG_KEY_PASSPHRASE}" ]; then

            API_ACTION="gpg --batch --yes --recipient --output --encrypt --armor"
            printf " ${LIGHT_BLUE} > API Action   : ${RESET}${Red} %s${RESET}\n" "${API_ACTION}"
            # shellcheck disable=SC2086 # this is intentionals
            API_RESULT=$(gpg --batch --yes --recipient ${GPG_RECIPIENT_ID} --output ${DATA_PATH_OUT} --encrypt --armor ${DATA_PATH_IN} 2>&1)
            log_with_timestamp "${PROJECT_LOG_LEVEL}" "${API_RESULT}"

        else

            API_ACTION="gpg --batch --yes --recipient --passphrase --output --encrypt --armor"
            printf " ${LIGHT_BLUE} > API Action   : ${RESET}${Red} %s${RESET}\n" "${API_ACTION}"
            API_RESULT=$(gpg --batch --yes --recipient "${GPG_RECIPIENT_ID}" --passphrase "${GPG_KEY_PASSPHRASE}" --output "${DATA_PATH_OUT}" --encrypt --armor "${DATA_PATH_IN}" 2>&1)
            log_with_timestamp "${PROJECT_LOG_LEVEL}" "${API_RESULT}"
        fi

        API_ACTION="Verify File"
        printf " ${LIGHT_BLUE} # Stage       -> ${RESET}${LIGHT_CYAN} %s${RESET}\n" "${API_ACTION}"
        log_with_timestamp "INFO" "Start"

        API_ACTION="gpg --batch --yes --list-packets --no-tty --passphrase-fd 0"
        printf " ${LIGHT_BLUE} > API Action   : ${RESET}${Red} %s${RESET}\n" "${API_ACTION}"
        API_RESULT=$(echo "${GPG_KEY_PASSPHRASE}" | gpg --batch --yes --list-packets --no-tty --passphrase-fd 0 "${DATA_PATH_OUT}" 2>&1)
        log_with_timestamp "${PROJECT_LOG_LEVEL}" "${API_RESULT}"
        GPG_CMD_RESULT="${API_RESULT}"

        API_ACTION="grep, awk"
        API_RESULT=$(echo "${GPG_CMD_RESULT}" | grep 'length:' | awk -F: '/:/ { print $2 }' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
        log_with_timestamp "${PROJECT_LOG_LEVEL}" "${API_RESULT}"
        GPG_CONTENT_LENGHT="${API_RESULT}"

        if [ "${GPG_CONTENT_LENGTH}" == "unknown" ]; then
            GPG_STATUS="TRUE"
        elif [[ "${GPG_CONTENT_LENGTH}" =~ ^[0-9]+$ ]] && [ "${GPG_CONTENT_LENGTH}" -gt 0 ]; then
            GPG_STATUS="TRUE"
        else
            GPG_STATUS="FALSE"
        fi

        if [[ -f "${DATA_PATH_OUT}" ]]; then
            API_ACTION="Checksum File"
            printf " ${LIGHT_BLUE} # Stage       -> ${RESET}${LIGHT_CYAN} %s${RESET}\n" "${API_ACTION}"
            log_with_timestamp "INFO" "Start"

            API_ACTION="md5sum"
            printf " ${LIGHT_BLUE} > API Action   : ${RESET}${Red} %s${RESET}\n" "${API_ACTION}"
            API_RESULT=$(md5sum "${DATA_PATH_OUT}" | awk -F' ' '{print $1}')
            log_with_timestamp "${PROJECT_LOG_LEVEL}" "${API_RESULT}"
            CHECKSUM_MD5="${API_RESULT}"

            API_ACTION="${CHECKSUM_SHA_CMD}"
            printf " ${LIGHT_BLUE} > API Action   : ${RESET}${Red} %s${RESET}\n" "${API_ACTION}"
            API_RESULT=$(${CHECKSUM_SHA_CMD} "${DATA_PATH_OUT}" | awk -F' ' '{print $1}')
            log_with_timestamp "${PROJECT_LOG_LEVEL}" "${API_RESULT}"
            CHECKSUM_SHA512="${API_RESULT}"
        fi

    fi
fi

# log the result
display_project_details
