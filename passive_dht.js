const ip = require('ip');
const DHT = require('bittorrent-dht')
const randombytes = require('randombytes') // in dht
const myenv = require('./env.js')

var cmdargs = process.argv.slice(2);
if (cmdargs.length < 2 || cmdargs.length > 3) {
    console.log("Usage: " + process.argv[0] + process.argv[1] + " <start_port> <num_nodes> [nodeIdPrefix]")
    process.exit();
}

const dhtPort = cmdargs[0]
const numNodes = cmdargs[1]
const nodeIdPrefix = cmdargs.length >= 3 ? cmdargs[2] : undefined
const myHostAndPort = ip.address() + ':' + dhtPort // cant use hostname
dhts = []

function shutdown() {
    console.log("shutting down");

    setTimeout(() => {
        console.error('Could not finish in time, forcefully shutting down');
        process.exit(0);
    }, 10000)

    numDhts = dhts.length
    dhtsProcessed = 0

    dhts.forEach(dht => {
        dht.destroy(() => {
            dhtsProcessed ++
            if (dhtsProcessed == numDhts) {
                console.log('all DHTs destroyed')
                process.exit(0)
            }
        })
    })
}

process.on('SIGTERM', shutdown)
process.on('SIGINT', shutdown)

function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

async function makedhts() {
    for (var i=0; i<numNodes; i++) {

        var nodeId = randombytes(myenv.nodeIdLen)
        if (nodeIdPrefix) {
            gH = Buffer.from(nodeIdPrefix)
            nodeId = Buffer.concat([gH, nodeId.slice(gH.length)])
        }

        if (i%10 == 0) await sleep(600)
        if (i%100 == 0) await sleep(1100)
        if (i%1000 == 0) console.log(`started ${i}'th dht`)
        if (i == numNodes-1) console.log('all dhts created')

        const dht = new DHT({
            bootstrap: [ myenv.bootstrapHost+":"+myenv.bootstrapPort],
            nodeId: nodeId,
            //timeBucketOutdated: 900000, // 15min
            //maxAge: 900000, // 15min
        })
        dhts.push(dht)

        dht.listen(parseInt(dhtPort)+i, function () {
            //console.log('now listening' + this.iAsy)
            // everyone refreshes buckets after everyone's started
            setTimeout(() => {
                if (this.iAsy%1000 == 0) console.log(`refreshing ${this.iAsy}'th passive dht node`)
                this.dhtAsy.lookup(this.dhtAsy.nodeId)
            }, this.iAsy + numNodes*57) // each node gets 30ms to start and a litte smear with iAsy
        }.bind({iAsy:i, dhtAsy:dht}))

        //dht.on('peer', function (peer, infoHash, from) {
        //  console.log('found potential peer: ' + peer.host + ':' + peer.port + ' through ' + from.address + ':' + from.port)
        //})

        //dht.on('warning', function (err) { console.log(err) })

        //dht.on('announce', function (peer, infoHash) {
        //    if (peer && peer.host && peer.port) {
        //        console.log(`got announce from ${peer.host}:${peer.port}`)
        //    } else {
        //        console.log('got malformed announce')
        //    }
        //})

        //dht.on('announce_peer', function (infoHash, peer) {
        //    console.log(`got announce_peer from ${peer.host}:${peer.port}`)
        //})

        //function dhtstate () {
        //    console.log('dht nodes')
        //    const nodes = dht.toJSON().nodes
        //    console.log(nodes)
        //}
        //setInterval(dhtstate, 5*1000)

        //console.log(`looking up self ${dht.nodeId}`)
        //dht.lookup(dht.nodeId)
        //dht.lookup(dht.nodeId, function (err, numNodesWPeers) {
        //    if (err) {
        //        console.log('lookup error')
        //        console.log(err)
        //        dht.destroy()
        //        process.exit()
        //    } else {
        //        console.log('loookup returned ' + numNodesWPeers + ' nodes with peers')
        //    }
        //})
    }
}
makedhts()
