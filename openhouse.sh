#!/usr/bin/sh

## Check if authToken.json exists
TOKENFILE=$([ -f ./sparkAuth.json ] && echo true || echo false )

## if TOKENFILE exists, check date/time
## if current date/time > 24 hours of AuthToken, regenerate it

diff () {
	printf '%s' $(( $(date -d"$TOKFDATE" +'%s') -
		        $(date -d"$CURRENT" +'%s')))
}

regen () {
	$( ./go.sh )
}

if [ "$TOKENFILE" = "true" ]
then
	TOKFDATE=`cat sparkAuth.json | ./jq '.D.Results[0].Expires' | sed s/\"//g`
	CURRENT=$(date)
	SEC=$(diff)
	if [ $SEC -lt 0 ] 
	then
		echo "AuthToken is only good for 24 hours"
		echo "Re-generating AuthToken...."
		regen
	else
		echo "AuthToken is still valid, $SEC seconds left to use"
		echo
	fi
	AUTHTOKEN=`cat sparkAuth.json | ./jq '.D.Results[0].AuthToken' | sed s/\"//g`
else
	## Regenerate
	echo "Re-generating AuthToken...."
	regen
fi

echo "Enter your KEY: \c"
read KEY
echo "Enter your SECRET: \c"
read SECRET
echo "Enter the service path.  Ex) /v1/listings"
echo -e "Enter it here: \c"
read SERVICEPATH

AUTHTOKEN=$( [ -f ./sparkAuth.json ] && cat sparkAuth.json | ./jq '.D.Results[0].AuthToken' | sed s/\"//g || ./go.sh | ./jq '.D.Results[0].AuthToken' | sed s/\"//g )
APISIG=$( echo -n "${SECRET}ApiKey${KEY}" | md5sum --text | cut -f1 -d' ' )
PREMD5="${SECRET}ApiKey${KEY}ServicePath${SERVICEPATH}AuthToken${AUTHTOKEN}"
APISIG=$(echo -n "${SECRET}ApiKey${KEY}ServicePath${SERVICEPATH}AuthToken${AUTHTOKEN}" | md5sum --text | cut -f1 -d' ')

echo " AuthToken: $AUTHTOKEN"
echo "       KEY: $KEY"
echo "    SECRET: $SECRET"
echo "PRE-ApiSig: $PREMD5"
echo "    APISIG: $APISIG"


curl "https://sparkapi.com${SERVICEPATH}?AuthToken=${AUTHTOKEN}&ApiSig=${APISIG}" \
-X GET \
-H "X-SparkApi-User-Agent: curl testing/1.0" \
-H "User-Agent: Spark API curl Client/v1" \
-H "Content-Type: application/json" | ./jq '.D'
#-H "Content-Type: application/json" #| ./jq '.D.StandardFields.City'
#--data '{"AuthToken":"'$AUTHTOKEN'","ApiSig":"'$APISIG'"}'

echo
echo
echo " AuthToken: $AUTHTOKEN"
echo "       KEY: $KEY"
echo "    SECRET: $SECRET"
echo "PRE-ApiSig: $PREMD5"
echo "    APISIG: $APISIG"
