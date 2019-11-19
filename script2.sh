########Removing all the temp files
rm -f t1 t3 t4 t5
p1=`pwd`
echo "script to detect changes to /etc/"

####To check if directory already copied, if not then copy , for first run###
if [ -d etc ]
then
	echo ""
	#diff -r /etc etc
else
	#cp -asfpr /etc/ .
	cp -fpr /etc/ .
	#diff -r /etc etc
fi 

####Find all the softlinks in etc dir#######
find -L etc -xtype l > soft.tmp

###Loop over links to find all details####
cat soft.tmp | while read line
do
	ls -lrt $line >> t1 2>&1
done

####Formating the softlinks to match the copied dir#####
##To convert /etc to etc
cat t1 | awk '{print $(NF)}' | grep  -w "^/etc" > t2
####To convert paths for mount points to absolute paths
cat t1 | awk '{print $(NF)}' | grep -Ew "../var|../usr|../boot" >> t4
######Generate output of matching lines to temp file t3#####
cat t2 | while read line
do
	grep "$line" t1 >> t3
done

#####Iterate over T3 and change softlinks from /etc to etc to match the backup path########
if [ -f t3 ]
then
cat t3 | while read line
do
	f1=`echo $line | awk '{print $(NF-2)}'`
	f2=`echo $line | awk '{print $(NF)}'`
	#f3=`echo $f2 | sed "s%/etc%etc%g"`
	#echo "$f1 $p1$f2"
	ln -sfn $p1$f2 $f1
done
fi

#####Loop over absolute paths################
if [ -f t4 ]
then
cat t4 | while read line
do
        grep "$line" t1 >> t5
done
fi

#######Removing relative paths to absolute paths######
if [ -f t5 ]
then
cat t5 | while read line
do
        f1=`echo $line | awk '{print $(NF-2)}'`
        f2=`echo $line | awk '{print $(NF)}'`
        f3=`echo $f2 | sed "s%\.\.\/%\/%g"`
        #echo "$f1 $f3"
        ln -sfn $f3 $f1
done
fi


################Finding changes#####################
if [ ! -f file_diff.report ]
then
touch file_diff.report
fi

echo "Appending changes to file_diff.report, please do not delete file_diff.report , else you would loose history of changes"
val2=`diff -r /etc etc`
if [ ! -z "$val2" ]
then
	dd=`date`
	echo "--------------" >> file_diff.report
	echo "Script ran at : $dd" >> file_diff.report
	echo "$val2" >> file_diff.report
	echo "--------------" >> file_diff.report
	echo "" >> file_diff.report
	rm -rf etc
	cp -fpr /etc/ .
fi	


##########File formatting to make a redable report#######
sed -i "s%Only in \/etc%File added in \/etc%g" file_diff.report
sed -i "s%Only in etc%File removed from\/etc%g" file_diff.report
sed -i "s/^[0-9]d/Line added at /g" file_diff.report
sed -i "s/^[0-9]c/Line changed at /g" file_diff.report
sed -i "s/^[0-9]a/Line Deleted at /g" file_diff.report

rm -f t1 t2 t3 t4 t5
