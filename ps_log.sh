#!/bin/bash 
MaxFileSize=204800
DaysToKeep=7
echo -e "\n Fecha:"$(date) >> ~/log/ps.log
echo -e "\n Uptime: "$(uptime) >> ~/log/ps.log
ps -e -o pcpu,pmem,args --sort=pcpu | tail >> ~/log/ps.log
#Get size in bytes** 
file_size=$(du -b ~/log/ps.log | tr -s '\t' ' ' | cut -d' ' -f1)
if [ "$file_size" -gt $MaxFileSize ];then   
    timestamp=$(date +%s)
    mv ~/log/ps.log ~/log/ps.log."$timestamp"
    gzip ~/log/ps.log."$timestamp"
    touch ~/log/ps.log
    # remove old files
    find ~/log -name "ps.log.*" -type f -mtime +$DaysToKeep -delete 
fi