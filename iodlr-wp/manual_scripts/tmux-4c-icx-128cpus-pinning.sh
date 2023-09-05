#!/bin/bash

# verify image name is passed as parameter
total_params=$#
if [ ${total_params} -gt 0 ]; then
  image_name=$1
else
  echo "Please specify image name..."
  exit
fi

# check to see if image exists
if [ -z "$(docker images -q ${image_name})" ]; then
  echo "ERROR: Container \"${image_name}\" does not exist"
  exit 1
fi

# backup a copy of the tmux script
cp "${0##*/}" ./tmux-script-used.sh

# pre-allocate huge pages
echo 20000 | sudo tee /proc/sys/vm/nr_hugepages
echo 3 | sudo tee /proc/sys/vm/drop_caches

tmux new-session -d -s 4c-128cpus-pinning-session-name 
tmux send-keys "sudo docker run -it --rm --privileged --ulimit memlock=-1:-1 --cpuset-cpus=\"0-7,64-71\" --cpuset-mems=\"0\" --entrypoint bash ${image_name}"
tmux split-window -h 
tmux send-keys "sudo docker run -it --rm --privileged --ulimit memlock=-1:-1 --cpuset-cpus=\"8-15,72-79\" --cpuset-mems=\"0\" --entrypoint bash ${image_name}"

tmux select-layout tiled

tmux split-window -v 
tmux send-keys "sudo docker run -it --rm --privileged --ulimit memlock=-1:-1 --cpuset-cpus=\"16-23,80-87\" --cpuset-mems=\"0\" --entrypoint bash ${image_name}"
tmux split-window -h 
tmux send-keys "sudo docker run -it --rm --privileged --ulimit memlock=-1:-1 --cpuset-cpus=\"24-31,88-95\" --cpuset-mems=\"1\" --entrypoint bash ${image_name}"

tmux select-layout tiled
tmux setw synchronize-panes
tmux attach-session -d -t 4c-128cpus-pinning-session-name
