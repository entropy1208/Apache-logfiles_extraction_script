#!/bin/bash

prog_name=$0
declare -A log_dict

function usage () {
    cat << EOF
Usage: ./assignment-1.sh [-n N] (-c|-2|-r|-F|-t) file
where:
     -n: Limit the number of results to N
     -c: Which IP address makes the most number of connection attempts?
     -2: Which address makes the most number of successful attempts?
     -r: What are the most common results codes and where do they come
         from?
     -F: What are the most common result codes that indicate failure (no
	 auth, not found etc) and where do they come from?
     -t: Which IP number get the most bytes sent to them?
	 file: A file name
EOF
    exit 0
}

die () {
    echo "ERROR: $*. Aborting." >&2
    exit 1
}

while getopts ":n:c2rFth" opt; do
    case $opt in
        n)
            num_results=$OPTARG
            if [[ ${OPTARG:0:1} == '-' ]]; then
                echo "Invalid value $OPTARG given to -$opt" >&2
            exit 1
            fi
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            exit 1
            ;;
        c)
            if [ -z ${flag+'c'} ];
                then flag='c';
            else
            die "-c|-2|-r|-F|-t are mutually exclusive flags!";
            fi
            ;;
        2)
            if [ -z ${flag+'2'} ];
                then flag='2';
            else
            die "-c|-2|-r|-F|-t are mutually exclusive flags!";
            fi
            ;;
        r)
                if [ -z ${flag+'r'} ];
                then flag='r';
            else
            die "-c|-2|-r|-F|-t are mutually exclusive flags!";
            fi
            ;;
        F)
            if [ -z ${flag+'F'} ];
                then flag='F';
            else
            die "-c|-2|-r|-F|-t are mutually exclusive flags!";
            fi
            ;;
        t)
            if [ -z ${flag+'t'} ];
                then flag='t';
            else
            die "-c|-2|-r|-F|-t are mutually exclusive flags!";
            fi
            ;;
        h)
            usage
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            usage
            exit 1
            ;;
        *)
            echo "Invalid option: -$OPTARG" >&2
            usage
            exit 1
            ;;
    esac
done
if ! [[ -v flag ]];
    then usage
fi
#re='^[0-9]+$'
#if ! [[ $num_results =~ $re ]] ; then
#    echo "N as an integer is not provided!"
#    usage
#fi
shift "$((OPTIND - 1))"
test $# -eq 0 && die "You must supply the file!"
test $# -gt 1 && die "Too many command-line arguments"
file_name=$1
#echo $file_name
#echo $num_results
print_entries ()
{
#    echo $flag
#    echo $file_name
#    echo $num_results
    case $flag in
        c)
            #Add all IPs (The output from awk) to an array
            ipArr=($(awk '{ print $1 }' $file_name ))
            if [ ${#ipArr[@]} -le 1 ]
            then
                #TODO change message & behaviour
                echo "No entry file"
                exit 1
            fi

            #Loop over all IPs (Including duplicates)
            for i in "${ipArr[@]}"
            do
                if [ -v log_dict[$i] ]
                then
                    ((log_dict["$i"]++))
                else
                    log_dict+=(["$i"]=1)
                fi
            done

            #Finding most requested IP
            mostReqIp=${ipArr[0]}
            for key in "${!log_dict[@]}"; do
                if [ ${log_dict["$mostReqIp"]} -le ${log_dict["$key"]} ]
                then
                    mostReqIp=$key
                fi
            done
            echo "$mostReqIp ${log_dict[$mostReqIp]}"
            exit 0
            ;;
        2)
            #Add all IPs (The output from awk) to an array
            ipArr=($(awk '$9 ~ /200/ { print $1 }' $file_name ))
            if [ ${#ipArr[@]} -le 1 ]
            then
                #TODO change message & behaviour
                echo "No entry file"
                exit 1
            fi

            #Loop over all IPs (Including duplicates)
            for i in "${ipArr[@]}"
            do
                if [ -v log_dict[$i] ]
                then
                    ((log_dict["$i"]++))
                else
                    log_dict+=(["$i"]=1)
                fi
            done

            #Find most requested IP
            mostReqIp=${ipArr[0]}
            for key in "${!log_dict[@]}"; do
                if [ ${log_dict["$mostReqIp"]} -le ${log_dict["$key"]} ]
                then
                    mostReqIp=$key
                fi
            done
            echo "$mostReqIp ${log_dict[$mostReqIp]}"
            exit 0
            ;;
        r)
            #Add all statuses (The output from awk) to an array
            statusArr=($(awk '{ print $9 }' $file_name ))
            if [ ${#statusArr[@]} -le 1 ]
            then
                echo "No entry file"
                exit 1
            fi
            
            #Loop over all statuses (Including duplicates)
            for i in "${statusArr[@]}"
            do
                if [ -v log_dict[$i] ]
                then
                    ((log_dict["$i"]++))
                else
                    log_dict+=(["$i"]=1)
                fi
            done
            
            mostUsedStatus=${statusArr[0]}
            for key in "${!log_dict[@]}"; do
                if [ ${log_dict["$mostUsedStatus"]} -le ${log_dict["$key"]} ]
                then
                    mostUsedStatus=$key
                fi
            done
            
            #Search for all entries with the most used Status | sort the output in reverse order | limit the output
            if [[ -v num_results ]]; #todo <- add "if n is set"
            then
                awk -v mostUsedStatus=$mostUsedStatus '$9 ~ mostUsedStatus {print mostUsedStatus " " $1}' $file_name |sort -r |head -n $num_results
            else
                awk -v mostUsedStatus=$mostUsedStatus '$9 ~ mostUsedStatus {print mostUsedStatus " " $1}' $file_name |sort -r
            fi
            
            exit 0
            ;;
        F)
            #Add all statuses (The output from awk) to an array
            statusArr=($(awk '$9 !~ /200/ { print $9 }' $file_name ))
            if [ ${#statusArr[@]} -le 1 ]
            then
                echo "No entry file"
                exit 1
            fi

            #Loop over all statuses (Including duplicates)
            for i in "${statusArr[@]}"
            do
                if [ -v log_dict[$i] ]
                then
                    ((log_dict["$i"]++))
                else
                    log_dict+=(["$i"]=1)
                fi
            done

            mostUsedStatus=${statusArr[0]}
            for key in "${!log_dict[@]}"; do
                if [ ${log_dict["$mostUsedStatus"]} -le ${log_dict["$key"]} ]
                then
                    mostUsedStatus=$key
                fi
            done


            #Search for all entries with the most used Status | sort the output in reverse order | limit the output
	    if [[ -v num_results ]];#todo <- add "if n is set"
	    then
            awk -v mostUsedStatus=$mostUsedStatus '$9 ~ mostUsedStatus {print mostUsedStatus " " $1}' $file_name|sort -r |head -n $num_results
	    else
	    	awk -v mostUsedStatus=$mostUsedStatus '$9 ~ mostUsedStatus {print mostUsedStatus " " $1}' $file_name|sort -r
	    fi
	    
            exit 0
            ;;
        t)
            #Add all IPs and their bytes to an array (I the first field of the array is the first ip, in the second field of the array is the bytes of the first ip)
            ipArr=($(awk '{ log_dict[$1] += $10 } END{for (key in log_dict) print key " " log_dict[key]}' $file_name))
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
            exit 0
            ;;
    esac
}
print_entries