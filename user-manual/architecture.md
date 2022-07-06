# Cluster Architecture

As mentioned previously, the cluster is designed with simplicity in mind,
keeping longevity as the highest priority. Since the cluster does not see many
users (only ~dozen at any one time), we conciously chose to sacrifice some
performance enhancements in order to maintain a certain level of simplicity in
the cluster design.

![Cluster Architecture Diagram](spa-cluster-diagram.png)

### Comments
- OSG stands for [Open Science Grid](https://opensciencegrid.org/).  We have
  designed the cluster in order to (in the future) connect to OSG and allow
  users of OSG to submit jobs from our cluster and write output files to our
  cluster. We do not currently have plans to enable running OSG jobs on our
  cluster unless absolutely necessary (discussions with representatives from OSG
  indicate that this is feasible).
- The head node (`spa-osg-hn`) and the worker nodes are only accessible by
  CSE-IT admins and those of us added as "cluster admins" by IT. Currently, the
  cluster admins are Jeremy and Tom.
- The login node (`spa-osg-login`) is intended to be the point from which
  condor jobs are submitted. Additional login nodes could be added similar to
  how we currently have multiple zebra interactive nodes.
- Future plans for the cluster includes connecting the workstations to the
  condor cluster allowing them to submit jobs directly as well.
