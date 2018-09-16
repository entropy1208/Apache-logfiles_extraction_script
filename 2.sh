#!/bin/bash
declare -A ipDict

#Add all IPs (The output from awk) to an array
ipArr=($(awk '$9 ~ /200/ { print $1 }' thttpd.log ))
if [ ${#ipArr[@]} -le 1 ]
then
	#TODO change message & behaviour
	echo "No entry file"
	exit 1
fi

#Loop over all IPs (Including duplicates)
for i in "${ipArr[@]}"
do
	if [ -v ipDict[$i] ]
	then
		((ipDict["$i"]++))
	else
		ipDict+=(["$i"]=1)
	fi
done

#Find most requested IP
mostReqIp=${ipArr[0]}
for key in "${!ipDict[@]}"; do
	if [ ${ipDict["$mostReqIp"]} -le ${ipDict["$key"]} ]
	then
		mostReqIp=$key
	fi
done

echo "$mostReqIp ${ipDict[$mostReqIp]}"
