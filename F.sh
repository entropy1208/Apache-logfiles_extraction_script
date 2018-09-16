#!/bin/bash
declare -A statusDict

#Add all statuses (The output from awk) to an array
statusArr=($(awk '$9 !~ /200/ { print $9 }' thttpd.log ))
if [ ${#statusArr[@]} -le 1 ]
then
	echo "No entry file"
	exit 1
fi

#Loop over all statuses (Including duplicates)
for i in "${statusArr[@]}"
do
	if [ -v statusDict[$i] ]
	then
		((statusDict["$i"]++))
	else
		statusDict+=(["$i"]=1)
	fi
done

mostUsedStatus=${statusArr[0]}
for key in "${!statusDict[@]}"; do
	if [ ${statusDict["$mostUsedStatus"]} -le ${statusDict["$key"]} ]
	then
		mostUsedStatus=$key
	fi
done


#Search for all entries with the most used Status | sort the output in reverse order | limit the output
awk -v mostUsedStatus=$mostUsedStatus '$9 ~ mostUsedStatus {print mostUsedStatus " " $1}' thttpd.log|sort -r |head -n 20 #TODO Change to param from flag
