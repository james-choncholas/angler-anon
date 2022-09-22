module.exports = {
  //bootstrapHost: '10.52.3.148', // instance-1 internal ip set randomly by chameleon
  //bootstrapHost: 'instance-1', // set by gcp_run.sh
  //bootstrapHost: 'localhost', // for Dockerfile running local tests
  //bootstrapHost: 'akridex.com',
  bootstrapHost: process.env.DHT_BOOTSTRAP ? process.env.DHT_BOOTSTRAP : 'akridex.com',
  bootstrapPort: 20000,
  circuit_dir: 'mpcbin',
  circuit_prefix: "agmpc_singleatt",
  //circuit_prefix: "plain_singleatt",
  maxParticipants: 10,
  targetRuntime: Infinity, //us
  //targetRuntime: 600*1000, //us
  output_dir: '/tmp/',
  nodeIdLen: 20,
  //roomInfoHash: '7d24eab233ed084b97ea2ae59865e6e838c0108b', // cpu: 200m memory: 128Mi
  onlyLookup: false,
  skipProvisioning: false,
  prefixGeohash: (geohash, str) => {
      return Buffer.concat([Buffer.from(geohash), Buffer.from(str, 'hex').slice(geohash.length)])
  }
}

//// geoRoomInfoHash calculated like this
//gH = Buffer.from(myenv.geoHash)
//roomHash = Buffer.from(myenv.roomInfoHash, 'hex')
//geoRoomHash = Buffer.concat([gH, roomHash.slice(gH.length)])
//console.log(geoRoomHash.toString('hex'))
