#!/bin/bash -e

##############################################
# filename: auto_emon.sh
# function: Automatically collect and process
#           emon data, parse the data and 
#           generate csv files if needed.
##############################################

if [ "$#" -eq 0 ]; then
    echo "Usage: [options]"
    echo "--sleep <str>          Time (seconds) that need to wait before collecting."
    echo "--capture <str>        Time (seconds) that need to collect."
    echo "--sep_path <str>       Path where sep tool is installed."
    echo "--output <str>         The output file name, do not need a file extension."
    echo "--parse_data           With this flag, will parse raw data and generate csv."
    exit 3
fi

# get the input parameters
for var in "$@"; do
    case "$var" in
    --sleep=*)
        sleep_time="${var/--sleep=/}"
        ;;
    --sleep)
        sleep_time="-1"
        ;;
    --capture=*)
        capture_time="${var/--capture=/}"
        ;;
    --capture)
        capture_time="-1"
        ;;
    --sep_path=*)
        sep_path="${var/--sep_path=/}"
        ;;
    --sep_path)
        sep_path="-1"
        ;;
    --output=*)
        output="${var/--output=/}"
        ;;
    --output)
        output="-1"
        ;;
    --parse_data)
        parse_data=1
        ;;
    *)
        if [ "$sleep_time" = "-1" ]; then
            sleep_time="$var"
        elif [ "$capture_time" = "-1" ]; then
            capture_time="$var"
        elif [ "$sep_path" = "-1" ]; then
            sep_path="$var"
        elif [ "$output" = "-1" ]; then
            output="$var"
        else
            args+=("$var")
        fi
        ;;
    esac
done

sleep_time=${sleep_time:-0}
capture_time=${capture_time:-5}
sep_path=${sep_path:-"/opt/intel/sep"}
output=${output:-"test"}
parse_data=${parse_data:-0}

echo "Will capture emon data after $sleep_time seconds. Capture $capture_time seconds."

mkdir ${output}
cd ${output}

# source binaries
source ${sep_path}/sep_vars.sh

sleep $sleep_time
nohup emon -collect-edp -f emon.dat > /dev/null 2>&1 &
sleep $capture_time
emon -stop

# process emon.dat
if [ $parse_data = 1 ]; then
    emon -process-edp ${sep_path}/config/edp/edp_config.txt
fi
