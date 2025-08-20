# UMN HEP Cluster 

A computing cluster for the UMN HEP research groups (mainly CMS).

This manual is meant to be a helpful guide for users of this cluster, and be
notes for the administrators documenting why certain design choices were made.

## General Comments 

This cluster is roughly 140 machines. These machines are
(on average) a decade old, so we chose to keep the design simple and modular in
order to allow the cluster as a whole last longer as the individual components
die (and we wait for potentially more funding to upgrade components).

Simplification of the cluster led to the decision to decomission HDFS (a
distributed filesystem).  This decision is supported by studying the behavior
of using a NFS-mounted ZFS storage node already existing (whybee1) as the main
storage for our cluster computing. This study showed that copying files to a
scratch space, processing them, and then copying the output files to the
storage area was satisfiably performant.

Many different folks require many different libraries and some of those libraries
conflict with each other and cannot even be installed on the same machine. For this reason,
we are standardizing the usage of containers for compiling and running all software.
CMS has put shared a set of helpful containers on CVMFS, so CMS folks can use it from there.

Launching the development environment looks like the following
```
source /cvmfs/cms.cern.ch/cmsset_default.sh
export SINGULARITY_BIND=/home/,/local/cms/user/,/export/scratch/
cmssw-cc7 --ignore-mount /cvmfs/grid.cern.ch/etc/grid-security,/cvmfs/grid.cern.ch/etc/grid-security/vomses
```
Then you can run your normal compiling/running commands from within this container.

**Note**: Your favorite text editor may not be available within the container,
so you may want a separate window for file editing. Having two windows open side-by-side
can be done with [tmux](./misc/tmux.md).
