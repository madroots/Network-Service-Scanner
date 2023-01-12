#!/usr/bin/env bash
# shellcheck disable=SC2034
# COLORS
RESET='\033[0m'
YELLOW='\033[1;33m'
CYAN='\e[36m'
GRAY='\033[0;37m'
WHITE='\033[1;37m'
GRAY_R='\033[39m'
WHITE_R='\033[39m'
RED='\033[1;31m'
GREEN='\033[1;32m'
BLUE='\e[34m'
BOLD='\e[1m'
BLINK='\033[5m'

export GRAY

# LOADER
LOADER() {
clear
echo -e "${YELLOW}*${RESET}"
sleep 0.01; clear
echo -e "${YELLOW}**${RESET}"
sleep 0.01; clear
echo -e "${YELLOW}***${RESET}"
sleep 0.01; clear
echo -e "${YELLOW}****${RESET}"
sleep 0.01; clear
echo -e "${YELLOW}*****${RESET}"
sleep 0.01; clear
echo -e "${YELLOW}******${RESET}"
sleep 0.01; clear
echo -e "${YELLOW}*******${RESET}"
sleep 0.01; clear
echo -e "${YELLOW}********${RESET}"
sleep 0.01; clear
echo -e "${YELLOW}*********${RESET}"
sleep 0.01; clear
echo -e "${YELLOW}**********${RESET}"
sleep 0.01; clear
echo -e "${YELLOW}***********${RESET}"
sleep 0.01; clear
echo -e "${YELLOW}************${RESET}"
sleep 0.01; clear
echo -e "${YELLOW}*************${RESET}"
sleep 0.01; clear
echo -e "${YELLOW}**************${RESET}"
sleep 0.01; clear
echo -e "${YELLOW}***************${RESET}"
sleep 0.01; clear
echo -e "${YELLOW}****************${RESET}"
sleep 0.01; clear
echo -e "${YELLOW}*****************${RESET}"
sleep 0.01; clear
echo -e "${YELLOW}******************${RESET}"
sleep 0.01; clear
echo -e "${YELLOW}*******************${RESET}"
sleep 0.01; clear
echo -e "${YELLOW}********************${RESET}"
sleep 0.01; clear
echo -e "${YELLOW}*********************${RESET}"
sleep 0.01; clear
echo -e "${YELLOW}**********************${RESET}"
sleep 0.01; clear
echo -e "${YELLOW}***********************${RESET}"
sleep 0.01; clear
echo -e "${YELLOW}************************${RESET}"
sleep 0.01; clear
echo -e "${YELLOW}*************************${RESET}"
sleep 0.01; clear
echo -e "${YELLOW}**************************${RESET}"
sleep 0.01; clear
echo -e "${YELLOW}***************************${RESET}"
sleep 0.01; clear
echo -e "${YELLOW}****************************${RESET}"
sleep 0.01; clear
echo -e "${YELLOW}*****************************${RESET}"
sleep 0.01; clear
echo -e "${YELLOW}******************************${RESET}"
sleep 0.01; clear
echo -e "${YELLOW}*******************************${RESET}"
sleep 0.01; clear
echo -e "${YELLOW}********************************${RESET}"
sleep 0.01; clear
echo -e "${YELLOW}*********************************${RESET}"
sleep 0.01; clear
echo -e "${YELLOW}**********************************${RESET}"
sleep 0.01; clear
echo -e "${YELLOW}***********************************${RESET}"
sleep 0.01; clear
echo -e "${YELLOW}************************************${RESET}"
sleep 0.01; clear
echo -e "${YELLOW}*************************************${RESET}"
sleep 0.01; clear
echo -e "${YELLOW}**************************************${RESET}"
sleep 0.01; clear
echo -e "${YELLOW}***************************************${RESET}"
sleep 0.01; clear
echo -e "${YELLOW}****************************************${RESET}"
sleep 0.01; clear
echo -e "${YELLOW}*****************************************${RESET}"
sleep 0.01; clear
echo -e "${YELLOW}******************************************${RESET}"
sleep 0.01; clear
echo -e "${YELLOW}*******************************************${RESET}"
sleep 0.01; clear
echo -e "${GREEN}*******************************************************************${RESET}"
echo -e "${GREEN}&                     NETWORK SERVICE SCANNER                     &${RESET}"
echo -e "${GREEN}*******************************************************************${RESET}"
echo -e "${YELLOW}------------------Find services on your network-------------------- ${RESET} ${BOLD}"
echo
}
LOADER2(){
clear
echo
echo -e "${RED}${BLINK}  ---------- SCANNING ----------${RESET}"
}

SELECT_INTERFACE() {
    LOADER
    interfaces=($(ip link show | awk -F': ' '{print $2}' | grep -v '^lo$'))
    PS3="Select the interface: "
    select interface_name in "${interfaces[@]}"; do
        if [[ -n $interface_name ]]; then
            break
        else
            echo "Invalid selection"
        fi
    done
    DISCOVER_NETWORK $interface_name
}

DISCOVER_NETWORK() {
  clear
  interface_name=$1
  my_ip=$(ip address show "$interface_name" | awk '/inet/ {print $2}' | grep -E '^([0-9]{1,3}\.){3}[0-9]{1,3}' | cut -d '/' -f1)
  my_subnetmask=$(ip address show "$interface_name" | awk '/inet/ {print $2}' | grep -E '^([0-9]{1,3}\.){3}[0-9]{1,3}' | cut -d '/' -f2)
  ip_range="$my_ip/$my_subnetmask"
}

