#setup policy
cat /root/config/usecase3/policy2.json > /dev/rsi_policy_json
/root/rw_ivshmem -f /sys/bus/pci/devices/0000:00:03.0/resource2 -p 0 -z $((1*1024*1024)) -W ""
/root/rw_ivshmem -f /sys/bus/pci/devices/0000:00:03.0/resource2 -F packet.txt
