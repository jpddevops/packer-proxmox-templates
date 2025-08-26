#!/usr/bin/env bash

set -e

source common.sh

if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
  echo "Usage: script.sh [OPTIONS] [CONFIG_PATH]"
  echo ""
  echo "Options:"
  echo "  -h, --help    Show this help message and exit."
  echo "  -d, --debug   Run builds in debug mode."
  echo ""
  echo "Arguments:"
  echo "  CONFIG_PATH   Path to the configuration directory."
  echo ""
  echo "Examples:"
  echo "  ./build.sh"
  echo "  ./build.sh --help"
  echo "  ./build.sh --debug"
  echo "  ./build.sh config"
  echo "  ./build.sh us-west-1"
  echo "  ./build.sh --debug config"
  echo "  ./build.sh --debug us-west-1"
  exit 0
fi

if [ "$1" == "--debug" ] || [ "$1" == "-d" ]; then
  debug_mode=true
  debug_option="-debug"
  shift
else
  debug_mode=false
  debug_option=""
fi

SCRIPT_PATH=$(realpath "$(dirname "$(follow_link "$0")")")

if [ -n "$1" ]; then
  CONFIG_PATH=$(realpath "$1")
else
  CONFIG_PATH=$(realpath "${SCRIPT_PATH}/config")
fi

menu_message="Select a HashiCorp Packer build for Proxmox."

if [ "$debug_mode" = true ]; then
  menu_message+=" \e[31m(Debug Mode)\e[0m"
fi

menu_option_1() {
  INPUT_PATH="$SCRIPT_PATH"/builds/linux/debian/12/
  BUILD_PATH=${INPUT_PATH#"${SCRIPT_PATH}/builds/"}
  BUILD_VARS="$(echo "${BUILD_PATH%/}" | tr -s '/' | tr '/' '-').pkrvars.hcl"

  echo -e "\nCONFIRM: Build a Debian 12 (Bookworm) Template for Proxmox?"
  echo -e "\nContinue? (y/n)"
  read -r REPLY
  if [[ ! $REPLY =~ ^[Yy]$ ]]
  then
    exit 1
  fi

  ### Build a Debian 12 (Bookworm) for Proxmox. ###
  echo "Building a Debian 12 (Bookworm) for Proxmox..."

  ### Initialize HashiCorp Packer and required plugins. ###
  echo "Initializing HashiCorp Packer and required plugins..."
  packer init "$INPUT_PATH"

  ### Start the Build. ###
  echo "Starting the build...."
  echo "packer build -force -on-error=ask $debug_option"
  packer build -force -on-error=ask $debug_option \
      -var-file="$CONFIG_PATH/ansible.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/build.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/common.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/linux-storage.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/network.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/proxmox.pkrvars.hcl" \
      -var-file="$CONFIG_PATH/$BUILD_VARS" \
      "$INPUT_PATH"

  ### All done. ###
  echo "Done."
}


press_enter() {
  cd "$SCRIPT_PATH"
  echo -n "Press Enter to continue."
  read -r
  clear
}

info() {
  echo "License: BSD-2"
  echo ""
  echo "For more information, review the project README."
  read -r
}

incorrect_selection() {
  echo "Invalid selection, please try again."
}

until [ "$selection" = "0" ]; do
  clear
  echo ""
  echo "    ____                __                  ____                                             "
  echo "   / __ \ ____ _ _____ / /__ ___   _____   / __ \ _____ ____   _  __ ____ ___   ____   _  __ "
  echo '  / /_/ // __ `// ___// //_// _ \ / ___/  / /_/ // ___// __ \ | |/_// __ `__ \ / __ \ | |/_/ '
  echo " / ____// /_/ // /__ / ,<  /  __// /     / ____// /   / /_/ /_>  < / / / / / // /_/ /_>  <   "
  echo '/_/     \__,_/ \___//_/|_| \___//_/     /_/    /_/    \____//_/|_|/_/ /_/ /_/ \____//_/|_|   '
  echo ""
  echo -n "  Select a HashiCorp Packer build for your hypervisor:"
  echo ""
  echo ""
  echo "      Linux Distribution:"
  echo ""
  echo "       1  -  Debian 12"
  echo ""
  echo "      Other:"
  echo ""
  echo "        I   -  Information"
  echo "        Q   -  Quit"
  echo ""
  read -r selection
  echo ""
  case $selection in
    1 ) clear ; menu_option_1  ; press_enter ;;
    [Ii] ) clear ; info ; press_enter ;;
    [Qq] ) clear ; exit ;;
    * ) clear ; incorrect_selection ; press_enter ;;
  esac
done