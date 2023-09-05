#!/bin/bash -e

# container_ids needs updation manually
container_ids=(
d22d54f28d47
5d58f2823fd2
09b69df49e18
5279795de844
)
backup_path_host_machine=$(pwd)
logs_path_in_container="/opt/pkb/git/hhvm-perf"
# workspace_with_timestamp needs updation manually
workspace_with_timestamp="workspace-2023-09-05_00.22.05"

for container_id in "${container_ids[@]}"; do
	mkdir container_${container_id}
	cd container_${container_id}
	docker cp ${container_id}:${logs_path_in_container}/${workspace_with_timestamp} .
	cd ..
done
