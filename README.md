# Getting Started
Initialize submodules: `git submodule update --init --recursive`


# Running with Docker
```
./docker/build_container.sh
./docker/run_mpc_example.sh
./docker/run_k8s_example.sh
./docker/run_operator_example.sh
```


# Compiling on Host
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

