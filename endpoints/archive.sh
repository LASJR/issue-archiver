#!/bin/bash

# Journal settings
if [ -z ${year+x} ]; then
	  echo "Укажите год в формате ...archive?year=2022"
	  export err=1
fi

if [ -z ${issue+x} ]; then
	  echo "Укажите номер выпуска в формате ...archive?issue=2"
	  export err=1
fi

if [ -z ${email+x} ]; then
	  echo "Укажите электронную почту в формате ...archive?email=mail@example.com"
	  export err=1
fi

if [ -v err ]; then 
	exit 
fi

export LAJ_YEAR=$year
export LAJ_ISSUE=$issue
export SMTP_TO_ADDRESS=$email

nohup /app/scripts/archiver.sh > /tmp/archiver.log 2>&1 &
echo "Создание архива выпуска ЛЖНИ №$LAJ_ISSUE / $LAJ_YEAR запущено"
exit
