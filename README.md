# Getting Started
Initialize submodules: `git submodule update --init --recursive`

The easiest way to run AkriDEX is via docker.
In each directory (`akridex-mpc`, `akridex-operator`, and `akridex-discovery`)
run the `docker/build.sh` script to build the containers.

To run a simple resource discovery experiment with 9 resource providers and 1 customer,
run `akridex-discovery/docker/run.sh`

# Running on Host
```
npm install -g cmake-js
npm run deps
npm run libs
npm run compile
```

To change cmake flags
```
npm config set cmake_USE_RANDOM_DEVICE=OFF
npm config edit
```




# Public DHT bootstrap node setup
use chameleon install script for deps (do not need akridex-mpc)
allow port 20000 through machine firewall `sudo ufw allow 20000/udp`
to connect, ensure firwall port range is open (need 2 + 4\*(max num parties))
    if max number of parties is 10, need 42 sequential ports open

# Running the Source Code
Build bins in akridex-mpc and copy to mpcbins/

These instructions will start a Kubernetes cluster on the local machine,
start a DHT bootstrap node, start two providers advertising resources within
the cluster, then provision resources among the providers.
Both providers share the same underlying Kubernetes cluster.

Set bootstrap IP address to localhost in `env.js`.

Run:
```
k8s_start.sh
node bootstrap_dht.js
node bob_seed_dht.js 30000 dn5bpsbw 7d24eab233ed084b97ea2ae59865e6e838c0108b
node bob_seed_dht.js 31000 dn5bpsbw 7d24eab233ed084b97ea2ae59865e6e838c0108b
node alice_dht.js 32000 dn5bpsbw 7d24eab233ed084b97ea2ae59865e6e838c0108b 522b276a356bdf39013dfabea2cd43e141ecc9e8
```

# Full Benchmark
These steps will start DHT nodes, Kubernetes clusters, providers associated with those clusters, available resources within those clusters, then provision resources among them.

First set public IP addresses of nodes in `chameleon_install.sh`, `chameleon_run.sh`.

Next set bootstrapHost in `env.js` to the DHT bootstrap node (the first IP address in `chameleon_install.sh`

If using/not using geohash, configure `chameleon_run.sh` and `results/run_alice.sh`

Then run `chameleon_install.sh`, `chameleon_run.sh`.


# DHT Benchmark
These steps will start nodes in the DHT and measure lookup properties.

First set public IP addresses of nodes in `chameleon_install.sh`, `chameleon_dhtrun.sh`.

Next set bootstrapHost in `env.js` to the DHT bootstrap node (the first IP address in `chameleon_install.sh`

If using/not using geohash, configure `chameleon_dhtrun.sh`.

Then run `chameleon_install.sh`, `chameleon_dhtrun.sh`.

# Note About Port Allocation
AkriDEX needs outbound and inbound ports available on the host system(s).
When running AkriDEX with port x, the following ports are used.
```
DHT port = x
web server port = x+1
MPC starting port = x+2
MPC ending port = x+2+2*<number of participants>
```

When running multiple AkriDEX containers/processes on the same system,
ensure port numbers are spaced far enough apart.

# localhost Run Instructions
Build bins in akridex-mpc and copy to mpcbins/
Set bootstrap IP address to localhost in `env.js`.
Run:
```
k8s_start.sh
node bootstrap_dht.js
node bob_seed_dht.js 30000 dn5bpsbw 7d24eab233ed084b97ea2ae59865e6e838c0108b
node bob_seed_dht.js 31000 dn5bpsbw 7d24eab233ed084b97ea2ae59865e6e838c0108b
node alice_dht.js 32000 646e35627073627797ea2ae59865e6e838c0108b 522b276a356bdf39013dfabea2cd43e141ecc9e8
```

# Handy links
[bittorrent-dht](https://github.com/webtorrent/bittorrent-dht)
[BEP5 protocol explained](http://www.bittorrent.org/beps/bep_0005.html)

## less handy links
[bittorrent-tracker](https://github.com/webtorrent/bittorrent-tracker)
[browser-ready webtorrent](https://webtorrent.io/intro)
