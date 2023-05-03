#!/bin/bash
#
# Script to backup tgz of all mailbox into local folder
#

MAIL="root"
OUT=/backup
RETENTION=6

USERS=$(/opt/zimbra/bin/zmprov -l gaa)
DATA=$(date +%d%m%Y)
ERROR=0
LOG=/var/log/zimbra_backup.log
echo ${DATA} > ${LOG}
echo "" >> ${LOG}
echo $(df -h /backup) >> ${LOG}
echo "" >> ${LOG}

if [ ! -d ${OUT} ] ; then
      mkdir -p ${OUT}
fi

## Export TGZ of .eml of all mailbox
for USER in ${USERS}
do
        /opt/zimbra/bin/zmmailbox -z -m ${USER} getRestURL "//?fmt=tgz" > ${OUT}/${DATA}-${USER}.tgz
        if [ $? -eq 0 ] ; then
                echo "${USER} ... Done" >> ${LOG}
        else
                echo "${USER} ... Error" >> ${LOG}
                ERROR=1
        fi
done

## Clean older backup
/usr/bin/find ${OUT}/ -type f -mtime +${RETENTION} -exec rm -f {} \;
if [ $? -eq 0 ] ; then
        echo "Deleting older files... Done" >> ${LOG}
else
        echo "Deleting older files... Error" >> ${LOG}
        ERROR=1
fi

if [ ${ERROR} -eq 1 ] ; then
        echo "" >> ${LOG}
        echo $(df -h /backup) >> ${LOG}
        echo "Zimbra backup error" | mail -A ${LOG} -s "Zimbra backup error" ${MAIL}
fi

exit 0
