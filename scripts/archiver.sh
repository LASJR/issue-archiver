#!/bin/bash

# Journal settings
if [ -z ${LAJ_YEAR+x} ]; then
	  echo "[ERROR]: Please set LAJ_YEAR env var"
	  export err=1
fi

if [ -z ${LAJ_ISSUE+x} ]; then
	  echo "[ERROR]: Please set LAJ_ISSUE env var"
	  export err=1
fi


# S3 storage settings
if [ -z ${S3_BUCKET+x} ]; then
	  echo "[ERROR]: Please set S3_BUCKET env var"
	  export err=1
fi

if [ -z ${S3_ACCESS_KEY+x} ]; then
	  echo "[ERROR]: Please set S3_ACCESS_KEY env var"
	  export err=1
fi

if [ -z ${S3_SECRET_KEY+x} ]; then
	  echo "[ERROR]: Please set S3_SECRET_KEY env var"
	  export err=1
fi


# SMTP settings
if [ -z ${SMTP_HOST+x} ]; then
	  echo "[ERROR]: Please set SMTP_HOST env var"
	  export err=1
fi

if [ -z ${SMTP_PORT+x} ]; then
	  echo "[ERROR]: Please set SMTP_PORT env var"
	  export err=1
fi

if [ -z ${SMTP_FROM_ADDRESS+x} ]; then
	  echo "[ERROR]: Please set SMTP_FROM_ADDRESS env var"
	  export err=1
fi

if [ -z ${SMTP_USER_ADDRESS+x} ]; then
	  echo "[ERROR]: Please set SMTP_USER_ADDRESS env var"
	  export err=1
fi

if [ -z ${SMTP_USER_PASSWORD+x} ]; then
	  echo "[ERROR]: Please set SMTP_USER_PASSWORD env var"
	  export err=1
fi

if [ -z ${SMTP_TO_ADDRESS+x} ]; then
	  echo "[ERROR]: Please set SMTP_TO_ADDRESS env var"
	  export err=1
fi

if [ -v err ]; then 
	exit 1 
fi


# S3 storage settings (optional)
if [ -z ${S3_REGION+x} ]; then
	  echo "[INFO]: S3_REGION is unset. Using default value 'ru-central1'"
	  export S3_REGION=ru-central1
fi

if [ -z ${S3_HOST+x} ]; then
	  echo "[INFO]: S3_HOST is unset. Using default value 'storage.yandexcloud.net'"
	  export S3_HOST=storage.yandexcloud.net
fi

if [ -z ${S3_HOST_BUCKET+x} ]; then
	  echo "[INFO]: S3_HOST_BUCKET is unset. Using default value '%(bucket)s.storage.yandexcloud.net'"
	  export S3_HOST_BUCKET='%(bucket)s.storage.yandexcloud.net'
fi

httrack https://labanimalsjournal.ru/ru/contents/$LAJ_YEAR/$LAJ_ISSUE -B \
	--path laj-$LAJ_YEAR-$LAJ_ISSUE \
	--depth=3 \
	--ext-depth=0 \
	--max-rate=25000 \
	--sockets=8 \
	--structure=0

zip -r laj-$LAJ_YEAR-$LAJ_ISSUE.zip laj-$LAJ_YEAR-$LAJ_ISSUE

s3cmd \
  --access_key=$S3_ACCESS_KEY \
  --secret_key=$S3_SECRET_KEY \
  --region=$S3_REGION \
  --host=$S3_HOST \
  --host-bucket=$S3_HOST_BUCKET \
  --no-check-certificate \
  put laj-$LAJ_YEAR-$LAJ_ISSUE.zip s3://$S3_BUCKET

rm laj-$LAJ_YEAR-$LAJ_ISSUE.zip 
rm -rf laj-$LAJ_YEAR-$LAJ_ISSUE

cat <<EOF > /etc/msmtprc
# Set default values for all following accounts. 
defaults
auth on
tls on
tls_trust_file /etc/ssl/certs/ca-certificates.crt

# Account
account default
host $SMTP_HOST
port $SMTP_PORT
from $SMTP_FROM_ADDRESS
user $SMTP_USER_ADDRESS
password $SMTP_USER_PASSWORD
EOF

cat <<EOF > message.txt
From: $SMTP_FROM_ADDRESS
Subject: Архив выпуска ЛЖНИ №$LAJ_ISSUE / $LAJ_YEAR для регистрации в Информрегистре создан

Загрузите архив по ссылке https://$S3_BUCKET.$S3_HOST/laj-$LAJ_YEAR-$LAJ_ISSUE.zip
(!) Архив доступен в течение месяца после получения этого письма.
EOF

cat message.txt | msmtp $SMTP_TO_ADDRESS
