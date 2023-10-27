#!/bin/bash

include_hostname=false
port=""

while getopts ":hp:" opt; do
  case $opt in
    h)
      include_hostname=true
      ;;
    p)
      port="$OPTARG"
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      ;;
  esac
done

shift $((OPTIND-1))

if [ $# -lt 1 ]; then
    echo "Usage: $0 [-h] [-p port] <nmap_gnmap_file1> [<nmap_gnmap_file2> ...]"
    exit 1
fi

# Common ports: HTTP, HTTPS, SSH, FTP, Telnet, SMTP, SNMP, RDP, POP3, SMB, MSSQL, MySQL, VNC
common_ports=(80 443 22 21 23 25 161 3389 110 445 1433 3306 5900)

# If the -p option is used, only use the specified port
if [ -n "$port" ]; then
    common_ports=("$port")
fi

for gnmap_file in "$@"; do
    if [ ! -e "$gnmap_file" ]; then
        echo "File not found: $gnmap_file"
        continue
    fi
    
    for port in "${common_ports[@]}"; do
        output_file="port_${port}_open.txt"

        if [ "$include_hostname" = true ]; then
            grep "$port/open/" "$gnmap_file" | awk -F" " '{print $3}' | tr '()' | sort -u >> "$output_file"
        else
            grep "$port/open/" "$gnmap_file" | awk -F" " '{print $2}' | sort -u >> "$output_file"
        fi
    done
done
