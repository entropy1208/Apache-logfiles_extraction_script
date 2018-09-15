#!/bin/bash

prog_name=$0
declare -A log_dict

function usage () {
    cat << EOF
    Usage: $progname [-n N] (-c|-2|-r|-F|-t) file
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

limit_results=false

while getopts ":n:c2rFth" opt; do
    case $opt in
        n)
	    limit_results=true
	    num_results=$OPTARG
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
	    usage
	    ;;
    esac
done
echo $flag
if ! [[ -v flag ]];
    then usage
fi
shift "$((OPTIND - 1))"
test $# -eq 0 && die "You must supply the file!"
test $# -gt 1 && die "Too many command-line arguments"
file_name=$1
echo $file_name
IP=
status_code=
num_bytes=
awk '{log_dict[$1]++} END{for (var in log_dict) {print var, log_dict[var]};}' $file_name
echo $log_dict
# $9 is for the status codes, $10 for the bytes
awk '$9 ~ /200/ {log_dict[$1]++} END{for (var in log_dict) {print var, log_dict[var]}}' $file_name
echo $log_dict
awk '{log_dict[$1] += $10 } END{for (var in log_dict) {print var, log_dict[var]}}' $file_name
echo $log_dict
awk '{if !`[[ -v log_dict[$9] ]]` then log_dict[$9] = () else log_dict[$9] = log_dict[$9]  " " $1} END{for (var in log_dict) {print var, log_dict[var]}}' $file_name
exit 1
`awk '$9 ~ !/200/ { $log_dict[$9]=(${log_dict[$9]} $1 }' file_name`
