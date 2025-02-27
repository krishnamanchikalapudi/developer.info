#!/bin/bash
arg=${1}
DATE_TIME=`date '+%Y-%m-%d %H:%M:%S'`

prestep() {

api/v1/configuration/export
exportAll



# -z option with $1, if the first argument is NULL. Set to default
if  [[ -z "$1" ]] ; then # check for null
    echo "User action is NULL, setting to default INSTALL"
    arg='ALL'
fi

# -n string - True if the string length is non-zero.
if [[ -n $arg ]] ; then
    arg_len=${#arg}
    # uppercase the argument
    arg=$(echo ${arg} | tr [a-z] [A-Z] | xargs)
    echo "User Action: ${arg}, and arg length: ${arg_len}"
    
    if [[ "ALL" == "${arg}" ]] ; then   # EXPORT & IMPORT 
        exportAll
        sleep 5
        importAll
    elif [[ "EXPORT" == "${arg}" ]] ; then   # EXPORT 
        exportAll
    elif [[ "IMPORT" == "${arg}" ]] ; then   # IMPORT 
        aimportAll
    fi
fi

printf "\n ----------------------------------------------------------------  "

printf "\n***** [END] TS: $(date +"%Y-%m-%d %H:%M:%S") \n\n"