# UMN HEP Computing Cluster

Administrated and maintained by HEP students.

## Stack

- OS
  - Stable, CERN has not made a public decision on future of CentOS ==> go more mainstream?
  - Ubuntu or Fedora?
  - [Rocky Linux](https://rockylinux.org/)
    - [Installation docs](https://docs.rockylinux.org/guides/installation/)
- Auth
  - VAS and AD using IDs from central IT
  - LDAP retired by central IT, would mean we'd need to handle our own auth ==> recipe for disaster
- [Filesystem](filesystem) and storage
  - ZFS for some storage and larger home directories
    - i.e. merge `/data/cmszfs1/user/$USER` and `/home/$USER` for our lab's cluster
  - [hadoop HDFS](https://hadoop.apache.org/docs/r1.2.1/hdfs_design.html)
    - Not very feasible given the age of our cluster hardware
    - need some performance research, **can a medium cluster operate effectively on more simplified storage solution?**
  - Higher performance scratch disks
    - Separate partition/mount for system caches so that users don't prevent CVMFS/related from using necessary cache area
    - (money alert) upgrade dozen(ish) scorpions with scratch space < 10GB
- Admin Config Manager
  - [Ansible](https://docs.ansible.com/) for ease of use
  - ~[Puppet](https://puppet.com/docs/)~ ruled out due to complexity
- [Squid caching](http://www.squid-cache.org/) to help limit external network access to only what is necessary
  - This is required for CMSSW (I think) and is helpful for CVMFS
  - We can also look into connecting this caching to the container runner and its storage of container images
- Workload Manager
  - [HTCondor](https://htcondor.org/)
  - [Slurm](https://slurm.schedmd.com/)
  - Decide based on ease of setup
  - Discussion with Jeremy ==> having fixed resource allocation would be easier to maintain
    - A main "feature" of HTCondor is dynamic determination of "nodes" and their availability,
      this often leads to less-than-optimum use of the cluster.
    - By default, slurm sets one node -> one job; however, it also has plugins that allow the
      cluster admins to choose how jobs are allocated resources ("consumable resources").
      For example, we can have (by default) one CPU/core per job so that one node could have `$(nproc)` jobs.
- [CVMFS](https://cernvm.cern.ch/fs/)
  - CERN-related jobs, some containers are even distributed via CVMFS
  - **can we attach our own material to CVMFS?**
- Container Runner 
  - [singularity](https://sylabs.io/guides/3.7/user-guide/) or [docker](https://docs.docker.com/engine/install/)
  - Decide based on ease of setup

## Delayed
These goals are not necessarily "removed", but will not be primary goals.
- [CMS Tier-3 Computing Cluster](https://twiki.cern.ch/twiki/bin/view/CMSPublic/USCMSTier3Doc)
  - Chad and I talked, we don't think this is feasible
  - OSG Compute Entrypoint [Request](https://opensciencegrid.org/docs/compute-element/hosted-ce/)
  - Perhaps a "Tier-3 in a box" solution?
- Connect to LDCS?
  - [ARC Client Tools](https://www.nordugrid.org/arc/arc6/users/client_install.html)
  - Ask Florido (ARC dev and Lund sysadmin) for advice on setup
- Globus
  - Would be nice for sharing data between systems

Specific Node | Description
---|---
gc1-hn | Head Node for cluster
gc1-se | Storage Element connects HDFS
gc1-ce | compute element - Condor
hdfs-nn1 | Name Node for Hadoop
hdfs-nn2 | secondary name node
whybee1 | Node hosting ZFS server (/data/cmszfs1)

### Other considerations:
- Identity Management - Versatile Authentication Service (VAS) authentication against Active Directory (AD) or local accounts.
- Storage access - For example whybee1 serves NFS based on AD accounts/groups
- Home Directories - If others outside of CSE-IT have root access to machines, we cannot use CSE home directories due to security. We will need to manage our own home directories.
- Jeremy has ~25 6TB hard drives. We could put them into a JBoD (Just a Bunch of Disks) and connect to whybee1 or use another box for a new ZFS pool.
- Old drives consistently dieing leads to consistent re-calibration of Hadoop.

### Authentication Discussion
- Verify OIT will allow CMS to join machines
- Create an Organizational Unit for CMS within CSE\CSE-IT\ to contain machines.
- Create Joiner account to safely join machines to CMS OU
- Create cse- account for person(s) to remove/modify objects in CMS OU
- Use VAS or SSSD for joining machines to domain and authentication backend.

## References

- [OSG Worker Node Docker Build Context](https://github.com/opensciencegrid/docker-osg-wn)
- [OSG Worker Node Docs](https://opensciencegrid.org/docs/worker-node/using-wn/)
- [Consumable Resources in Slurm](https://slurm.schedmd.com/cons_res.html)
