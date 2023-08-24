#!/bin/bash -e

set -x
wsf_dirs=(
"/home/sfdev/wsf/build/workload/WordPress-IODLR"
"/home/sfdev/wsf_icx/build/workload/WordPress-IODLR"
"/home/sfdev/wsf_multi_run/build/workload/WordPress-IODLR"
)
wsf_names=(
"wsf"
"wsf_icx"
"wsf_multi_run"
)
timestamp=$1
origin_path=$(pwd)
echo ${origin_path}
for i in {0..2}; do
	cd ${wsf_dirs[i]}
	tar czvf ${wsf_names[i]}_logs_until_${timestamp}.tar.gz *
	sleep 5
	mv ${wsf_names[i]}_logs_until_${timestamp}.tar.gz ${origin_path}
	cd ${origin_path}
done
