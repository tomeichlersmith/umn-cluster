# UMN HEP Computing Cluster

Partially administrated and maintained by HEP students.

## Stack

- OS
  - [Rocky Linux](https://rockylinux.org/)
    - [Installation docs](https://docs.rockylinux.org/guides/installation/)
  - **Needs driver support for hard disk controllers used in R410 computers**
    - Chad discovered that RedHat 8.5 variants _do not_ have these drivers and require a hacky workaround
    - A workaround has been found by loading the driver on boot
- Auth
  - VAS and AD using IDs from central IT
- [Filesystem](filesystem) and storage
  - ZFS for data storage
  - HDFS data evacuated to expanded ZFS+NFS area
    - Once decomissioned, allows us to set a minimum of O(2TB) for boot disks
    - No reason to go lower than O(500GB) 
  - Home directories provided by CSE-IT
  - ? Higher performance scratch disks ?
    - Separate partition/mount for system caches so that users don't prevent CVMFS/related from using necessary cache area
    - (money alert) upgrade dozen(ish) scorpions with scratch space < 10GB
    - at minimum, harvest HDFS disks so that scratch areas can be larger
- Admin Config Manager
  - Handled by CSE-IT
  - [Ansible](https://docs.ansible.com/) for ease of use https://github.com/tomeichlersmith/umn-cluster/issues/5
  - [Puppet](https://puppet.com/docs/) ruled out due to complexity
- [Squid caching](http://www.squid-cache.org/) to help limit external network access to only what is necessary ✔️
  - This is required for CMSSW (I think) and is helpful for CVMFS
  - We can also look into connecting this caching to the container runner and its storage of container images
- Workload Manager
  - [HTCondor](https://htcondor.org/)
  - Reconfigure with central job throttling
  - Define working nodes to make it easier for users to use the highest number of cores possible
- [CVMFS](https://cernvm.cern.ch/fs/) ✔️
  - CERN-related jobs, some containers are even distributed via CVMFS
  - **can we attach our own material to CVMFS?**
- Container Runner ✔️
  - [singularity](https://sylabs.io/guides/3.7/user-guide/) easy to install

## Delayed
These goals are not necessarily "removed", but will not be primary goals.
- OSG Storage Entrypoint
  - Depends on xrootd
  - Allows jobs out in OSG to read/write files here
- Setting up certificates so folks can submit crab jobs from this cluster
- Connect to LDCS?
  - [ARC Client Tools](https://www.nordugrid.org/arc/arc6/users/client_install.html)
  - Ask Florido (ARC dev and Lund sysadmin) for advice on setup
- Globus ✔️
  - Extremely useful in rare situations
  - Make sure our storage node is available to it
  - UMN has expanded its license so we are probably good
  - ID tied to internet ID

## Assembly
All nodes have the Stack detailed above.

### Head Node
- Combined duties to simplify design of cluster
- Runs the Condor Scheduler + other "god" activities

### Login/Submit Node
- ssh to it to submit jobs
- Condor client with submit privileges
- Allow login by users

### Worker Nodes
- condor client to receive jobs
- not allow un-privileged users to ssh directly to
- ? allow specific non-sudo users to connect to help debug ?

### Nodes Already Provided
- Globus
  - May need to move it to Keller off of old v-sphere host
- Squid Proxy
  - Already in Keller

## Other considerations:
- 21 6TB hard driveshave been added to whybee1's ZFS pool.
- 6 additional 6TB drives pulled from Hadoop. Need ~10 to add more to Whybee1's second jbod. Hot spares are also very good to have.
- 2nd jbod has around 24 open slots for expansion
