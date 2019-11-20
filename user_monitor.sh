#set -x
echo "Checking file"

###Checking  if first run , if its not first run , then enter the loop############
if [ -f user.backup ]
then
########Create a backup of user file############
	mv user.backup user.backup-1
	cat /etc/passwd > user.backup

###To check if there are any changes in /etc/passwd#########
	d1=`diff user.backup user.backup-1`
	if [ ! -z "$d1" ]
	then

####Condition to create a log file##################
	if [ ! -f user_check.log ]
	then
		touch user_check.log
	fi

####Storing all the added/removed/modfied user in temp file###############
	diff user.backup user.backup-1  | egrep '>|<' | awk -F: '{print $1}' | cut -d " " -f2 > temp1
	dd=`date`
	echo "------------------------------------------------------" >> user_check.log
	echo "SCRIPT RUN TIME:$dd" >> user_check.log
#####Looping over the temp file to know if user was added or removed or modified###############
	cat temp1 | while read line
	do
		u1=`grep $line /etc/passwd`
		u1_bkp=`grep $line user.backup-1`
		if [[ ! -z "$u1" ]] && [[ ! -z "$u1_bkp" ]]
		then
			echo "user $line was modified" 
			echo "user $line was modified" >> user_check.log
		elif [[ ! -z "$u1" ]] && [[ -z "$u1_bkp" ]]
		then
			echo "user $line was added"
			echo "user $line was added" >> user_check.log
		elif [[ -z "$u1" ]] && [[ ! -z "$u1_bkp" ]]
		then
			echo "user $line was removed"
			echo "user $line was removed" >> user_check.log
		fi
	done
	echo "------------------------------------------------------" >> user_check.log
	echo "" >> user_check.log
	echo "" >> user_check.log
	echo " please refer user_check.log for details"
	else
		echo "NO changes observed"
	fi
else
	echo "seems like first run"
	echo "creating file......"
	cat /etc/passwd > user.backup
	echo "" ; echo "File set up for checking, do not delete user.backup-1 after 2nd run"
fi

rm -f temp1
echo ""
echo "END OF SCRIPT"

#############END OF SCRIPT################
