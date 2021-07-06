while [ -z $NAT_EXTERNAL_PORT ]; do
  echo "Searching for port...";
  port=$(cat /etc/podinfo/annotations | grep "k8s/2154" | grep -oE "\"[0-9]+\"" | grep -oE "[0-9]+" | xargs);
  if [ -n "$port" ]; then
    export NAT_EXTERNAL_IP=$(wget -qO- ifconfig.me);
    export NAT_EXTERNAL_PORT=$port;
    echo "Port found! NAT_EXTERNAL_IP=$NAT_EXTERNAL_IP NAT_EXTERNAL_PORT=$NAT_EXTERNAL_PORT";
    echo "export NAT_EXTERNAL_IP=$NAT_EXTERNAL_IP" >> ~/.profile;
    echo "export NAT_EXTERNAL_PORT=$NAT_EXTERNAL_PORT" >> ~/.profile;
    break;
  fi;
  sleep 2;
done;

echo "Starting miner...";
/opt/miner/bin/miner daemon;
touch /tmp/miner-started;
sleep 60;

echo "Starting stats loop...";
v="/opt/miner/bin/miner";
dir="/var/data/stats";
mkdir -p $dir;

while [ 1 ]; do
  miner_name=$($v info name);
  if [ ! -z "$miner_name" ] && [[ "$miner_name" != *"Error"* ]]; then
    echo "Dumping stats to $dir ...";
    start_time="$(date -u +%s)";
    echo "$miner_name" > $dir/info_name;
    $v info height > $dir/info_height;
    $v info p2p_status > $dir/info_p2p_status;
    $v info in_consensus > $dir/info_in_consensus;
    $v info block_age > $dir/info_block_age;

    $v hbbft perf --format csv > $dir/hbbft_perf.csv;
    $v peer book -s --format csv > $dir/peer_book.csv;
    $v ledger validators --format csv > $dir/ledger_validators.csv;
    $v print_keys > $dir/print_keys;
    $v versions > $dir/versions;
    end_time="$(date -u +%s)";
    elapsed="$(($end_time-$start_time))";
    echo "Stats dump took $elapsed seconds";

    sleep 120;
  else
    echo "Can't dump stats. Validator hasnt started yet $miner_name";
    sleep 30;
  fi;
done &

echo "Sleeping 5s to let miner start...";
sleep 5;
echo "Tailing validator logs...";
tail -F /var/data/log/*.log;
