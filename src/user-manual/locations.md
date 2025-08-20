# Important Locations

This page lists important locations (i.e. directories) that users of the cluster should be aware of.

### Home Directories 

**Path**: `/home/<username>` mostly abbreviated as `~` 

**Type**: NFS4

The home directories are provided by central CSE IT. This makes them shared across the _entire_ CSE
computing infrastructure (including other Linux login nodes on campus, not just within SPA).  While
you technically have the ability to request more storage capacity within them, the default quota
limit is only ~1 GB.

**Suggested Use**: Keep configuration files (`.bashrc`, `.vimrc`, etc...) here _only_.  Code and
data files should be kept elsewhere.

### Shared Data Space 

**Path**: `/local/cms/user/<username>` which is a friendlier alias to
`/data/cmszfs1/user/<username>` 

**Type**: NFS4

The shared data space (often called "local") is a network attached filesystem with storage purchased
by funding from our research group. This storage is shared among all users within UMN HEP
experimentalist groups with a large majority of the users being from the UMN CMS groups.  The
directories are shared across the different nodes using NFS but on the storage node that hosts the
data itself, they are stored within a ZFS file system.  [ZFS](https://en.wikipedia.org/wiki/ZFS) was
chosen because it has some self-healing properties to help prevent bit-rot so it is a safer choice
for storing large quantities of data.

The fact that this space is shared with all nodes in the cluster is both a positive and a negative.
The positive is that you can use this area to share data between nodes (and between users) without
the harsh limit of the home directories. The negative is that since the files are mounted over the
network, they are less quickly read/written than if they were available on a disk attached to the
machine you are on.

**Suggested Use**: Data Storage. Some folks also keep their code here, but you will see decreased
performance compared to non-network disks.

### Scratch Space 

**Path**: `/export/scratch/users/<username>` 

**Type**: ext4

As the name implies, the scratch space is intended to be used for scratch work.  It is _not_ shared
between different nodes and so none of the files within it are backed-up to another location.
Nevertheless, since the disk being used for the scratch space are physically attached to the node
and are not mounted over the network, they are much more performant for reading and writing. This
makes the scratch space ideal for code development as long as the code that is being developed is
backed-up somewhere else (for example, GitHub or GitLab).

I spend most of my time in the scratch space of my workstation, only moving to the shared data space
when I need to start using the multi-node nature of the cluster (i.e. submit jobs to condor).

Since each node has its own distinct scratch space, you will need to create a directory for your work.
```
mkdir -p /export/scratch/users/${USER}
```
These directories are only removed when the computer is re-installed with a new OS
(only happens every few years), so you can keep returning to the same workstation and its scratch space
for your work.

The scratch space is also used by condor as the "sandbox" directory that jobs are run within.

**Suggested Use**: Code development and test running.

### Temp Directory

**Path**: `/tmp`

**Type**: ext4

Like the scratch space, this directory is designed to host temporary files that the computer
needs to use. Unlike the scratch space, it is kept small O(10GB) and is not designed to be 
used directly. It should be left for system commands that require temporary files (e.g. ssh-agent).

**Suggested Use**: Dont use.

### Root Directory

**Path**: `/`

**Type**: ext4

This is the space that hosts the operating system for the node.
We try to keep it light so that the scratch space can have most of the disk
that is attached to the node. It usually runs O(100GB) to give plenty of room for
the system to generate the files it needs to function properly.

**Suggested Use**: Dont use.
