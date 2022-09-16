#include <emp-agmpc/emp-agmpc.h>
#include <optional>

struct AuctionResult {
  int WinningParty = 0;
  int WinningBid = 0;
};

std::optional<AuctionResult>
agmpc_singleatt_auction(const std::vector<IpPort> &ip_list, int party_index, int bid=0);
