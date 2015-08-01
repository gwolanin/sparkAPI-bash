#!/usr/bin/sh

KEY="<enter your key here>"
SECRET="<enter your secret here>"
APISIG=$(echo -n "${SECRET}ApiKey${KEY}" | md5sum --text)

curl -o sparkAuth.json "https://api.sparkapi.com/v1/session/" -X POST \
-H "X-SparkApi-User-Agent: PHP-API-Code-Examples/1.0" \
-H "User-Agent: Spark API curl Client/v1" \
-H "Content-Type: application/json" \
--data '{"ApiKey":"'${KEY}'","ApiSig":"'$APISIG'"}' 

