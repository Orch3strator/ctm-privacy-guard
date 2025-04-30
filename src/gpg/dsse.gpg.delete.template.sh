#!/bin/bash
set +x
# shellcheck enable=require-variable-braces
# file name: dsse.gpg.delete.template.sh
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
    printf "\n"
    # shellcheck disable=SC2059 # this is intentional
    printf "${Purple}Example:${Color_Off}\n"
    # shellcheck disable=SC2059 # this is intentional
    printf "${Cyan}./$(basename "$0")${Yellow} --template${Color_Off} name ${Yellow} --environment${Color_Off} fahrschule${Yellow}\n"
    # shellcheck disable=SC2059 # this is intentional
    printf "${Cyan}./$(basename "$0")${Yellow} --template${Color_Off} ALL ${Yellow} --environment${Color_Off} fahrschule${Yellow} --node ${Color_Off}ctm-lin.trybmc.local\n"
}

# Extract the script arguments
for arg in "$@"; do
    shift
    case "${arg}" in
    '--node') set -- "$@" '-n' ;;
    '--template') set -- "$@" '-t' ;;
    '--environment') set -- "$@" '-z' ;;
    '--help') set -- "$@" '-h' ;;
    *) set -- "$@" "${arg}" ;;
    esac
done

while getopts ":n:t:z:h" OPTION; do
    case "${OPTION}" in
    n)
        CTM_NODE="${OPTARG}"
        ;;
    t)
        GPG_TEMPLATE="${OPTARG}"
        ;;
    z)
        CTM_ENV="${OPTARG}"
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
ctmLogo
display_info

