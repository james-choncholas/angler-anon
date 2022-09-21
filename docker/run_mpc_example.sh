#!/bin/bash
scriptpath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

sudo docker run -it --rm \
    --name mpc \
    --net=host \
    -v $scriptpath/openssl:/akridex/openssl \
    akridex:latest \
    node src/run_local.js
