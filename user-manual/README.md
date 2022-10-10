# UMN HEP Cluster 

A computing cluster for the UMN HEP research groups (mainly CMS).

This manual is meant to be a helpful guide for users of this cluster, and be
notes for the administrators documenting why certain design choices were made.

## Table of Contents
- [Architecture](architecture.md)
- [Locations](locations.md)
- [Condor](condor)
  - [configuration](condor/configuration.md)
  - [usage](condor/README.md)
- [Containers and Their Runners](containers.md)
- [Misc Tips and Tricks](misc.md)

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
so you may want a separate window for file editing.

#### Common Issues
> When I try to start the container with `cmssw-cc7...` I get the following error:
```
bash: /local/grid/cmssoft/cms/cmsset_default.sh: No such file or directory
```

The command `cmssw-cc7` is simply a bash script that tries to recreate your _current_ environment
within a CentOS7 container. This means it will re-source `cmsset_default.sh` from whichever directory
you originally sourced it. The symlink at `/local/grid/cmssoft/cms/` simply points to /cvmfs/cms.cern.ch/`
however, this means it uses the wrong directory within the container and you see this error.

### CVMFS Instability
For some reason, the CVMFS mount is failing to reinitialize after it enters some error states.
This causes some machines to occasionally lose access to CVMFS. You can check if CVMFS is available
by running the following command. If CVMFS is operational on that machine, you will see a long
list of different software options provided by CVMFS.
```
ls /cvmfs/cms.cern.ch
```