function display_project_details() {
    # Define colors
    CYAN="\033[0;36m"
    BLUE="\033[0;34m"
    RESET="\033[0m"

    # Calculate the length of the variable and the number of '-' characters
    LENGTH=${#GPG_KEY_WORKING_FOLDER}
    TOTAL_LENGTH=$((LENGTH + 28)) # 24 is the length of " - Source File   : " string
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
    printf "${CYAN} - CTM Environment     :${RESET}${BLUE} %s${RESET}\n" "${CTM_ENV}"
    printf "${CYAN} - CTM Server          :${RESET}${BLUE} %s${RESET}\n" "${CTM_SERVER}"
    printf "${CYAN} - CTM Node ID         :${RESET}${BLUE} %s${RESET}\n" "${CTM_NODE}"
    printf "${CYAN} - CTM Agents #        :${RESET}${BLUE} %s${RESET}\n" "${CTM_AGENT_COUNT}"
    printf "${CYAN} - CTM Active Agents   :${RESET}${BLUE} %s${RESET}\n" "${CTM_ALL_ACTIVE_AGENTS}"
    printf " %s\n" "${SEPARATOR}"
    # shellcheck disable=SC2059 # this is intentional
    printf "${RESET} ---- ${Green}Processing Control-M Agents${RESET} ----\n"

    IFS=',' read -ra CTM_AGENT_TEMP <<<"${CTM_ACTIVE_AGENTS}"
    for CTM_AGENT in "${CTM_AGENT_TEMP[@]}"; do
        printf "${CYAN} - CTM Agent           :${RESET}${BLUE} %s${RESET}\n" "${CTM_AGENT}"
    done

    printf " %s\n" "${SEPARATOR}"
    printf "${CYAN} - GPG Template Name   :${RESET}${BLUE} %s${RESET}\n" "${GPG_KEY_NAME}"
    printf "${CYAN} - GPG Recipient       :${RESET}${BLUE} %s${RESET}\n" "${GPG_KEY_RECIPIENT}"
    printf " %s\n" "${SEPARATOR}"
    printf "${CYAN} - GPG Binary Local    :${RESET}${BLUE} %s${RESET}\n" "${GPG_PATH}"
    printf "${CYAN} - GPG Working Folder  :${RESET}${BLUE} %s${RESET}\n" "${GPG_KEY_WORKING_FOLDER}"
    printf " %s\n" "${SEPARATOR}"

}

# -- End of boilerplate --

# exit script if no ctm orderid provided
if [ -z "${GPG_TEMPLATE}" ]; then
    usage
    exit 1
fi

API_ACTION="Get Control-M Agent details"
echo " "
echo -e " ${LIGHT_BLUE} # Stage       -> ${LIGHT_CYAN}${API_ACTION}${Color_Off}"
log_with_timestamp "INFO" "Start"

# Get first CTM server
API_ACTION="ctm config servers::get"
# printf " ${LIGHT_BLUE} > API Action   : ${RESET}${Red} %s${RESET}\n" "${API_ACTION}"
API_RESULT=$(ctm config servers::get -e "${CTM_ENV}" 2>&1 | jq -r '.[0].name')
log_with_timestamp "${PROJECT_LOG_LEVEL}" "${API_RESULT}"
CTM_SERVER="${API_RESULT}"

# Get all agent(s) on server
API_ACTION="ctm config server:agents::get"
# printf " ${LIGHT_BLUE} > API Action   : ${RESET}${Red} %s${RESET}\n" "${API_ACTION}"
API_RESULT=$(ctm config server:agents::get "${CTM_SERVER}" -e "${CTM_ENV}" 2>&1)
log_with_timestamp "${PROJECT_LOG_LEVEL}" "${API_RESULT}"
CTM_AGENTS="${API_RESULT}"

API_ACTION="jq"
# printf " ${LIGHT_BLUE} > API Action   : ${RESET}${Red} %s${RESET}\n" "${API_ACTION}"
API_RESULT=$(echo "${CTM_AGENTS}" | jq -r '.agents | map(select(.status == "Available")) | length')
log_with_timestamp "${PROJECT_LOG_LEVEL}" "${API_RESULT}"
CTM_AGENT_COUNT="${API_RESULT}"

API_ACTION="jq"
# printf " ${LIGHT_BLUE} > API Action   : ${RESET}${Red} %s${RESET}\n" "${API_ACTION}"
API_RESULT=$(echo "${CTM_AGENTS}" | jq -r '.agents | map(select(.status == "Available")) | .[].nodeid' | tr '\n' ',' | sed 's/,$//')
log_with_timestamp "${PROJECT_LOG_LEVEL}" "${API_RESULT}"
CTM_ACTIVE_AGENTS="${API_RESULT}"
CTM_ALL_ACTIVE_AGENTS="${API_RESULT}"

# check if provided agent is active
if [ -n "${CTM_NODE}" ]; then
    if [[ "${CTM_ACTIVE_AGENTS}" =~ (^|,)${CTM_NODE}($|,) ]]; then
        CTM_ACTIVE_AGENTS="${CTM_NODE}"
    else
        CTM_ACTIVE_AGENTS=""
    fi
fi

# Get MFT config for active agent
IFS=',' read -ra CTM_AGENT_TEMP <<<"${CTM_ACTIVE_AGENTS}"
for CTM_AGENT in "${CTM_AGENT_TEMP[@]}"; do
    printf "\n"
    printf "${RESET} ---- ${CYAN}Agent Evaluation${RESET} ---- ${Yellow}%s${RESET}\n" "${CTM_AGENT}"
    API_ACTION="ctm config server:agent:mft:configuration::get"
    # printf " ${LIGHT_BLUE} > API Action   : ${RESET}${Blue} %s${RESET}\n" "${API_ACTION}"
    API_RESULT=$(ctm config server:agent:mft:configuration::get "${CTM_SERVER}" "${CTM_AGENT}" -e "${CTM_ENV}" 2>/dev/null)
    log_with_timestamp "${PROJECT_LOG_LEVEL}" "${API_RESULT}"
    CTM_CMD_RESULT="${API_RESULT}"

    API_ACTION="jq"
    # printf " ${LIGHT_BLUE} > API Action   : ${RESET}${Red} %s${RESET}\n" "${API_ACTION}"
    API_RESULT=$(echo "${CTM_CMD_RESULT}" | jq -r '.pgpTempDir')
    log_with_timestamp "${PROJECT_LOG_LEVEL}" "${API_RESULT}"
    CTM_TEMPLATE_TEMP="${API_RESULT}"

    if test -n "${CTM_TEMPLATE_TEMP}"; then

        API_ACTION="ctm config server:agent:mft:pgptemplates::get"
        # printf " ${LIGHT_BLUE} > API Action   : ${RESET}${Red} %s${RESET}\n" "${API_ACTION}"
        API_RESULT=$(ctm config server:agent:mft:pgptemplates::get "${CTM_SERVER}" "${CTM_AGENT}" -s name="${GPG_KEY_NAME}" -e "${CTM_ENV}")
        log_with_timestamp "${PROJECT_LOG_LEVEL}" "${API_RESULT}"
        CTM_CMD_RESULT="${API_RESULT}"

        # Get template names
        API_ACTION="jq"
        # printf " ${LIGHT_BLUE} > API Action   : ${RESET}${Red} %s${RESET}\n" "${API_ACTION}"
        API_RESULT=$(echo "${CTM_CMD_RESULT}" | jq -r .[].name | tr '\n' ',' | sed 's/,$//')
        log_with_timestamp "${PROJECT_LOG_LEVEL}" "${API_RESULT}"
        CTM_ALL_ACTIVE_TEMP="${API_RESULT}"

        # Remove PGP_TEMPLATE and GnuPG_TEMPLATE from list -> do not delete
        API_ACTION="sed"
        # printf " ${LIGHT_BLUE} > API Action   : ${RESET}${Red} %s${RESET}\n" "${API_ACTION}"
        #API_RESULT=$(echo "${CTM_ALL_ACTIVE_TEMP}" | sed 's/PGP_TEMPLATE,//g; s/GnuPG_TEMPLATE,//g')

        API_RESULT=$(echo "${CTM_ALL_ACTIVE_TEMP}" | tr ',' '\n' | grep -vE '^(PGP_TEMPLATE|GnuPG_TEMPLATE)$' | tr '\n' ',' | sed 's/,$//')
        log_with_timestamp "${PROJECT_LOG_LEVEL}" "${API_RESULT}"
        CTM_ALL_ACTIVE_TEMPLATES="${API_RESULT}"

        # Keep template names for processing
        CTM_ACTIVE_TEMPLATES="${API_RESULT}"

        # log template info
        API_ACTION="assigned template"
        log_with_timestamp "${PROJECT_LOG_LEVEL}" "${GPG_TEMPLATE}"
        API_ACTION="all active templates"
        log_with_timestamp "${PROJECT_LOG_LEVEL}" "${CTM_ALL_ACTIVE_TEMPLATES}"

        API_RESULT=$(echo "${CTM_CMD_RESULT}" | jq '. | length')
        # shellcheck disable=SC2116 disable=SC2034 # this is intentional
        CTM_PGP_TEMPLATE_COUNT="${API_RESULT}"

        # check if provided template is active
        if [ -n "${GPG_TEMPLATE}" ]; then
            if [[ "${CTM_ACTIVE_TEMPLATES}" =~ (^|,)${GPG_TEMPLATE}($|,) ]]; then
                CTM_ACTIVE_TEMPLATES="${GPG_TEMPLATE}"
            else
                CTM_ACTIVE_TEMPLATES=""
            fi
        fi

        # iterate through all active templates
        if [[ "${GPG_TEMPLATE}" == "ALL" ]]; then
            CTM_ACTIVE_TEMPLATES="${CTM_ALL_ACTIVE_TEMPLATES}"
        fi

        API_ACTION="process templates"
        log_with_timestamp "${PROJECT_LOG_LEVEL}" "${CTM_ACTIVE_TEMPLATES}"

        IFS=',' read -ra CTM_ACTIVE_TEMPLATES <<<"${CTM_ACTIVE_TEMPLATES}"
        # printf "${CYAN} - GPG Template:${RESET}${BLUE} %s${RESET}\n" "${CTM_ACTIVE_TEMPLATE}"
        for CTM_ACTIVE_TEMPLATE in "${CTM_ACTIVE_TEMPLATES[@]}"; do
            GPG_KEY_NAME="${CTM_ACTIVE_TEMPLATE}"

            API_ACTION="current template"
            log_with_timestamp "${PROJECT_LOG_LEVEL}" "${CTM_ACTIVE_TEMPLATE}"

            API_ACTION="ctm config server:agent:mft:pgptemplate::delete"
            # printf " ${LIGHT_BLUE} > API Action   : ${RESET}${Red} %s${RESET}\n" "${API_ACTION}"
            CTM_NOTES="Delete Template: ${GPG_KEY_NAME} on ${CTM_SERVER}:${CTM_AGENT}"
            log_with_timestamp "${PROJECT_LOG_LEVEL}" "${CTM_NOTES}"

            API_RESULT=$(ctm config server:agent:mft:pgptemplate::delete "${CTM_SERVER}" "${CTM_AGENT}" "${GPG_KEY_NAME}" -e "${CTM_ENV}" 2>&1)
            API_RESULT_MESSAGE=$(echo "${API_RESULT}" | jq -r 'if has("message") then .message elif has("errors") then .errors[0].message else empty end')
            log_with_timestamp "${PROJECT_LOG_LEVEL}" "${API_RESULT_MESSAGE}"

            if [[ "${API_RESULT_MESSAGE}" == *"successfully"* ]]; then
                CTM_PGP_STATUS="OK"
                printf "${CYAN}  - CTM API Status: ${Green}'%s'    -> ${DARK_GREY} %s${RESET}\n" "${CTM_PGP_STATUS}" "${CTM_NOTES}"
            else
                CTM_PGP_STATUS="Error"
                printf "${CYAN}  - CTM API Status: ${Red}'%s' -> ${DARK_GREY} %s${RESET}\n" "${CTM_PGP_STATUS}" "${CTM_NOTES}" 
            fi
        done
    fi
done

# log the result
display_project_details

# Pgp Template was added successfully.
# Pgp Template was deleted successfully.
# Pgp Template was added successfully.
# The required field 'executableFullPath' is missing or empty
