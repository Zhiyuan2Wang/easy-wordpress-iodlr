#!/bin/bash -e

function parse_numa_core() {
        IFS=',' read -ra ranges <<< "$1"
        for range in "${ranges[@]}"; do
                if [[ ${range} =~ - ]]; then
                        start=$(echo "${range}" | cut -d'-' -f1)
                        end=$(echo "${range}" | cut -d'-' -f2)
                        for ((i=start; i <= end; i++)); do
                                output+=",${i}"
                        done
                else
                        output+=",${range}"
                fi
        done
        cpu_list=${output#,}
        #echo "CPU List: ${cpu_list}"
}

function parse_sar() {
        # input: 
        # # param1: cpu_list
        # # params2: path of sar.logs.txt
        # output:
        # # CPU_Util (%): 99.58
        # # Frequency (MHz): 2395.69
        IFS=',' read -ra cpu_list <<< "$1"
        sar_file="$2"
        frequency_base_line=$(grep -n MHz "${sar_file}" | cut -d':' -f1)
        for cpu in "${cpu_list[@]}"; do
               cpu_util_line_list+=("$((cpu + 5))")
               cpu_frequency_line_list+=("$((cpu + frequency_base_line + 2))")
        done

        cpu_count=${#cpu_list[@]}

        idle_sum=0
        for cpu_util_line in "${cpu_util_line_list[@]}"; do
                single_idle=$(sed -n "${cpu_util_line}p" "${sar_file}" | awk '{ print $NF }')
                idle_sum=$(echo "${idle_sum} + ${single_idle}" | bc)
        done
        idle_average=$(echo "scale=2; ${idle_sum} / ${cpu_count}" | bc)
        cpu_util_average=$(echo "100 - ${idle_average}" | bc)
        #echo "CPU_Util (%): ${cpu_util_average}"

        frequency_sum=0
        for cpu_frequency_line in "${cpu_frequency_line_list[@]}"; do
                single_frequency=$(sed -n "${cpu_frequency_line}p" "${sar_file}" | awk '{ print $NF }')
                frequency_sum=$(echo "${frequency_sum} + ${single_frequency}" | bc)
        done
        frequency_average=$(echo "scale=2; ${frequency_sum} / ${cpu_count}" | bc)
        #echo "Frequency (MHz): ${frequency_average}"
}

function get_cpu_util_and_frequency() {
        # $1: cpu list, such as "0-4,16-18,23-34"
        # $2: path of sar.logs.txt
        parse_numa_core $1
        parse_sar ${cpu_list} $2
		echo "${sar_file},${cpu_util_average},${frequency_average}"
}

get_cpu_util_and_frequency $1 $2