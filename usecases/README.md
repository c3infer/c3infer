# Use Cases
We provide an automated system to reproduce each usecase descripbed in the paper. 

## Reproducing Use Cases
For running each use case, you simply need to run the particular script:
```
 \mnt\out\bin\usecase[number]_Auto.sh 
 ```

Each automated script spans multiple *realms* required for the given use case. These realms can be accessed through dedicated `tmux` consoles. For each realm, a specific script is automatically executed after boot, so no manual interaction is required beyond monitoring the logs within each realm.

All realm-specific scripts are available at [here](https://gitlab.doc.ic.ac.uk/c3infer/overlay/-/tree/master/realm_overlays?ref_type=heads) and follow a consistent naming convention. For example, **Realm B** in **Use Case 2** executes the script `usecase2_realm_B_Auto.sh`

 ## Customized Run of Use Cases
If you prefer to run customized experiments, you can execute the standard scripts that create multiple realms with shared memory configured between them, without automatically running a default script in each realm:
 ```
 \mnt\out\bin\usecase[number].sh 
 ```

