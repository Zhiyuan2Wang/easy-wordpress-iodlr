#!/bin/bash -e

echo "get emon"
emon -collect-edp -f ./emon.dat &
sleep 10
emon -stop

# $1 sample: optjit_https_1instance_8C16T
cp ./emon.dat $1.emon.dat

sleep 5
emon -process-edp /opt/intel/sep/config/edp/edp_config.txt

sleep 5
mv summary.xlsx "$1".summary.xlsx
