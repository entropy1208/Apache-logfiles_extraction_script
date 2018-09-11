#!/bin/bash

prog_name=$0

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
flag=

while getopts ":n:c2rFth" opt; do
    case $opt in
        n)
	    limit_results=true
	    num_results=$OPTARG
	:)
	    echo "Option -$OPTARG requires an argument." >&2
	    exit 1;;
	c) 
	    [ -z ${flag+'c'} ] && die "-c|-2|-r|-F|-t are mutually exclusive flags!"
	2)  
	    [ -z ${flag+'2'} ] && die "-c|-2|-r|-F|-t are mutually exclusive flags!"
	r)
            [ -z ${flag+'r'} ] && die "-c|-2|-r|-F|-t are mutually exclusive flags" 
	F)
	    [ -z ${flag+'F'} ] && die "-c|-2|-r|-F|-t are mutually exclusive flags" 
	t)
	    [ -z ${flag+'t'} ] && die "-c|-2|-r|-F|-t are mutually exclusive flags" 
    	h)
	    usage;;
	\?)
	    echo "Invalid option: -$OPTARG" >&2
	    usage
	    exit 1;;
	*) usage;;
    esac
done
shift $((OPTIND - 1))
test $# - eq 0 && die "You must supply the file!"
test $# - eq 1 || die "Too many command-line arguments"
file_name=$1
