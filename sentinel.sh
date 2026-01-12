#!/bin/bash
# Sentinel - Lightweight Log-based IDS
# By ne0mesys | 2026

set -o pipefail

# ─────────────────────────────
# Colors
# ─────────────────────────────
green="\e[0;32m\033[1m"
red="\e[0;31m\033[1m"
blue="\e[0;34m\033[1m"
yellow="\e[0;33m\033[1m"
purple="\e[0;35m\033[1m"
gray="\e[0;37m\033[1m"
end="\033[0m\e[0m"

# ─────────────────────────────
# Root checker
# ─────────────────────────────
checkRoot() {
  if [[ "$EUID" -ne 0 ]]; then
    echo -e "\n${red}[!] Run this script as root!${end}\n"
    exit 1
  fi
}
checkRoot

# ─────────────────────────────
# Globals
# ─────────────────────────────
IP=$(hostname -I | awk '{print $1}')

APACHE="/var/log/apache2"
NGINX="/var/log/nginx"
SSH="/var/log/auth.log"
FTP="/var/log/vsftpd.log"
SAMBA="/var/log/samba"

MODE=""
SERVICE=""

# ─────────────────────────────
# Help
# ─────────────────────────────
helpPanel() {
  echo -e "\n${yellow}[+]${end}${gray} Usage:${end}${yellow} ./sentinel.sh${end}${blue} -s|d <service>${end}\n"
  echo -e "\t${blue} -a${end}${gray}) Scans all services.${end}"
  echo -e "\t${blue} -s${end}${gray}) Scans a specific service.${end}"
  echo -e "\t${blue} -d${end}${gray}) Delete a specific .log file.${end}"
  echo -e "\t${blue} -o${end}${gray}) Shows available services.${end}\n"
  echo -e "\n${green}[+] By ne0mesys${end}\n"
}

# ─────────────────────────────
# Apache
# ─────────────────────────────
apache() {
  echo -e "\n${blue}[+] Apache Service [+]${end}"

  [[ ! -d "$APACHE" ]] && echo -e "${green}[✓] Apache is not installed${end}" && return

  if [ -z "$APACHE/access.log.*" ]; then 

    logs=$(cat "$APACHE"/access.log* 2>/dev/null | grep -i nmap | grep -v "$IP" | sort -u)
    ips=$(echo "$logs" | awk '{print $1}' | sort -u)

    [[ -z "$ips" ]] && echo -e "${green}[✓] No attacks detected${end}" && return

    echo "$ips" | nl -w2 -s'. ' | while read n ip; do
      echo -e "${red}[+] Attacker $n:${end} ${red}$ip${end}"
    done
  else 
    echo -e "${green}[✓] No attacks detected${end}"
  fi 
}

