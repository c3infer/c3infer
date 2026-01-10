# Reproducing Use Cases
For running each use case, you first need to run the associated script:
 ```
 /mnt/out/bin/usecase[number].sh 
 ```
Each script spans multiple *realms* required for the given use case. These realms can be accessed through dedicated `tmux` consoles (e.g., realmA console). When all realms are booted and accessible through their particular console, you can start executing the scripts of each use case. For each realm and each use case, a specific script is stored within that realm that can be executed. For example, **Realm B** in **use case 2** must execute the script `/root/usecase2/realmB.sh`. The scripts must be executed in the exact order described below, and each script should be started only after the previous one has completed successfully.

## Use case 1 (video moderation):
Realm A:
```
./usecase1/realmA.sh
```
Realm B:
```
./usecase1/realmB.sh
```
Realm C:
```
./usecase1/realmC.sh
```
Realm D:
```
./usecase1/realmD.sh
```

## Use case 2 (Loop-Back LLM Inference):
Realm A:
```
./usecase2/realmA.sh
```
Realm B:
```
./usecase2/realmB.sh
```
Realm C:
```
./usecase2/realmC.sh
```
Realm A:
```
./usecase2/realmA_2.sh
```

## Use case 3 (Service VM):
Realm B:
```
./usecase3/realmB.sh
```
Realm A:
```
./usecase3/realmA.sh
```
