#!/bin/bash/
THRESHOLD_IN_DAYS="30"
KEYTOOL="keytool"
KEYSTORE=$(find / \( -name "*.jks" -o -name "cacerts" \) | grep -iv java)
for i in $KEYSTORE
do
        echo "\n" | keytool -list -v -keystore "$i" > /tmp/certi

        CURRENT=`date +%s`
        THRESHOLD=$(($CURRENT + ($THRESHOLD_IN_DAYS*24*60*60)))
        if [ $THRESHOLD -le $CURRENT ]; then
                echo "[ERROR] Invalid date."
                exit 1
        fi
        echo "Looking for certificates inside the keystore $i expiring in $THRESHOLD_IN_DAYS day(s)..."

        if [ $? -gt 0 ]; then echo "Error opening the keystore."; fi

        cat /tmp/certi | grep "Alias" | awk '{print $3}' | while read Alias
        do
                EXPIRACY=`cat /tmp/certi | grep -A20 "$Alias" | grep Valid`
                UNTIL=`cat /tmp/certi | grep -A20 "$Alias" | grep Valid | perl -ne 'if(/until: (.*?)\n/) { print "$1\n"; }'`
                UNTIL_SECONDS=`date -d "$UNTIL" +%s`
                REMAINING_DAYS=$(( ($UNTIL_SECONDS - $(date +%s)) / 60 / 60 / 24 ))
                if [ $THRESHOLD -le $UNTIL_SECONDS ]; then
                echo "[OK]      Certificate with Alias $Alias
                expires in '$UNTIL' ($REMAINING_DAYS day(s) remaining)."
                else
                echo "[WARNING]     Certificate with Alias $Alias"
                echo "         expires in '$UNTIL' ($REMAINING_DAYS day(s) remaining)."
                echo "$i with $Alias expires $UNTIL" >> /tmp/warnings
                RET=1
                fi
done
done
exit $RET
