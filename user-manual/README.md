# UMN HEP Cluster
A computing cluster for the UMN HEP research groups (mainly CMS).

This manual is meant to be a helpful guide for users of this cluster,
and be notes for the administrators documenting why certain design choices were
made.

## Table of Contents
- [Architecture](architecture.md)
- [Locations](locations.md)
- Condor
  - [configuration](condor_config.md)
  - [usage](condor_usage.md)
- [Containers and Their Runners](containers.md)
- [Misc Tips and Tricks](misc.md)

## General Comments
This cluster is roughly 140 machines. These machines are (on average) a decade old,
so we chose to keep the design simple and modular in order to allow the cluster as
a whole last longer as the individual components die (and we wait for potentially more
funding to upgrade components).

Simplification of the cluster led to the decision to decomission HDFS (a distributed filesystem).
This decision is supported by studying the behavior of using a NFS-mounted ZFS storage node already existing (whybee1)
as the main storage for our cluster computing. This study showed that copying files to a scratch space, processing them,
and then copying the output files to the storage area was satisfiably performant.
