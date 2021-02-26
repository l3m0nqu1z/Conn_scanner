#!/bin/bash
TMP=$(date +"%H%M%S".netstat)
TMPPATH=/tmp/$TMP
netstat -tunapl > $TMPPATH
awk '/firefox/ {print $5}' $TMPPATH > $TMPPATH.2
cut -d: -f1 $TMPPATH.2 > $TMPPATH
sort -o $TMPPATH $TMPPATH
uniq -c $TMPPATH > $TMPPATH.2
sort -o $TMPPATH.2 $TMPPATH.2
tail -n5 $TMPPATH.2 > $TMPPATH
grep -oP '(\d+\.){3}\d+' $TMPPATH > $TMPPATH.2
while read -r IP
do
  whois $IP | \
  awk -F':' '/^Organization/ {print $2}'
done < $TMPPATH.2
rm -f $TMPPATH $TMPPATH.2
