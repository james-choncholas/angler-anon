const binding = require('bindings')('agmpc_singleatt_auction_napi');
const array = new Int32Array(10);

//binding.agmpc_singleatt_auction_napi(
//  ["127.0.0.1","127.0.0.1","127.0.0.1"],
//  [3000, 4000, 5000],
//  0
//);

const ips = [];
ips.push("127.0.0.1");
ips.push("127.0.0.1");
ips.push("127.0.0.1");

//const ports = new Uint32Array(3);
//ports[0] = 3000;
//ports[1] = 4000;
//ports[2] = 5000;

const ports = [];
ports.push(3000);
ports.push(4000);
ports.push(5000);

// args: ip_array, port_array, party_index, [bob_bid], [ms_for_logging]
binding.agmpc_singleatt_auction_napi(ips, ports, 0, 0, 0);
