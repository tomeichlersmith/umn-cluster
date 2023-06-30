# Condor Configuration

- Move `EXECUTE` to `/export/scratch/condor/execute`
  - More space for sandbox directories that jobs will run in
  - **Note** Jobs wont operate with this change unless the EXECUTE directory
    has the correct permissions (`755` a.k.a. `drwxr-xr-x`)
  - the rest of the files condor reads/writes are kept in `/var` which is large
    enough if we keep the root partition O(100GB)
- Separate roles
  - head node is _only_ the head node (condor: `use ROLE : CentralManager`)
  - Login/submit node is _only_ login/submit node (condor: `use ROLE : Submit`)
  - worker nodes are _only_ worker nodes (condor: `use ROLE : Execute`)
- Default allocation keeps 1 cpu per slot
  - leave this as is since all of our multi-threaded apps are moved to
    other clusters like MSI
- Pretend the data storage space (`/local/cms/`) is not mounted to worker nodes
  - allows condor to handle file transfer to scratch space
  - centrally managed file transfer means the system can slow down jobs 
    if the storage node is getting too many read calls (aka "throttling")
- Increase job throttling limit `FILE_TRANSFER_DISK_LOAD_THROTTLE = 5.0`
  - Default `FILE_TRANSFER_DISK_LOAD_THROTTLE` is `2.0` which is pretty conservative,
    we tried a value of `10.0` but that seemed to cause the submit node to lose
    connection with the NFS host so we settled on the moderate value of `5.0`.
- Set `JOB_START_DELAY` to `5`
  - This makes sure no two jobs start within 5s of each other. This staggering
    is helpful to avoid overwhelming the shared data storage location.

