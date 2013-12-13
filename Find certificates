#!/bin/bash/
PASSWORD="--storepass <password>"
#KEYSTORE="cacerts"
THRESHOLD_IN_DAYS="30"
KEYTOOL="keytool"

KEYSTORE=$(find / -name cacerts)
#KEYSTORE=$(find / -name *.jks)

for i in $KEYSTORE
do
        CURRENT=`date +%s`
        THRESHOLD=$(($CURRENT + ($THRESHOLD_IN_DAYS*24*60*60)))
        if [ $THRESHOLD -le $CURRENT ]; then
                echo "[ERROR] Invalid date."
                exit 1
        fi
        echo "Looking for certificates inside the keystore $i expiring in $THRESHOLD_IN_DAYS day(s)..."

        $KEYTOOL -list -v -keystore "$i"  $PASSWORD 2>&1 > /dev/null
        #if [ $? -gt 0 ]; then echo "Error opening the keystore."; exit 1; fi
        if [ $? -gt 0 ]; then echo "Error opening the keystore."; fi

        $KEYTOOL -list -v -keystore "$i" $PASSWORD | grep Alias | awk '{print $3}' | while read ALIAS
        do
                #Iterate through all the certificate alias
                EXPIRACY=`$KEYTOOL -list -v -keystore "$i"  $PASSWORD -alias $ALIAS | grep Valid`
                UNTIL=`$KEYTOOL -list -v -keystore "$i"  $PASSWORD -alias $ALIAS | grep Valid | perl -ne 'if(/until: (.*?)\n/) { print "$1\n"; }'`
                UNTIL_SECONDS=`date -d "$UNTIL" +%s`
                REMAINING_DAYS=$(( ($UNTIL_SECONDS -  $(date +%s)) / 60 / 60 / 24 ))
                if [ $THRESHOLD -le $UNTIL_SECONDS ]; then
                        echo "[OK]      Certificate $ALIAS expires in '$UNTIL' ($REMAINING_DAYS day(s) remaining)."
                else
                        echo "[WARNING] Certificate $ALIAS expires in '$UNTIL' ($REMAINING_DAYS day(s) remaining)."
                        RET=1
                fi

done
done
        exit $RET
