#!/bin/bash

### Observações/Recomendações
### Modelo de gravação SYNC;
### Mudar de gravação ou colocar como váriável (set);
### O valor do count esta em 100MB;
### Timeout pode ser ajustado também;
### Recomendação de crontab (*/30 * * * * sh /tmp/teste-disco-dd.sh 2>> /tmp/resultbash.log)

DATA=$(date +%Y-%m-%d)
DD_RESULT=$(/usr/bin/timeout 5m /bin/dd if=/dev/zero of=/tmp/output_$DATA.dat bs=1024 count=1000000 conv=sync 2>&1 | /bin/grep copied)
if [ $? == 0 ];then
  /bin/logger "MONITOR - "$DD_RESULT
else
  /bin/logger "MONITOR - Timeout 5 min."
fi
rm /tmp/output_$DATA.dat -rf &
