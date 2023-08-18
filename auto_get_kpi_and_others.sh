#!/bin/bash -e

loop_dirs=(
0817-162214-logs-static_WordPress-IODLR_wp5.6_php8.0.18_optnojit_https-cryptomb_1n/
0817-164909-logs-static_WordPress-IODLR_wp5.6_php8.0.18_optnojit_https-cryptomb_1n/
0817-171438-logs-static_WordPress-IODLR_wp5.6_php8.0.18_optnojit_https-cryptomb_1n/
0817-174152-logs-static_WordPress-IODLR_wp5.6_php8.0.18_optnojit_https-cryptomb_1n/
0817-180324-logs-static_WordPress-IODLR_wp5.6_php8.0.18_optnojit_https-cryptomb_1n/
0817-182504-logs-static_WordPress-IODLR_wp5.6_php8.0.18_optnojit_https-cryptomb_1n/
0817-184609-logs-static_WordPress-IODLR_wp5.6_php8.0.18_optjit_https_1n/
0817-190554-logs-static_WordPress-IODLR_wp5.6_php8.0.18_optjit_https_1n/
0817-192604-logs-static_WordPress-IODLR_wp5.6_php8.0.18_optjit_https_1n/
0817-194638-logs-static_WordPress-IODLR_wp5.6_php8.0.18_optjit_https_1n/
0817-200711-logs-static_WordPress-IODLR_wp5.6_php8.0.18_optjit_https_1n/
0817-202809-logs-static_WordPress-IODLR_wp5.6_php8.0.18_optjit_https_1n/
0817-204848-logs-static_WordPress-IODLR_wp5.6_php8.0.18_optjit_https-cryptomb_1n/
0817-211000-logs-static_WordPress-IODLR_wp5.6_php8.0.18_optjit_https-cryptomb_1n/
0817-213101-logs-static_WordPress-IODLR_wp5.6_php8.0.18_optjit_https-cryptomb_1n/
0817-215216-logs-static_WordPress-IODLR_wp5.6_php8.0.18_optjit_https-cryptomb_1n/
0817-221335-logs-static_WordPress-IODLR_wp5.6_php8.0.18_optjit_https-cryptomb_1n/
0817-223546-logs-static_WordPress-IODLR_wp5.6_php8.0.18_optjit_https-cryptomb_1n/
)

cpu_lists=(
0-7,96-103
0-15,96-111
0-23,96-119
0-31,96-127
0-39,96-135
0-47,96-143
0-7,96-103
0-15,96-111
0-23,96-119
0-31,96-127
0-39,96-135
0-47,96-143
0-7,96-103
0-15,96-111
0-23,96-119
0-31,96-127
0-39,96-135
0-47,96-143
)

result_file="result_ww33_4.txt"

function get_kpi_from_loop_dir {
        echo "scaling_case,run1,run2,run3,run4,run5," >> $result_file
        for loop_dir in "${loop_dirs[@]}"; do
                printf "%s," "${loop_dir}" >> ${result_file}
                for i in {1..5}; do
                        tps=$(grep TPS "${loop_dir}/itr-${i}/logs/performance.log" | grep -oE '[0-9.]+')
                        printf "%s," "${tps}" >> ${result_file}
                done
                printf "\n" >> ${result_file}
        done
}

function get_dashboard_urls {
        for loop_dir in "${loop_dirs[@]}"; do
                printf "%s," "${loop_dir}" >> ${result_file}
                dashboard_url=$(grep "WSF Portal URL" "${loop_dir}/publish.logs" | grep  -o 'https://[^[:space:]]*')
                printf "%s,\n" "${dashboard_url}" >> ${result_file}
        done
}

function get_sar_related {
		for ((i=0; i < ${#loop_dirs[@]}; i++)); do
				./get_cpu_util_and_frequency_from_sar.sh ${cpu_lists[i]} "${loop_dirs[i]}worker-0-1-sar/sar.logs.txt"
		done
}

get_kpi_from_loop_dir
get_dashboard_urls
get_sar_related