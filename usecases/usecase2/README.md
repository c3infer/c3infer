# Use case 2 - intro to tools
In this guide there you can find a guide of the usecases without policy (in normal ivshmem - so never use protected=true in this case)

Starting a realm with 2 shared memory using ivshmem (realms **A**, **B** and **C**):
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
      -object memory-backend-file,size=64M,share=on,mem-path=/dev/shm/shm2,id=shm2 \
      -device ivshmem-plain,memdev=shm2 \
      -cpu host -M virt -enable-kvm -M gic-version=3,its=on \
      -smp 1 -m 512M -nographic \
      -append "console=hvc0 root=/dev/vda1 rw" < /dev/hvc1 >/dev/hvc1 &
```

**NOTE:** each memdev name corresponds to a shared memory region, so in this case:
```bash
      -object memory-backend-file,size=64M,share=on,mem-path=/dev/shm/shm2,id=shm2 \
      -device ivshmem-plain,memdev=shm2,protected=true \
```
all the realms booted with **shm2** will see the same memory.
So:
1. for A,B we need **shm1**
2. for B,C we need **shm2**
3. for C,D we need **shm3**
if we want different memories to be different between realms

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

# Loop: A->B->C->A

We need a 3 realm loop, I will describe what each realm should do (the commands are not precise but should be similar):

**Realm A**
Shared memory: **shm1**, **shm3**
Workflow (this can be started by userspace with a script):
1. Puts the prompt into the shared memory **shm1** (use one in your examples):
```bash
/root/rw_ivshmem -f /sys/bus/pci/devices/0000:00:03.0/resource2 -W "PROMPT"
```
2. Print to console something like: "Prompt uploaded"
3. Keeps reading the result from the second shared memory (**shm3**):
```bash
/root/rw_ivshmem -f /sys/bus/pci/devices/0000:00:04.0/resource2 -z $((64*1024*1024)) -D output.txt
```
If it read nothing, go back to step 3.

4. Clears the memory:
```bash
/root/rw_ivshmem -f /sys/bus/pci/devices/0000:00:04.0/resource2 -W "" #I haven't tried this but it should clear the memory
```
5. Prints file:
```bash
echo "Result:"
cat output.txt
```

**Realm B**
Shared memory: **shm1**, **shm2**
Workflow:
**NOTE:** this realm should run in a loop and all the steps below should be put in an init.d file.
During the loop any possible prints to console **HAVE TO BE SUPPRESSED**, so no prints to console (I will have to disable console later when I install the policies).
So, I expect the realm to boot, enter in the init.d and stay there forever.
1. Reads the file from shared memory:
```bash
/root/rw_ivshmem -f /sys/bus/pci/devices/0000:00:03.0/resource2 -z $((64*1024*1024)) -D input.mp4
```
If input is empty, the realm should iterate step 1 (it means that A has not written anything yet).
2. Clears the memory:
```bash
/root/rw_ivshmem -f /sys/bus/pci/devices/0000:00:03.0/resource2 -W "" #I haven't tried this but it should clear the memory
```
3. Runs the LLM:
```bash
./inference_realm1.sh ./gpt2-large-q8_0.gguf > ./inference.txt
```
4. Puts the prompt result into the file:
**NOTE:** this uses **shm2** (to communicate with C)
```bash
/root/rw_ivshmem -f /sys/bus/pci/devices/0000:00:04.0/resource2 -F inference.txt
```
Then, goes back to step 1.


**Realm C**
Shared memory: **shm2**, **shm3**
Workflow:
**NOTE:** this realm should run in a loop and all the steps below should be put in an init.d file.
During the loop any possible prints to console **HAVE TO BE SUPPRESSED**, so no prints to console (I will have to disable console later when I install the policies).
So, I expect the realm to boot, enter in the init.d and stay there forever.
1. Reads the file from shared memory:
```bash
/root/rw_ivshmem -f /sys/bus/pci/devices/0000:00:03.0/resource2 -z $((64*1024*1024)) -D inference.txt
```
If input is empty, the realm should iterate step 1 (it means that B has not written anything yet).

2. Clears the memory:
```bash
/root/rw_ivshmem -f /sys/bus/pci/devices/0000:00:03.0/resource2 -W "" #I haven't tried this but it should clear the memory
```
3. Runs filtering:
```bash
 ./inference_realm2.sh ./gpt2-large-q8_0.gguf ./inference.txt > ./filtered.txt
```
4. Puts the encoded .mp4 into the file:
**NOTE:** this uses **shm3** (to communicate with A)
```bash
/root/rw_ivshmem -f /sys/bus/pci/devices/0000:00:04.0/resource2 -F filtered.txt
```
Then, goes back to step 1.
