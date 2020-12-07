export MASTER_RPC_ADDRS="172.151.33.1:7100,172.151.37.200:7100,172.151.42.130:7100"

./yb-admin -master_addresses $MASTER_RPC_ADDRS set_load_balancer_enabled 0


./bin/yb-admin --master_addresses $MASTER_RPC_ADDRS modify_placement_info aws.us-west.us-west-2b0,aws.us-west.us-west-2b1,aws.us-west.us-west-2b2 3



---

# 0 for masters and item table.
# 1 for client0
# 2 for client1

./yb-admin -master_addresses $MASTER_RPC_ADDRS set_load_balancer_enabled 0







---
