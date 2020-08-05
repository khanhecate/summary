#!/bin/bash
YELLOW='\033[1;33m'
GREN='\033[0;32m'
RED='\033[0;31m'
CLEAR='\033[0m'

if ! command -v bc &> /dev/null
then
    echo "please install bc"
    exit
fi

info_OS_name() {
hostnamectl | grep "  Operating System: " | sed "s/  Operating System: //g" | sed "s/\"//g"
}
info_cpu_percen() {
# mpstat | awk '$12 ~ /[0-9.]+/ { print 100 - $12"%" }'
raw=$(echo print `top -n 1 | tr -s " " | cut -d$" " -f10 | tail -n +8 | head -n -1 | paste -sd+ | bc`/ `nproc` | python)
echo "${raw::4} %"
}
info_cpu_total() {
getconf _NPROCESSORS_ONLN
}
info_cpu_name() {
lscpu | sed -nr '/Model name/ s/.*:\s*(.*) @ .*/\1/p'
}
info_ram_total() {
getconf -a | grep PAGES | awk 'BEGIN {total = 1} {if (NR == 1 || NR == 3) total *=$NF} END {print total / 1024" kB"}' |while read KB dummy;do echo $((KB/1024)) MB;done
}
info_ram_percen() {
# cat /proc/meminfo | grep "MemTotal:\|MemFree:" | awk '{print $2}' | awk "NR==2" | while read MemTol dummy; do echo $((MemTol-`info_ram_total`)) KB;done
# echo "not yeet"
total=$(getconf -a | grep PAGES | awk 'BEGIN {total = 1} {if (NR == 1 || NR == 3) total *=$NF} END {print total / 1024" kB"}' |while read KB dummy;do echo $((KB/1024));done)
usage=$(free | grep "Mem:" | awk '{print $3}' | while read KB dummy;do echo $((KB/1024));done)
# percent=$(awk "BEGIN { pc=100*${usage}/${total}; i=int(pc); print (pc-i<0.5)?i:i+1 }")
percentage=$(echo "${usage}*100/${total}" | bc)
echo "$percentage %"
}
info_ram_usage() {
free | grep "Mem:" | awk '{print $3}' | while read KB dummy;do echo $((KB/1024)) MB;done
}
info_uptime() {
uptime -p
}
echo -e "${RED}OS NAME  ${CLEAR}: `info_OS_name`"
echo -e "${RED}OS Uptime${CLEAR}: `info_uptime`"
echo -e "${GREN}CPU NAME ${CLEAR}: `info_cpu_name`"
echo -e "${GREN}CPU LOAD ${CLEAR}: `info_cpu_percen`"
echo -e "${GREN}CPU CORE ${CLEAR}: `info_cpu_total`"
echo -e "${YELLOW}RAM TOTAL${CLEAR}: `info_ram_total`"
echo -e "${YELLOW}RAM LOAD ${CLEAR}: `info_ram_percen`"
echo -e "${YELLOW}RAM USAGE${CLEAR}: `info_ram_usage`"
