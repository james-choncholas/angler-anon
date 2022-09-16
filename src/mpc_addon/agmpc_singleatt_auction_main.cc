#include <iostream>

#include <agmpc_singleatt_auction.h>
#include <jlog.h>

#include <emp-agmpc/cmpc_config.h>

#include <libgen.h>         // dirname
#include <unistd.h>         // readlink
#include <linux/limits.h>   // PATH_MAX

using namespace emp;
using namespace std;

#define APP_DEBUG 0

static const string outputDir = "/tmp/";

int main(int argc, char** argv) {
    if (argc < 4 || argc > 6) {
        error("Usage: agmpc_singleatt_auction <ipaddr filepath> <output filepath> <party index> [bob_bid] [ms_logging]\n");
    }
    std::string ipFilePath = string(argv[1]);
    std::string outputFilePath = string(argv[2]);

    auto start = clock_start();
    std::vector<IpPort> ip_list;

    std::ifstream infile(ipFilePath);
    std::vector<std::string> fileIP;
    std::vector<int> filePorts;
    int nP = 0;
    string ip, port;
    while (getline(infile,ip,':')) {
        getline(infile,port);
        ip_list.push_back({ip, atoi(port.c_str())});
        ++nP;
    }

    int party_index = atoi(argv[3]);
    if (party_index > nP) {
        cout << "party_index out of range\n";
        return 1;
    }

    if (party_index > 1 && argc <= 4) {
        cout << "bob needs to supply input bid\n";
        return 1;
    }

    int bid=0, msLogger=0;
    if (argc >= 5) {
        bid = atoi(argv[4]);
        if (argc >= 6) {
            msLogger = atoi(argv[5]);
        }
    }

    auto res = agmpc_singleatt_auction(ip_list, party_index, bid);
    double t2 = time_from(start);

    ofstream outputfs;
    outputfs.open (outputFilePath, ios::trunc | ios::out);
    outputfs << to_string(res->WinningParty) << " " << to_string(res->WinningBid) << "\n";
    outputfs.flush();
    outputfs.close();

    MSG("SeNtInAl,3dbar,%s,%s,%d,%d,%.0f\n", __FUNCTION__, "e2e-mpc", nP, msLogger, t2);
    return 0;
}
