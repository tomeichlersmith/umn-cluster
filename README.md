# UMN SPA Computing Cluster

Administrated and maintained by Physics students.

## Requirements
- [CVMFS](https://cernvm.cern.ch/fs/)
- ~[CMS Tier-3 Computing Cluster](https://twiki.cern.ch/twiki/bin/view/CMSPublic/USCMSTier3Doc)~
  - Chad and I talked, we don't think this is feasible
- Container Runner - [singularity](https://sylabs.io/guides/3.7/user-guide/) or [docker](https://docs.docker.com/engine/install/)
- Reliable Data Storage
  - ~[hadoop HDFS](https://hadoop.apache.org/docs/r1.2.1/hdfs_design.html)~ 
    - Not feasible given the age of our cluster hardware
  - Plain-Old NFS
- Cluster Job Scheduler
  - [HTCondor](https://htcondor.org/)
  - [Slurm](https://slurm.schedmd.com/)
- Network and Infrastructre Administration Tool
  - [Puppet](https://puppet.com/docs/)
- Connect to LDCS?
  - [ARC Client Tools](https://www.nordugrid.org/arc/arc6/users/client_install.html)
  - Ask Florido (ARC dev and Lund sysadmin) for advice on setup
- Retire LDAP Auth, try to use VAS to use IDs from central IT
  - Can be accomplished most simply by CSE-IT adminiing lower-levels of cluster
- Retire CFEngine admin tool in favor of unification with puppet
- Update computers to CentOS7 across the board
  - SCL6 EoL was more than a year ago

## Open Questions

### Tom Answer
- Can we _not_ be a full CMS Tier 3? Having all of the OSG software stack significantly adds to the complexity.
- Is it possible to have a shared submit node for submitting to CMS cluster?
- Can we host our workload manager within a container? This would allow us to not have full access to sensitive parts of cluster.

### Chad Answer
- Is CSE-IT open to a "split-admin" model where CSE-IT handles the bottom of the stack (OS, Auth, NFS home dirs, ZFS storage, container runner)
  and we handle the top of the stack (workload manager, cvmfs, container runner, etc...)? We could safely split this administration by either
  - have the entire top level be housed within a container (requires workload manager and container runner to be runnable within a container)
  - have Ansible script configure this top level that Chad deploys
  - CSE-IT provides admin privileges to single SPA point-person for admin the cluster (unlikely)

## Notes from Chad
> CSE-IT has determined that the cluster machines are no longer viable to support as they do not use modern remote [IPMI](https://en.wikipedia.org/wiki/Intelligent_Platform_Management_Interface) access.

- ~10 yr old machines where ~10% of them have had hardware failures are not a sustainable base for Hadoop
- add zpool onto whybee1 with 20 6TB disks in server room right away, evacuate hadoop before shutting down

### Main Elements
- Twins/Gopher Machines
  - Scientific Linux 6 (end of life more than a year ago...)
  - Configured with [CFEngine](https://docs.cfengine.com/docs/3.18/examples.html)
  - LDAP Authentication
  - Hadoop data disks
- Scorpion Machines
  - CentOS7
  - Configured with Puppet
  - LDAP Authentication
  - Hadoop data disks
- Various others
  - Configured with CFEngine

Specific Node | Description
---|---
gc1-hn | Head Node for cluster
gc1-se | Storage Element connects HDFS
gc1-ce | compute element - Condor
hdfs-nn1 | Name Node for Hadoop
hdfs-nn2 | secondary name node
whybee1 | Node hosting ZFS server (/data/cmszfs1)

> If CMS wants the cluster or part of the cluster to continue, making it as simple as possible is the correct path.

"Simplifying" includes:
- Retiring Hadoop
- New Compute Element with Condor or Slurm
- New Submit Node
- Compute nodes would be treated as simple commodity hardware. e.g. if a machine dies, it simply goes away.

### Other considerations:
- Identity Management - Versatile Authentication Service (VAS) authentication against Active Directory (AD) or local accounts.
- Storage access - For example whybee1 serves NFS based on AD accounts/groups
- Home Directories - If others outside of CSE-IT have root access to machines, we cannot use CSE home directories due to security. Necessitate our own home directory server?
- Jeremy has ~25 6TB hard drives. We could put them into a JBoD (Just a Bunch of Disks) and connect to whybee1 or use another box for a new ZFS pool.