INPUT_NETWORK() {
  read -r -e -p "Enter IP range: " ip_range
  if [[ $ip_range =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\/([0-9]|[1-2][0-9]|3[0-2])$ ]]; then
    echo "Valid IP range."
  else
    echo "Invalid IP range. Please enter a valid IP range in the format xxx.xxx.xxx.xxx/yy."
    INPUT_NETWORK
  fi
}

NMAP_RUN(){
for str in "${ip_range[@]}"; do
  nmap "$str" -Pn -p "$PORT_NO" | grep -B 4 -A 1 open
done
}

ASK_PORT() {
clear
read -r -e -p "Enter port: " PORT_NO
}

NETWORK_SELECT() {
  LOADER
  echo "Please select network IP range:"
  echo "1. AUTODISCOVER"
  echo "2. CUSTOM"
  read -r option

  case $option in
    1) SELECT_INTERFACE;;
    2) INPUT_NETWORK;;
    *) echo "Invalid option. Please try again."; SELECTION;;
  esac
}

SELECTION(){
LOADER
PORT_NO=""
PS3='Make a selection: '
options=("SSH" "VNC" "HTTP" "HTTPS" "TOMCAT" "RTSP" "FTP" "TELNET" "SMTP" "IMAP" "POP3" "LOTUS" "DNS" "NTP" "PRINTERS" "CUSTOM PORT" "EXIT")
select opt in "${options[@]}"
do
    case $opt in
        "SSH")
            echo && echo -e "${YELLOW}Scan started for: $opt${RESET}" ; sleep 2 ; LOADER2 ; PORT_NO="22" ; NMAP_RUN ; exit 0 ;;
        "VNC")
            echo && echo -e "${YELLOW}Scan started for: $opt${RESET}" ; sleep 2 ; LOADER2 ; PORT_NO="5900" ; NMAP_RUN ; exit 0 ;;
        "HTTP")
            echo && echo -e "${YELLOW}Scan started for: $opt${RESET}" ; sleep 2 ; LOADER2 ; PORT_NO="80" ; NMAP_RUN ; exit 0 ;;
        "HTTPS")
            echo && echo -e "${YELLOW}Scan started for: $opt${RESET}" ; sleep 2 ; LOADER2 ; PORT_NO="443" ; NMAP_RUN ; exit 0 ;;
        "TOMCAT")
            echo && echo -e "${YELLOW}Scan started for: $opt${RESET}" ; sleep 2 ; LOADER2 ; PORT_NO="8080" ; NMAP_RUN ; exit 0 ;;
        "RTSP")
            echo && echo -e "${YELLOW}Scan started for: $opt${RESET}" ; sleep 2 ; LOADER2 ; PORT_NO="554" ; NMAP_RUN ; exit 0 ;;
        "FTP")
            echo && echo -e "${YELLOW}Scan started for: $opt${RESET}" ; sleep 2 ; LOADER2 ; PORT_NO="21" ; NMAP_RUN ; exit 0 ;;
        "TELNET")
            echo && echo -e "${YELLOW}Scan started for: $opt${RESET}" ; sleep 2 ; LOADER2 ; PORT_NO="23" ; NMAP_RUN ; exit 0 ;;
        "SMTP")
            echo && echo -e "${YELLOW}Scan started for: $opt${RESET}" ; sleep 2 ; LOADER2 ; PORT_NO="25" ; NMAP_RUN ; exit 0 ;;
        "IMAP")
            echo && echo -e "${YELLOW}Scan started for: $opt${RESET}" ; sleep 2 ; LOADER2 ; PORT_NO="143" ; NMAP_RUN ; exit 0 ;;
        "POP3")
            echo && echo -e "${YELLOW}Scan started for: $opt${RESET}" ; sleep 2 ; LOADER2 ; PORT_NO="110" ; NMAP_RUN ; exit 0 ;;
        "LOTUS")
            echo && echo -e "${YELLOW}Scan started for: $opt${RESET}" ; sleep 2 ; LOADER2 ; PORT_NO="1352" ; NMAP_RUN ; exit 0 ;;
        "DNS")
            echo && echo -e "${YELLOW}Scan started for: $opt${RESET}" ; sleep 2 ; LOADER2 ; PORT_NO="53" ; NMAP_RUN ; exit 0 ;;
        "NTP")
            echo && echo -e "${YELLOW}Scan started for: $opt${RESET}" ; sleep 2 ; LOADER2 ; PORT_NO="123" ; NMAP_RUN ; exit 0 ;;
        "PRINTERS")
            echo && echo -e "${YELLOW}Scan started for: $opt${RESET}" ; sleep 2 ; LOADER2 ; PORT_NO="515" ; NMAP_RUN ; exit 0 ;;
        "CUSTOM PORT")
            echo && echo -e "${YELLOW}Scan started for: $opt${RESET}" ; sleep 2 ; ASK_PORT ; LOADER2 ; NMAP_RUN ; exit 0 ;;
        "EXIT")
            clear ; break
            ;;
        *) echo "invalid option $REPLY"
                echo $PORT_NO ;;
    esac
done
}
NETWORK_SELECT
SELECTION
