#!/bin/bash
scriptpath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
#set -e

NUM_PARTIES=10
PASSIVE_DHT_NUM_NODES=10

geohash=dn5bpsbw
# room hash without geohash (cpu: 200m memory: 128Mi)
pure_lookup_hash=7d24eab233ed084b97ea2ae59865e6e838c0108b
# room hash including geohash prefix
#lookup_hash=646e35627073627797ea2ae59865e6e838c0108b
alice_node_id=522b276a356bdf39013dfabea2cd43e141ecc9e8


# Kill old running tests
killcontainers() {
    echo "killing containers..."
    for party in $(seq 2 $NUM_PARTIES); do
        sudo docker stop bob${party} &>/dev/null
    done
    sudo docker stop alice &>/dev/null
    sudo docker stop bootstrap &>/dev/null
    sudo docker stop passive &>/dev/null
    echo "...done"

    echo "stopping k8s"
    $scriptpath/../k8s_stop.sh
}

killcontainers

echo "starting k8s cluster"
$scriptpath/../k8s_start.sh

echo "starting bootstrap"
sudo docker run -d --rm \
    --name bootstrap \
    --net=host \
    reg.choncholas.com/research/dex/akridex-discovery:latest \
    node bootstrap_dht.js 20000

echo "starting passive dht nodes"
sudo docker run -d --rm \
    --name passive \
    --net=host \
    reg.choncholas.com/research/dex/akridex-discovery:latest \
    node passive_dht.js 10000 ${PASSIVE_DHT_NUM_NODES}

sleep 10 # very important to let k8s generate certs

for party in $(seq 2 ${NUM_PARTIES}); do
    echo "starting bob $party"
    sudo docker run -d --rm \
        --name bob${party} \
        --net=host \
        -v $HOME/.kube:/root/.kube \
        reg.choncholas.com/research/dex/akridex-discovery:latest \
        node bob_seed_dht.js $((30000 + 100*${party})) $geohash $pure_lookup_hash
done

sleep 5

echo "starting alice"
sudo docker run -it --rm \
    --name alice \
    --net=host \
    -v $scriptpath/openssl:/akridex-discovery/openssl \
    --env TIME="SeNtInAl,3dbar,bash,walltime,$NUM_PARTIES,0,%E
SeNtInAl,3dbar,bash,kerntime,$NUM_PARTIES,0,%S
SeNtInAl,3dbar,bash,usrtime,$NUM_PARTIES,0,%U
SeNtInAl,3dbar,bash,cpu,$NUM_PARTIES,0,%P
SeNtInAl,3dbar,bash,elapsed,$NUM_PARTIES,0,%e
SeNtInAl,3dbar,bash,maxram,$NUM_PARTIES,0,%M
SeNtInAl,3dbar,bash,majpfaults,$NUM_PARTIES,0,%F
SeNtInAl,3dbar,bash,minpfaults,$NUM_PARTIES,0,%R
SeNtInAl,3dbar,bash,contextsw-invol,$NUM_PARTIES,0,%c
SeNtInAl,3dbar,bash,contextsw-vol,$NUM_PARTIES,0,%w
SeNtInAl,3dbar,bash,sockrx,$NUM_PARTIES,0,%r
SeNtInAl,3dbar,bash,socktx,$NUM_PARTIES,0,%s" \
    reg.choncholas.com/research/dex/akridex-discovery:latest \
    time node alice_dht.js 40000 $geohash $pure_lookup_hash $alice_node_id 0 $NUM_PARTIES

killcontainers
