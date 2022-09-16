#!/bin/bash
scriptpath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

sudo docker run -it --rm \
    --name alice \
    --net=host \
    -v $scriptpath/openssl:/akridex-discovery/openssl \
    reg.choncholas.com/research/dex/akridex:latest \
    node src/run_local.js
