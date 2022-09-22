#include <napi.h>

#include <agmpc_matcher.h>
#include <emp-agmpc/cmpc_config.h>

#include <jlog.h>

// args: ip_array, port_array, party_index (1 indexed), [bob_bid], [ms_for_logging]
static Napi::Array Method(const Napi::CallbackInfo& info) {
  Napi::Env env = info.Env();

  if (info.Length() < 3 || info.Length() > 5) {
    Napi::TypeError::New(env, "Wrong number of arguments")
        .ThrowAsJavaScriptException();
    return Napi::Array(env, NULL);
  }

  auto start = clock_start();
  std::vector<IpPort> ip_list;

  auto ips = info[0].As<Napi::Array>();
  auto ports = info[1].As<Napi::Array>();
  if (ips.Length() != ports.Length()) {
    Napi::TypeError::New(env, "IP and ports length do not match")
        .ThrowAsJavaScriptException();
    return Napi::Array(env, NULL);
  }
  int nP = ips.Length();
  ip_list.reserve(nP);
  for (auto i = 0; i < nP; i++) {
    ip_list.push_back({
          static_cast<Napi::Value>(ips[i]).ToString().Utf8Value(),
          static_cast<Napi::Value>(ports[i]).As<Napi::Number>().Int32Value()
        });
  }

  cout << "Participants:\n";
  for (int i = 0; i < nP; i++) {
    cout << '\t' << ip_list[i].Ip << ":" << ip_list[i].port << '\n';
  }

  uint32_t party_index = info[2].As<Napi::Number>().Uint32Value();
  cout << "Party Index: " << party_index << '\n';
  if (party_index > nP) {
    Napi::TypeError::New(env, "party_index out of range")
        .ThrowAsJavaScriptException();
    return Napi::Array(env, NULL);
  }

  int bid=0, msLogger=0;
  if (party_index > 1) {
    if (info.Length() <= 3) {
      Napi::TypeError::New(env, "bob needs to supply input bid")
          .ThrowAsJavaScriptException();
    return Napi::Array(env, NULL);
    } else {
      bid = info[3].As<Napi::Number>().Int32Value();
      cout << "Bid: " << bid << '\n';
    }
    if (info.Length() > 4) {
      msLogger = info[4].As<Napi::Number>().Int32Value();
      cout << "Logging ms: " << msLogger << '\n';
    }
  }

  cout << "Running agmpc_matcher...\n";
  auto res = agmpc_matcher(ip_list, party_index, bid);
  double t2 = time_from(start);
  cout << "...done\n";

  MSG("SeNtInAl,3dbar,%s,%s,%d,%d,%.0f\n", __FUNCTION__, "e2e-mpc", nP, msLogger, t2);
  cout << "Winning party: " << res->WinningParty << '\n';
  cout << "Winning bid: " << res->WinningBid << '\n';
  //return Napi::Uint32Array(res->WinningParty, res->WinningBid);
  return Napi::Array(env, NULL);
}

static Napi::Object Init(Napi::Env env, Napi::Object exports) {
  exports.Set(Napi::String::New(env, "agmpc_matcher_napi"),
              Napi::Function::New(env, Method));
  return exports;
}

NODE_API_MODULE(agmpc_matcher_napi, Init)
