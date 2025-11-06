#!/bin/bash
arg=${1}
new_val=${2}
DATE_TIME=`date '+%Y-%m-%d %H:%M:%S'`
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
YAML_FILE="${SCRIPT_DIR}/test.yml"

update-value() {
    printf "\n ----------------------------------------------------------------  "
    printf "\n ------------ Updating current-val in test.yml ------------  "
    printf "\n ----------------------------------------------------------------  \n"
    
    # If new value is provided as argument, use it; otherwise generate timestamp-based value
    if [[ -n "$new_val" ]]; then
        VAL_TO_UPDATE="$new_val"
    else
        VAL_TO_UPDATE="val-$(date +%Y%m%d-%H%M%S)"
    fi
    
    echo "Updating current-val to: ${VAL_TO_UPDATE}"
    
    # Update the value in test.yml using sed
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS requires -i '' for sed
        sed -i '' "s/current-val:.*/current-val: ${VAL_TO_UPDATE}/" "${YAML_FILE}"
    else
        # Linux
        sed -i "s/current-val:.*/current-val: ${VAL_TO_UPDATE}/" "${YAML_FILE}"
    fi
    
    if [ $? -eq 0 ]; then
        echo "Successfully updated test.yml"
        echo "Current value in test.yml:"
        grep "current-val" "${YAML_FILE}"
    else
        echo "Error: Failed to update test.yml"
        exit 1
    fi
}

update-value

printf "\n ----------------------------------------------------------------  "
printf "\n***** [END] TS: $(date +"%Y-%m-%d %H:%M:%S") \n\n"

