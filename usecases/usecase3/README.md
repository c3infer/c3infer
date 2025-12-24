# Use case 1 - intro to tools
In this guide there you can find a guide of the usecases without policy (in normal ivshmem - so never use protected=true in this case)

Starting a realm with a rootfs image (realm **A**):
```bash
qemu-system-aarch64\
      -M confidential-guest-support=rme0 \
      -object rme-guest,id=rme0,measurement-log=on,measurement-algorithm=sha512  \
      -nodefaults \
      -chardev stdio,mux=on,id=virtiocon0,signal=off \
      -device virtio-serial-pci \
      -device virtconsole,chardev=virtiocon0 \
      -mon chardev=virtiocon0,mode=readline \
      -kernel /mnt/out/bin/Image-guest \
      -drive if=none,file=/mnt/out-br/images/rootfs.img,format=raw,id=hd0 \
      -device virtio-blk-pci,drive=hd0 \
      -object memory-backend-file,size=64M,share=on,mem-path=/dev/shm/shm1,id=shm1 \
      -device ivshmem-plain,memdev=shm1 \
      -cpu host -M virt -enable-kvm -M gic-version=3,its=on \
      -smp 1 -m 512M -nographic \
      -append "console=hvc0 root=/dev/vda1 rw" < /dev/hvc1 >/dev/hvc1 &
```


Starting a realm with a rootfs image+network (realm **B**) - please check this it might not work but should be fine:
```bash
qemu-system-aarch64\
      -M confidential-guest-support=rme0 \
      -object rme-guest,id=rme0,measurement-log=on,measurement-algorithm=sha512  \
      -nodefaults \
      -chardev stdio,mux=on,id=virtiocon0,signal=off \
      -device virtio-serial-pci \
      -device virtconsole,chardev=virtiocon0 \
      -mon chardev=virtiocon0,mode=readline \
      -kernel /mnt/out/bin/Image-guest \
      -drive if=none,file=/mnt/out-br/images/rootfs.img,format=raw,id=hd0 \
      -device virtio-blk-pci,drive=hd0 \
      -object memory-backend-file,size=64M,share=on,mem-path=/dev/shm/shm1,id=shm1 \
      -device ivshmem-plain,memdev=shm1 \
      -device virtio-net-pci,netdev=net0,romfile= \
      -netdev user,id=net0 \
      -cpu host -M virt -enable-kvm -M gic-version=3,its=on \
      -smp 1 -m 512M -nographic \
      -append "console=hvc0 root=/dev/vda1 rw" < /dev/hvc1 >/dev/hvc1 &
```

**NOTE** once the realms boot, the ivshmem devices will appear here (numbers 03,04 may vary but they should be exact - you should be able to find them by listing the devices inside the guest anyway):
```bash
      /sys/bus/pci/devices/0000:00:03.0/resource2
      /sys/bus/pci/devices/0000:00:04.0/resource2
      ...
```

I included in the zip I gave you a utility to write into ivshmem, run it to list help:
```bash
/root/rw_ivshmem
```

Example usage to write a string into shared memory:
```bash
/root/rw_ivshmem -W test
```

Example usage to read a string from shared memory:
```bash
/root/rw_ivshmem -W 4 #reads 4 chars 
```

Example usage to write a video into shared memory:
```bash
/root/rw_ivshmem -f /sys/bus/pci/devices/0000:00:03.0/resource2 -F encoded.mp4
```

Example usage to read a video from shared memory, into out.mp4:
```bash
/root/rw_ivshmem -f /sys/bus/pci/devices/0000:00:03.0/resource2 -z $((64*1024*1024)) -D out.mp4
```

**NOTE:** rw_ivshmem is set to work for ivshmems up to 64M per shm, however this can be configure in rw_ivshmem.c, by changing these:
```bash
#define DEFAULT_SHM_SIZE   (64 * 1024 * 1024)
#define LONG_LEN           (64 * 1024 * 1024)
```

To recompile, run this:
```bash
aarch64-linux-gnu-gcc rw_ivshmem.c -o rw_ivshmem
```

# Service vm A->B (B is service)

We need a 4 realm pipelines, I will describe what each realm should do (the commands are not precise but should be similar):

**Realm A**
Shared memory: **shm1**
Workflow (this can be started by userspace with a script):
1. Puts the .mp4 into the shared memory (use raw.mp4 inside encoding):
```bash
python3 create_ptk.py > pkt.txt #I am not sure it is doing what it should..ideally the print(pkt line should just be printed to pkt.txt)
```
1. Puts the .mp4 into the shared memory (use raw.mp4 inside encoding):
```bash
/root/rw_ivshmem -f /sys/bus/pci/devices/0000:00:03.0/resource2 -F pkt.txt
```
2. Print to console something like: "Uploaded packet"

**Realm B**
Shared memory: **shm1**
Workflow (can be started by userspace):
1. Reads the file from shared memory:
```bash
/root/rw_ivshmem -f /sys/bus/pci/devices/0000:00:03.0/resource2 -z $((64*1024*1024)) -D pkt.txt
```
If input is empty, the realm should iterate step 1 (it means that A has not written anything yet).
2. Clears the memory:
```bash
/root/rw_ivshmem -f /sys/bus/pci/devices/0000:00:03.0/resource2 -W "" #I haven't tried this but it should clear the memory
```
3. Sends the packet. I haven't implemented the script but its very simple with scapy..raw_ip should be the content of pkt.txt:
**NOTE**: it sends a packet into the eth0 interface, but perhaps it had another name, check the name of it by running **ip a** or **ifconfig**.
```bash
#!/usr/bin/env python3
from scapy.all import IP, send

def main():
    # Suppose these came from "bytes(pkt)" stored somewhere:
    raw_ip = b"..."

    # Reconstruct the packet from bytes (L3)
    pkt = IP(raw_ip)

    # Send at Layer 3 (kernel will choose outgoing interface via routing)
    send(pkt, iface="eth0", verbose=1)

if __name__ == "__main__":
    main()
```

4. Prints something like: packet sent..
Then, goes back to step 1.