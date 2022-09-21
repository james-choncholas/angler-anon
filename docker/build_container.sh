#!/bin/bash
scriptpath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd $scriptpath/..

sudo docker build \
    -f docker/Dockerfile \
    -t akridex:latest \
    .
