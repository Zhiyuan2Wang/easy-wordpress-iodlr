#!/bin/bash -e

test_case_list=(
        "test_static_WordPress-IODLR_wp5.6_php8.0.18_optnojit_https-cryptomb_1n"
        "test_static_WordPress-IODLR_wp5.6_php8.0.18_optjit_https_1n"
        "test_static_WordPress-IODLR_wp5.6_php8.0.18_optjit_https-cryptomb_1n"
)
container_num_list=(1 2 3 4 5 6)
php_worker_num_per_container_list=(16 16 16 16 16 16)
numa_option_core_list=(
"0-7,96-103"
"0-7,96-103|8-15,104-111"
"0-7,96-103|8-15,104-111|16-23,112-119"
"0-7,96-103|8-15,104-111|16-23,112-119|24-31,120-127"
"0-7,96-103|8-15,104-111|16-23,112-119|24-31,120-127|32-39,128-135"
"0-7,96-103|8-15,104-111|16-23,112-119|24-31,120-127|32-39,128-135|40-47,136-143"
)
numa_option_mem_list=(
        "0"
        "0|0"
        "0|0|0"
        "0|0|0|0"
        "0|0|0|0|0"
        "0|0|0|0|0|0"
)
numa_pinning_list=(
        "no"
        "no"
        "no"
        "no"
        "no"
        "no"
)
for i in {0..2}; do
        for j in {0..5}; do
                ./ctest.sh --set "CONTAINER_COUNT=${container_num_list[j]}" --set "PHP_WORKER_NUM_PER_CONTAINER=${php_worker_num_per_container_list[j]}" --set "NUMA_OPTION_CORE=${numa_option_core_list[j]}" --set "NUMA_OPTION_MEM=${numa_option_mem_list[j]}" --set "NUMA_PINNING=${numa_pinning_list[j]}" -R "${test_case_list[i]}" --run 5 --loop 1 -VV
        done
done