# ─────────────────────────────
# SSH
# ─────────────────────────────
ssh_scan() {
  echo -e "\n${blue}[+] SSH Service [+]${end}"

  output=$(journalctl -u ssh --no-pager 2>/dev/null | grep -v "$IP")
  [[ -z "$output" ]] && echo -e "${green}[✓] No SSH activity${end}" && return

  ips=$(echo "$output" | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' | sort -u)
  [[ -z "$ips" ]] && echo -e "${green}[✓] No attackers detected${end}" && return

  echo "$ips" | nl -w2 -s'. ' | while read n ip; do
    user=$(echo "$output" | grep "$ip" | grep -oP 'user \K\S+' | head -1)
    [[ -z "$user" ]] && user="Unknown"
    echo -e "${red}[+] Attacker $n:${end} ${red}$ip${end} (${gray}user: $user${end})"
  done
}

# ─────────────────────────────
# Nginx
# ─────────────────────────────
nginx_scan() {
  echo -e "\n${blue}[+] Nginx Service [+]${end}"

  [[ ! -d "$NGINX" ]] && echo -e "${green}[✓] Nginx is not installed${end}" && return

  logs=$(cat "$NGINX"/access.log* 2>/dev/null | grep -i nmap | grep -v "$IP")
  ips=$(echo "$logs" | awk '{print $1}' | sort -u)

  [[ -z "$ips" ]] && echo -e "${green}[✓] No attacks detected${end}" && return

  echo "$ips" | nl -w2 -s'. ' | while read n ip; do
    echo -e "${red}[+] Attacker $n:${end} ${red}$ip${end}"
  done
}

# ─────────────────────────────
# FTP
# ─────────────────────────────
ftp_scan() {
  echo -e "\n${blue}[+] FTP Service [+]${end}"

  [[ ! -f "$FTP" ]] && echo -e "${green}[✓] FTP is not installed${end}" && return

  ips=$(grep "Client" "$FTP"* 2>/dev/null | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' | grep -v "$IP" | sort -u)
  [[ -z "$ips" ]] && echo -e "${green}[✓] No attacks detected${end}" && return

  echo "$ips" | nl -w2 -s'. ' | while read n ip; do
    echo -e "${red}[+] Attacker $n:${end} ${red}$ip${end}"
  done
}

# ─────────────────────────────
# Samba
# ─────────────────────────────
samba_scan() {
  echo -e "\n${blue}[+] Samba Service [+]${end}"

  [[ ! -d "$SAMBA" ]] && echo -e "${green}[✓] Samba is not installed${end}" && return

  found=0

  if [ -z "$SAMBA/log.*" ]; then 
    for log in "$SAMBA"/log.*; do
      ip=$(basename "$log" | sed 's/log\.//')
      [[ "$ip" == "$IP" ]] && continue

      if grep -qi "authentication failure\|bad password" "$log"; then
        found=1
        echo -e "${red}[+] Attacker:${end} ${red}$ip${end}"
      fi
    done
  else 
    [[ "$found" -eq 0 ]] && echo -e "${green}[✓] No attacks detected${end}"
  fi 
}

# ─────────────────────────────
# Clean logs
# ─────────────────────────────
clean_logs() {
  echo -ne "${yellow}[+]${end} Clean ${SERVICE} logs? (yes/no): "
  read ans
  [[ "$ans" != "yes" && "$ans" != "y" ]] && exit

  case "$SERVICE" in
    ftp) truncate -s 0 "$FTP"* ;;
    apache) truncate -s 0 "$APACHE"/access.log* ;;
    nginx) truncate -s 0 "$NGINX"/access.log* ;;
    ssh) truncate -s 0 "$SSH" ;;
    samba) truncate -s 0 "$SAMBA"/log.* ;;
    *) echo -e "${red}[!] Invalid service${end}" ;;
  esac

  echo -e "${green}[✓] Logs cleaned${end}"
}

# ─────────────────────────────
# Arguments
# ─────────────────────────────
while getopts "as:d:oh" opt; do
  case "$opt" in
    a) MODE="all" ;;
    s) MODE="single"; SERVICE="$OPTARG" ;;
    d) MODE="clean"; SERVICE="$OPTARG" ;;
    o) MODE="list" ;;
    h) helpPanel; exit ;;
  esac
done

# ─────────────────────────────
# Execution
# ─────────────────────────────
case "$MODE" in
  all) apache; ssh_scan; nginx_scan; ftp_scan; samba_scan ;;
  single)
    case "$SERVICE" in
      apache) apache ;;
      ssh) ssh_scan ;;
      nginx) nginx_scan ;;
      ftp) ftp_scan ;;
      samba) samba_scan ;;
      *) echo -e "${red}[!] Unknown service${end}" ;;
    esac ;;
  clean) clean_logs ;;
  list)
    echo -e "\n${yellow}[+]${end}${gray} Services:${end}\n"
    echo -e "\t ${yellow}ftp${end}${gray} |${end}${yellow} ssh${end}${gray} |${end}${yellow} apache${end}${gray} |${end}${yellow} nginx${end}${gray} |${end}${yellow} samba${end}\n" ;;
  *) helpPanel ;;
esac

