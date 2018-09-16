#!/bin/bash
declare -A statusDict

#Add all IPs and their bytes to an array (I the first field of the array is the first ip, in the second field of the array is the bytes of the first ip)
ipArr=($(awk '{ log_dict[$1] += $10 } END{for (key in log_dict) print key " " log_dict[key]}' thttpd.log))
if [ ${#ipArr[@]} -le 1 ]
then
	#TODO change message & behavior
	echo "No entry file"
	exit 1
fi

#Searching the ip with most bytes:
ipWithMostBytes=${ipArr[0]}
mostBytes=${ipArr[1]}

i=1
while [ $i -lt ${#ipArr[@]} ]
do
	if [ $mostBytes -lt ${ipArr[$i]} ]
	then
		mostBytes=${ipArr[$i]} 
		ipWithMostBytes=${ipArr[$i-1]}
	fi
	i=$(($i+2))
done

echo "$ipWithMostBytes $mostBytes"

