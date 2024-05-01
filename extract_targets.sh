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

# Nmap top 100 ports
common_ports=(80 23 443 21 22 25 3389 110 445 139 143 53 135 3306 8080 1723 111 995 993 5900 1025 587 8888 199 1720 465 548 113 81 6001 10000 514 5060 179 1026 2000 8443 8000 32768 554 26 1433 49152 2001 515 8008 49154 1027 5666 646 5000 5631 631 49153 8081 2049 88 79 5800 106 2121 1110 49155 6000 513 990 5357 427 49156 543 544 5101 144 7 389 8009 3128 444 9999 5009 7070 5190 3000 5432 1900 3986 13 1029 9 5051 6646 49157 1028 873 1755 2717 4899 9100 119 37)

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

# Remove all empty results
find . -type f -empty -print -delete

echo "Done"
