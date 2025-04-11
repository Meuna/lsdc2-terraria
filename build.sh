#!/bin/bash

script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

podman build $script_dir -t docker.io/meuna/lsdc2:terraria \
&& podman push docker.io/meuna/lsdc2:terraria