
#####To check if its the first run########
if [[ -f hiddenfiles ]] || [[ -f excutablefiles ]]
then
###Move files to create a difference report
mv hiddenfiles "hiddenfiles-1"
mv excutablefiles "excutablefiles-1"

####Creating a list of all hidden files and excutable files###########
find / -name ".*" -exec ls -lhrt  {} \; > hiddenfiles
find /usr/bin -type f -exec ls -lhrt  {} \; > excutablefiles
find /usr/sbin -type f -exec ls -lhrt {} \; >> excutablefiles

#####removing unwanted liines#######
sed -i '/total/d' hiddenfiles
sed -i '/total/d' "hiddenfiles-1"

#####Sorting out the generated diff report in Proper format############
h_files=`diff hiddenfiles hiddenfiles-1 | egrep '^<|^>' | awk '{print "updated/removed/added by user " $4 " on date " $7 " " $8 " " $9 " on file " $10}' | sort -u -k12,12`
e_files=`diff excutablefiles excutablefiles-1 | egrep '^<|^>' | awk '{print "updated/removed/added by user " $4 " on date " $7 " " $8 " " $9 " on file " $10}' | sort -u -k12,12`

#####To check if report file exits##############
if [ ! -f hidden_excutable_monitor.report ]
then
touch hidden_excutable_monitor.report
echo "###################################################################################################" >> hidden_excutable_monitor.report
echo "PLEASE REFER THE BELOW REPORT" >> hidden_excutable_monitor.report
echo "####################################################################################################" >> hidden_excutable_monitor.report
fi


####STart writing the outputs to report file#############
if [[ ! -z "$h_files" ]] || [[ ! -z "$e_files" ]]
then
	echo "****************************" >> hidden_excutable_monitor.report
	dd=`date`
	echo "#### SCRIPT RUN AT $dd #####" >> hidden_excutable_monitor.report
	echo "$h_files" >> hidden_excutable_monitor.report
	echo "$e_files" >> hidden_excutable_monitor.report
	echo "****************************" >> hidden_excutable_monitor.report
	echo "" >> hidden_excutable_monitor.report
	echo "" >> hidden_excutable_monitor.report
fi
else
#############If its a first run of the script it will create necessary files#######
echo "Seems like first excution"
echo "Run the script one more time to start"
find / -name ".*" -exec ls -lhrt  {} \; > hiddenfiles
find /usr/bin -type f -exec ls -lhrt  {} \; > excutablefiles
find /usr/sbin -type f -exec ls -lhrt {} \; >> excutablefiles
fi


####END OF SCRIPT############
echo " Script completed "	
