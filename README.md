# UMN HEP Computing Cluster

Administrated and maintained by HEP students.

## Stack

- OS
  - Stable, CERN has not made a public decision on future of CentOS ==> go more mainstream?
  - Ubuntu or Fedora?
- Auth
  - VAS and AD using IDs from central IT
  - LDAP retired by central IT, would mean we'd need to handle our own auth ==> recipe for disaster
- Storage
  - ZFS for some storage and larger home directories
    - i.e. merge `/data/cmszfs1/user/$USER` and `/home/$USER` for our lab's cluster
  - [hadoop HDFS](https://hadoop.apache.org/docs/r1.2.1/hdfs_design.html)
    - Not very feasible given the age of our cluster hardware
    - need some performance research, **can a medium cluster operate effectively on more simplified storage solution?**
- Admin Config Manager
  - [Ansible](https://docs.ansible.com/) for ease of use
  - ~[Puppet](https://puppet.com/docs/)~ ruled out due to complexity
- Workload Manager
  - [HTCondor](https://htcondor.org/)
  - [Slurm](https://slurm.schedmd.com/)
  - Decide based on ease of setup
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

## References

- [OSG Worker Node Docker Build Context](https://github.com/opensciencegrid/docker-osg-wn)
- [OSG Worker Node Docs](https://opensciencegrid.org/docs/worker-node/using-wn/)
