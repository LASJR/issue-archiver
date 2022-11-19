#!/bin/bash

if [ -z ${LAJ_YEAR+x} ]; then
	  echo "[ERROR]: Please set LAJ_YEAR env var"
	  export err=1
fi

if [ -z ${LAJ_ISSUE+x} ]; then
	  echo "[ERROR]: Please set LAJ_ISSUE env var"
	  export err=1
fi

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

if [ -v err ]; then 
	exit 1 
fi

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

httrack http://labanimalsjournal.ru/ru/contents/$LAJ_YEAR/$LAJ_ISSUE -B \
	--path laj-$LAJ_YEAR-$LAJ_ISSUE \
	--depth=3 \
	--ext-depth=0 \
	--max-rate=25000 \
	--sockets=8 \
	--structure=0 && \

zip -r laj-$LAJ_YEAR-$LAJ_ISSUE.zip laj-$LAJ_YEAR-$LAJ_ISSUE && \

s3cmd \
  --access_key=$S3_ACCESS_KEY \
  --secret_key=$S3_SECRET_KEY \
  --region=$S3_REGION \
  --host=$S3_HOST \
  --host-bucket=$S3_HOST_BUCKET \
  --no-check-certificate \
  put laj-$LAJ_YEAR-$LAJ_ISSUE.zip s3://$S3_BUCKET
