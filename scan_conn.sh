#!/bin/bash
SCRIPTNAME=`basename "$0"`
if [ "$1" = "" ] || [ "$#" -gt 1 ]
then
cat << ALERT
(!) Aborting... please run the script with an argument as a searching item e.g.
./$SCRIPTNAME firefox -----> PROCESS NAME
./$SCRIPTNAME 3123 --------> PID
./$SCRIPTNAME ESTAB -------> STATE ( ESTAB | LISTEN | UNCONN )
./$SCRIPTNAME tcp ---------> Netid ( tcp | udp )
ALERT
exit 1
else
   PROCESS=$1
fi
if ! command -v ss >> /dev/null 2>&1 || ! command -v whois >> /dev/null 2>&1
then
   echo "Firstly, there is need to install 'ss' and 'whois' on your PC"
   echo -n "Do you want to install these tools? [Y/n] "
   read answer
   case $answer in
      Y|y|Yes|yes|"")
         echo "Installing components..."
         sudo apt update -y >> /dev/null 2>&1
         sudo apt install -y ss-dev whois >> /dev/null 2>&1
         echo "Done. Now script is working..."
         sleep 1
         ;;
      *)
         echo "(!) Aborting..."
         exit
         ;;
   esac
fi
TMP=$(date +"%H%M%S".ss)
TMPPATH=/tmp/$TMP
NUM_RES="5"
search_process() {
awk '{print $6"\t"$7"\t"$1"\t"$2}' | grep "users:.*$1" | awk '{print $1}'
}
sorting() {
cut -d: -f 1 | sort | uniq -c | sort | awk '{print $2}' | tac
}
results() {
head -n $1 $TMPPATH | while read IP
do
   local res=$(whois $IP | awk -F':' '/^Organization/ {print $2}')
   [ -n "$res" ] && echo "$res" && echo "$res" >> $TMPPATH.org
   [ -z "$res" ] && echo "(!) Cannot find Organization of IP: $IP"
done
if [ -f $TMPPATH.org ]
then
   echo "_________________________________________________________"
   echo "Connections per Org: "
   cat $TMPPATH.org | sort | uniq -c
   > $TMPPATH.org
fi
}
more_results() {
echo -n "To see more results press 'l' or any other key to exit: "
read more_results
case $more_results in
   l)
      echo "###########################################################"
      NUM_RES=$(($NUM_RES+10))
      results $NUM_RES
   ;;
   *)
      exit
   ;;
esac
}
cleanup() {
rm -rf /tmp/*.ss*
}
no_results() {
LENGTH=$(cat $TMPPATH)
[ -z "$LENGTH" ] && echo "No results"
}
ss -tunap | search_process $1 | sorting > $TMPPATH
results $NUM_RES
NUM_RES_ALL=$(wc -w $TMPPATH | cut -d' ' -f1)
while [[ $NUM_RES -lt $NUM_RES_ALL ]]
do
more_results
done
no_results
cleanup
