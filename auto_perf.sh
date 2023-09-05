#!/bin/bash -e

if [ "$#" -eq 0 ]; then
    echo "Usage: [options]"
    echo "--sleep <str>              Wait to capture perf data, default is 0. Both 5 and 5s mean 5 seconds, min is also supported."
    echo "--capture <str>            Define the capture time, default is 60s, both s and min are supported."
    echo "--frequency <num>          Sampling frequency, default is 99, which means sample 99 times per second."
    echo "--cpu <str>                CPUs to be monitored, default is all core. Support N/N-M/all, where N means CPU N, N-M means CPU N-M and all means all CPUs."
    echo "--flamegraph               Generate flame graph."
    echo "--hotspot                  Generate hotspot graph."
    echo "--perfreport               Generate perf report."    
    echo "--output <str>             The output file name, do not need a file extension."
    exit 3
fi

sleep_time=0
capture_time=60
sample_frequency=99
cpu=all
flamegraph=0
hotspot=0
perfreport=0
output_file=perf

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
    --frequency=*)
        sample_frequency="${var/--frequency=/}"
        ;;
    --frequency)
        sample_frequency="-1"
        ;;
    --cpu=*)
        cpu="${var/--cpu=/}"
        ;;
    --cpu)
        cpu="-1"
        ;;
    --flamegraph)
        flamegraph=1
        ;;
    --hotspot)
        hotspot=1
        ;;
    --perfreport)
        perfreport=1
        ;;
    --output=*)
        output_file="${var/--output=/}"
        ;;
    --output)
        output_file="-1"
        ;;
    *)
        if [ "$sleep_time" = "-1" ]; then
            sleep_time="$var"
        elif [ "$capture_time" = "-1" ]; then
            capture_time="$var"
        elif [ "$sample_frequency" = "-1" ]; then
            sample_frequency="$var"
        elif [ "$cpu" = "-1" ]; then
            cpu="$var"
        elif [ "$output_file" = "-1" ]; then
            output_file="$var"
        else
            args+=("$var")
        fi
        ;;
    esac
done

if [ "$sleep_time" = "-1" ]; then
    sleep_time=0
fi
if [[ "$sleep_time" =~ "min" ]]; then
    sleep_time=${sleep_time/min/}
    sleep_time=$((60 * $sleep_time))
else
    sleep_time=${sleep_time/s/}
fi

if [ "$sample_frequency" = "-1" ]; then
    sample_frequency=99
fi
args+="-F $sample_frequency "

if [ "$cpu" = "-1" ]; then
    cpu=all
fi
if [ "$cpu" = "all" ]; then
    args+="-a -g "
else
    args+="-C $cpu -g "
fi

if [ "$output_file" = "-1" ]; then
    output_file="perf"
fi
args+="-o ${output_file}.data "

if [ "$capture_time" = "-1" ]; then
    capture_time=60
fi
if [[ "$capture_time" =~ "min" ]]; then
    capture_time=${capture_time/min/}
else
    capture_time=${capture_time/s/}
fi
args+="-- sleep $capture_time "

echo "sleep $sleep_time seconds, then run perf record"
echo "perf record args: $args"

# sleep and execute perf record
sleep $sleep_time
perf record $args 

# generate perf report
if [ $perfreport = 1 ]; then
    perf report -i ${output_file}.data -f -n --sort=dso --max-stack=0 --stdio > ${output_file}_report.txt
fi

# generate perf hotspot
if [ $hotspot = 1 ]; then
    perf report -i ${output_file}.data -f -n --no-child --max-stack=0 --stdio > ${output_file}_hotspots.txt
fi

# generate flame graph
if [ $flamegraph = 1 ]; then
    perf script -i ${output_file}.data &> perf.unfold
    ./stackcollapse-perf.pl perf.unfold &> perf.folded
    ./flamegraph.pl perf.folded &> ${output_file}.svg
fi
