#setup policy
cat /root/config/usecase3/policy1.json > /dev/rsi_policy_json
/root/rw_ivshmem -f /sys/bus/pci/devices/0000:00:03.0/resource2 -R $((1*1024*1024))
/root/rw_ivshmem -f /sys/bus/pci/devices/0000:00:03.0/resource2 -z $((1*1024*1024)) -D packet.txt
