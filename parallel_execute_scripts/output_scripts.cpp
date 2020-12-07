#include <iostream>
#include <fstream>
#include <vector>
#include <numeric>

const int total_warehouses = 15000; // 100000 for 12xl
const int num_ips_per_client = 6; // 3 for 12xl
const int client_repeat_count = 1; // 2 for 12xl

const int loader_threads_per_client = 30; // 60 for 12xl
const int num_connections_per_client = 600; // 300 for 12xl
const int delay_per_client = 120; //

using namespace std;

void ReadClientIps(vector<string>& ips) {
  ifstream clients("yb_nodes.txt");
  string line;
  int i = 0;
  while (getline(clients, line)) {
    // skipping masters.
    if (i < 3) {
      i++;
      continue;
    }
    ips.emplace_back(line);
  }
}

class IpsIterator {
 public:
  IpsIterator(const vector<string>& ips, int num_ips_per_client, int repeat_count) :
    ips_(ips),
    num_ips_per_client_(num_ips_per_client),
    repeat_count_(repeat_count),
    idx_(0),
    current_count_(0) {
  }

  string GetNext() {
    string execute_ips = "";
    int idx = idx_;
    for (int j = 0; j < num_ips_per_client_ && idx < ips_.size(); ++j) {
      if (j != 0) execute_ips += ",";
      execute_ips += ips_.at(idx++);
    }

    ++current_count_;
    if (current_count_ == repeat_count_) {
      current_count_ = 0;
      idx_ = idx;
    }

    return execute_ips;
  }

  int GetNumSplits() {
    return (ips_.size() + num_ips_per_client_ - 1) / num_ips_per_client_ * repeat_count_;
  }

 private:
  const vector<string>& ips_;
  const int num_ips_per_client_;
  const int repeat_count_;
  int idx_;
  int current_count_;
};

void OutputLoaderScripts(const vector<string>& ips) {
  IpsIterator ip_iterator(ips, num_ips_per_client, client_repeat_count);
  int load_splits = ip_iterator.GetNumSplits();
  int warehouses_per_split = total_warehouses / load_splits;

  cout << "LOAD SPLITS: " << load_splits << "\nWH per split " << warehouses_per_split << "\n";
  for (int i = 0; i < load_splits; ++i) {
    string filename = "loader" + to_string(i) + ".sh";
    ofstream load_output(filename.data());
    load_output << "~/tpcc/tpccbenchmark --load=true"
                << " --nodes=" << ip_iterator.GetNext()
                << " --total-warehouses=" << total_warehouses
                << " --warehouses=" << warehouses_per_split
                << " --start-warehouse-id=" << i * warehouses_per_split + 1
                << " --loaderthreads=" << loader_threads_per_client;
  }
}

void OutputExecuteScripts(const vector<string>& ips) {
  IpsIterator ip_iterator(ips, num_ips_per_client, client_repeat_count);
  int execute_splits = ip_iterator.GetNumSplits();
  int warehouses_per_split = total_warehouses / execute_splits;
  int initial_delay_per_client = 0;
  int warmup_time = execute_splits * delay_per_client - delay_per_client;

  for (int i = 0; i < execute_splits; ++i) {
    string filename = "execute" + to_string(i) + ".sh";
    ofstream execute_output(filename.data());

    execute_output << "~/tpcc/tpccbenchmark --execute=true"
                   << " --nodes=" << ip_iterator.GetNext()
                   << " --num-connections=" << num_connections_per_client
                   << " --total-warehouses=" << total_warehouses
                   << " --warehouses=" << warehouses_per_split
                   << " --start-warehouse-id=" << i * warehouses_per_split + 1
                   << " --warmup-time-secs=" << warmup_time
                   << " --initial-delay-secs=" << initial_delay_per_client;
    initial_delay_per_client += delay_per_client;
    warmup_time -= delay_per_client;
  }
}

int main() {
  vector<string> ips;
  ReadClientIps(ips);
  OutputLoaderScripts(ips);
  OutputExecuteScripts(ips);
}

