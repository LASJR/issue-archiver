#!/bin/bash
export LAJ_YEAR=$year
export LAJ_ISSUE=$issue
nohup /app/scripts/archiver.sh > /tmp/archiver.log 2>&1 &
echo "Создание архива выпуска ЛЖНИ №$LAJ_ISSUE / $LAJ_YEAR запущено"
exit
