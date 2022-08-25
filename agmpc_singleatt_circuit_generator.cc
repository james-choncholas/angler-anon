// including the plain protocol execution
#include <emp-tool/execution/plain_prot.h>

// browse the `circuits` subdirectory for different pre-written circuits.
#include <emp-tool/circuits/bit.h>
#include <emp-tool/circuits/circuit_file.h>

#include <iostream>

#include <libgen.h>         // dirname
#include <unistd.h>         // readlink
#include <linux/limits.h>   // PATH_MAX

using namespace emp;
using namespace std;

typedef struct Resource {
    Integer price;
} Resource;


int main(int argc, char** argv) {
    if (argc != 2)
        error("Usage: agmpc_circuit_generator <max num parties>\n");

    int max_num_parties = atoi (argv[1]);
    if (max_num_parties < 3)
        error("Requires at least 3 parties\n");

    char result[PATH_MAX];
    ssize_t count = readlink("/proc/self/exe", result, PATH_MAX);
    const char *path;
    if (count != -1) {
        path = dirname(result);
    } else {
        error("cant find path\n");
        return 1;
    }

    for (int num_parties = 3; num_parties <= max_num_parties; ++num_parties) {
      std::string circuitPath = string(path) + "/agmpc_singleatt_" + to_string(num_parties) + "_circuit.txt";

      emp::setup_plain_prot(true, circuitPath.c_str());

      // no public wires in agmpc, alice must supply
      Integer globalMinIndex(32, 0, ALICE);
      Integer globalMinCost(32, INT_MAX, ALICE);
      Integer secondPrice(32, INT_MAX, ALICE);
      Integer curIndex(32, 2, ALICE); // 0=none, 1=alice, 2=first bob
      Integer one(32, 1, ALICE);

      std::vector<Resource> db = {};
      for (int i=1; i < num_parties; i++) {
          Resource r = {
              Integer(32, 0, BOB) // price
          };
          db.push_back(r);
      }

      // For each available resource
      for (auto rec = db.begin(); rec != db.end(); rec++) {
          Bit isMin = rec->price < globalMinCost;
          secondPrice = secondPrice.If(isMin, globalMinCost);
          globalMinCost = globalMinCost.If(isMin, rec->price);
          globalMinIndex = globalMinIndex.If(isMin, curIndex);

          Bit isSecondMin = (!isMin) & (rec->price < secondPrice);
          secondPrice = secondPrice.If(isSecondMin, rec->price);
          curIndex = curIndex + one;
      }

      globalMinIndex.reveal<int>();
      secondPrice.reveal<int>();

      // Close the protocol execution.
      emp::finalize_plain_prot();
    }
}
