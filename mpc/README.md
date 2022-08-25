# DEV REPO NOTE
**WARNING**
This repo is for akridex-mpc-dev but but be named akridex-mpc for compatibility with hardcoded paths in scripts


# If cloning from scratch
Must apply patches to emp-tool and emp-ot

```
cd ${scriptpath}/emp-tool
git apply ../emp-tool_bandwidth_instrumentation.patch
make
sudo make install
```

```
cd ${scriptpath}/emp-ot
git apply ../emp-ot_flushfix.patch
make
sudo make install
```

Patches were created with:
```
cd emp-tool/
git diff > ../emp-tool_bandwidth_instrumentation.patch
```


# SOSP 21 notes

may have misattributed noflush to a performance improvement.
noflush alone is a slow down.
Does nothing with parsock.

Ada says need to measure in different network conditions to verify.

Parsock speeds up setup phase even though parsock clearly happens before that measurement
Why?
Ideas: 
    parsock spreads sockets across cores (and maybe even numa nodes)
        so sending the first round of io is faster.





# Building and Running EMP

Implementation of DEX's auction function.
The auction can run in 3 security models, semi-honest 2pc, publicly verifiable covert, and authenticated garbling 2pc.

Specifically for semihonest 2pc there are a few different applications.
- sh2pc\_auction is a usable application that computes an auction for resources.
- sh2pc\_auction\_benchmark is a tool to run the auction repeatedly with increasing size and performance measurements.
In this configuration, the evaluator (bob) has the single call and the generator (alice) has all the possible values.
- sh2pc\_auction\_benchmark\_dc2 is just like benchmark except the evaluator (bob) has ALL the data.
This forces an OT on every circuit input.


## Flame Graphs
1. install FlameGraph repo and point path in docker/run.sh

## sh2pc installation instructions:

1.  Install necessary dependencies
    ```bash
    > ./install.sh
    ```

1.  Build and run the sh2pc tests
    ```bash
    > ./scripts/build_all.sh
    > ./scripts/run_all.sh
    ```


## pvc installation instructions:

1. First install normal dependancies.
    ```bash
    > ./install.sh
    ```
1. Build a circuit file with circuit generator program.
    ```bash
    > mkdir build
    > cd build
    > cmake ..
    > make
    > ./bin/gen_auction
    ```

1. Install special pvc dependancies.
    ```bash
    > ./install_pvc.sh
    ```

1. Copy the circuit to PVC location
    ```bash
    > cp to pvc test dir with special name (aes or something)
    ```

1. Run the pvc test but with the new circuit
    ```bash
    > cd emp-pvc/test
    > run the test
    ```

## AG installation instructions:
Copy the following two lines into emp-agmpc/CMakeLists.txt right above the test cases

```
install(DIRECTORY emp-agmpc DESTINATION include)
install(DIRECTORY cmake/ DESTINATION cmake)
```

Run make install from that directory
