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
#awk '{log_dict[$1]++} END{for (var in log_dict) {print var, log_dict[var]};}' $file_name
#echo $log_dict
# $9 is for the status codes, $10 for the bytes
#awk '$9 ~ /200/ {log_dict[$1]++} END{for (var in log_dict) {print var, log_dict[var]}}' $file_name
#echo $log_dict
#awk '{log_dict[$1] += $10 } END{for (var in log_dict) {print var, log_dict[var]}}' $file_name
#echo $log_dict
#awk '{if !`[[ -v log_dict[$9] ]]` then log_dict[$9] = () else log_dict[$9] = log_dict[$9]  " " $1} END{for (var in log_dict) {print var, log_dict[var]}}' $file_name
#`awk '$9 ~ !/200/ { $log_dict[$9]=(${log_dict[$9]} $1 }' file_name`
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

            #Set n (to 1 if non existent, otherwise to the parameter n)
            if [[ -v num_results ]]; 
            then
                n=$num_results
            else
                n=1
            fi

            #Print all IPs and their number | sort | limit to n
            for key in "${!log_dict[@]}"; do
				echo "$key ${log_dict[$key]}"
            done | sort -rn -k2 | head -n $n
			
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
			
	    #Set n (to 1 if non existent, otherwise to the parameter n)
	    if [[ -v num_results ]]; 
            then
                n=$num_results
            else
                n=1
            fi

            #Print all IPs and their number | sort | limit to n
            for key in "${!log_dict[@]}"; do
				echo "$key ${log_dict[$key]}"
            done | sort -rn -k2 | head -n $n
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
            
            #sort status codes
            sorted_status_codes=( $(
                (for key in "${!log_dict[@]}"; do
                    echo "$key ${log_dict["$key"]}"
                done) | sort -r -nk2 | awk '{print $1}'
            ))
            
            #output the result depending on -v
            if [[ -v num_results ]]; 
            then
                (for status in "${sorted_status_codes[@]}"; do
                    awk -v status=$status '$9 ~ status {print status " " $1}' $file_name |sort -r |uniq
                done)|head -n $num_results
            else
                for status in "${sorted_status_codes[@]}"; do
                    awk -v status=$status '$9 ~ status {print status " " $1}' $file_name |sort -r |uniq
                done
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

            #sort status codes
            sorted_status_codes=( $(
                (for key in "${!log_dict[@]}"; do
                    echo "$key ${log_dict["$key"]}"
                done) | sort -r -nk2 | awk '{print $1}'
            ))
            
            #output the result depending on -v
            if [[ -v num_results ]]; 
            then
                (for status in "${sorted_status_codes[@]}"; do
                    awk -v status=$status '$9 ~ status {print status " " $1}' $file_name |sort -r |uniq
                done)|head -n $num_results
            else
                for status in "${sorted_status_codes[@]}"; do
                    awk -v status=$status '$9 ~ status {print status " " $1}' $file_name |sort -r |uniq
                done
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


