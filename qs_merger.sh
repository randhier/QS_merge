#!/bin/bash
#
# qs_merge.sh 
#

TMPFILE=qualityscores.tmp
PARTFILE=part-00001
MODELFILE=model_liblinear
REQUIRED_FILES="$PARTFILE $MODELFILE"

#verifies that required files exist
for file in $REQUIRED_FILES
do
	if [ ! -f $file ]
	then
		echo "$file does not exist"
		exit 1
	fi
done

# remove tmp file if it exists
if [ -f $TMPFILE ]
	then
	rm $TMPFILE
fi

# Format the part file
lines=`sed 's/[{"}]//g' $PARTFILE |tr ',' '\n'|awk '{print $1"="$2}'`
# Gets each lines featurename and has then matches the has in the model file
for feature in $lines
do
	hash=`echo $feature | awk -F '=' '{print $2}'`
	featurename=`echo $feature | awk -F '=' '{print $1}'`
	# Not a fan of having the trailing white space within the grep call but sometimes the hash matches a QS score, need something better
	qs=`grep "$hash " $MODELFILE|awk '{print $2}'`
	if [ ! -z $qs ]
		then
		echo "Feature $featurename has a QS of $qs"| tee -a $TMPFILE
		else
		echo "WARN: Feature $featurename with hash $hash does not have a QS"| tee -a $TMPFILE
	fi
done