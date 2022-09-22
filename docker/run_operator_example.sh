#!/bin/bash
scriptpath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# This script emulates a distributed AkriDEX deployment.
# Different actors (nodes) in the system are encapulated
# with containers.
#
# First it starts a DHT bootstrap node and adds
# passive nodes to the DHT.
#
# Then, it runs some providers who contribute resources
# to the dark pool. For the purposes of this example,
# the providers are all offering resources in the
# same Kubernetes cluster.
#
# One of these providers is running the akridex kubernetes
# operator (as in a real-world deployment)
#
# Lastly, a request queries the dark pool and allocates
# resources in the cluster.


NUM_PARTIES=10
PASSIVE_DHT_NUM_NODES=10
LOC_HASH=dn5bpsbw
# room hash without LOC_HASH (cpu: 200m memory: 128Mi)
LOOKUP_HASH=7d24eab233ed084b97ea2ae59865e6e838c0108b
# room hash including LOC_HASH prefix
#lookup_hash=646e35627073627797ea2ae59865e6e838c0108b
QUERY_NODE_ID=522b276a356bdf39013dfabea2cd43e141ecc9e8


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
    $scriptpath/../scripts/k8s_stop.sh
}

killcontainers

echo "starting k8s cluster"
$scriptpath/../scripts/k8s_start.sh

echo "starting bootstrap"
sudo docker run -d --rm \
    --name bootstrap \
    --net=host \
    akridex:latest \
    node src/bootstrap_dht.js 20000

echo "starting passive dht nodes"
sudo docker run -d --rm \
    --name passive \
    --net=host \
    akridex:latest \
    node src/passive_dht.js 10000 ${PASSIVE_DHT_NUM_NODES}

sleep 10 # let k8s generate certs

for party in $(seq 3 ${NUM_PARTIES}); do
    echo "starting bob $party"
    sudo docker run -d --rm \
        --name bob${party} \
        --net=host \
        -v $HOME/.kube:/root/.kube \
        akridex:latest \
        node src/bob_seed_dht.js $((30000 + 100*${party})) $LOC_HASH $LOOKUP_HASH
done

sleep 5 # let providers start up

echo "starting akridex kubernetes operator"
kubectl delete deployment akridex-op
kubectl apply -f $scriptpath/../kubernetes/deployment.yaml
kubectl apply -f $scriptpath/../kubernetes/rbac.yaml
kubectl apply -f $scriptpath/../kubernetes/MarketUnitCRDv1.yaml
kubectl rollout status deployment akridex-op

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
    akridex:latest \
    time node src/alice_dht.js 40000 $LOC_HASH $LOOKUP_HASH $QUERY_NODE_ID 0 $NUM_PARTIES

killcontainers
