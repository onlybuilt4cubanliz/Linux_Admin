#lastlog -t1 | grep -E 'Nov ([ 1-9]|1[0-9]) (0[0-6])'

#######Sorting for date and day#########
curr_m=`date | cut -d " " -f2`
curr_d=`date | cut -d " " -f3`

###Last log command to find history one day ago############
###The below command will search for all login attempts between midnight and 6AM#####
lastlog -t1| grep -E "$curr_m ([ 0-9])([0-9]) (0[0-5]):([0-9])([0-9])" > $curr_d-$curr_m.log

#########Checking if a particular user tried to login###########
user_rec=`lastlog -t1 -u vagrant`
val1=`grep "$user_rec" $curr_d-$curr_m.log`

###Checking if user record exist##########
if [ ! -z "$val1" ]
then
#echo "val is not null"
echo ""
else
echo "$val1" >> $curr_d-$curr_m.log
fi

####Extracting size of log####
log_size=`cksum $curr_d-$curr_m.log`
log_size1=`echo $log_size | cut -d " " -f1`

####Condition to send an alert
if [ -f size.pid ]
then
s1=`cksum $curr_d-$curr_m.log | cut -d " " -f1`
s2=`cat size.pid`
	if [ $s1 -ne $s2 ]
	then
		echo "Alert"
	else
		echo "No new record"
	fi
else
cksum $curr_d-$curr_m.log | cut -d " " -f1 > size.pid
fi

echo " All details will part of $curr_d-$curr_m.log, please refer file for intrusion."

echo "END OF SCRIPT"
