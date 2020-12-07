set -ex

# shut down nodes.
for n in $(cat yb_nodes.txt);
do
  ssh -i ./ssh/cluster.pem -ostricthostkeychecking=no -p 54422 yugabyte@$n /home/yugabyte/bin/yb-server-ctl.sh tserver stop
done

for n in $(cat yb_nodes.txt | head -n 3);
do
  ssh -i ./ssh/cluster.pem -ostricthostkeychecking=no -p 54422 yugabyte@$n /home/yugabyte/bin/yb-server-ctl.sh master stop
done

# create fake zones.
i=0
ZONEID=0
BASEZONE="us-west-2b"
for n in $(cat yb_nodes.txt);
do
  ZONEID=$(( $i / 3 ))
  i=$(( $i + 1 ))
  ssh -i ./ssh/cluster.pem -ostricthostkeychecking=no -p 54422 yugabyte@$n sed -i "s/--placement_zone.*/--placement_zone=${BASEZONE}${ZONEID}/g" tserver/conf/server.conf
done

i=0
ZONEID=0
for n in $(cat yb_nodes.txt | head -n 3);
do
  ZONEID=$(( $i / 3 ))
  i=$(( $i + 1 ))
  ssh -i ./ssh/cluster.pem -ostricthostkeychecking=no -p 54422 yugabyte@$n sed -i "s/--placement_zone.*/--placement_zone=${BASEZONE}${ZONEID}/g" master/conf/server.conf
done

# start up nodes.
for n in $(cat yb_nodes.txt | head -n 3);
do
  ssh -i ./ssh/cluster.pem -ostricthostkeychecking=no -p 54422 yugabyte@$n /home/yugabyte/bin/yb-server-ctl.sh master start
done

for n in $(cat yb_nodes.txt);
do
  ssh -i ./ssh/cluster.pem -ostricthostkeychecking=no -p 54422 yugabyte@$n /home/yugabyte/bin/yb-server-ctl.sh tserver start
done

