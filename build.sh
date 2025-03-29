#!/bin/bash
podman build . -t docker.io/meuna/lsdc2:terraria \
&& podman push docker.io/meuna/lsdc2:terraria