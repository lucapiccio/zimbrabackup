#!/bin/bash
#
# Script to restore mailbox from backup
#
# Author: Luca Piccinini <luca.piccinini@lpsystem.eu>

## Path of backup
OUT=/backup

if [ "$#" -eq 0 ] ;
then
   echo -e "\e[31mUsage: ./zimbrarestore.sh -m mailboxToRestore -d daysBeforeToday -o OutputMailbox\e[39m"
   exit 1
fi

while getopts d:t:a:w: option
do
  case "${option}" in
    m) MAILBOX=${OPTARG};;
    d) DAYS=${OPTARG};;
    o) USER=${OPTARG};;
    *)
        echo -e "\e[31mOption non reconnue : ${option}/${OPTARG}\e[39m"
        echo -e "\e[31mUsage: ./zimbrarestore.sh -m mailboxToRestore -d daysBeforeToday -o OutputMailbox\e[39m"
        exit 3 ;;
  esac
done

if [ ! ${DAYS} -gt 0 ] ; then
    DAYS=1
fi

DATA=$(date +%d%m%Y -d "-${DAYS} days")

if [ -f ${OUT}/${DATA}-${MAILBOX}.tgz ] ; then
    /opt/zimbra/bin/zmmailbox -z -m ${USER} postRestURL "//?fmt=tgz&resolve=reset" ${OUT}/${DATA}-${MAILBOX}.tgz
else
    echo -e "\e[31mBackup not found in ${OUT}/${DATA}-${MAILBOX}.tgz\e[39m"
fi

exit 0
