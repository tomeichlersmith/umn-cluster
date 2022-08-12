# Cluster Admin Manual
The word "manual" is probably a misnomer,
this area is simply a collection of studies that were done and
notes that were taken during the construction of the updated cluster.

### Table of Contents
- [filesystem](filesystem) is a study on how HDFS compares to copying to scratch from LOCAL done on the old cluster
- [hardware](hardware) is a survey of the hardware of the nodes in the cluster
- [proto-cluster](proto-cluster) is a series of job-timing studies on the new cluster
- [hardware.md](hardware.md) are notes on how the current hardware interacts with updated software
- `cmsfarm_slack.py` is a (currently not working) script to post the status of the cluster to a channel in slack
- `restart_cvmfs.yaml` is an Ansible script to restart CVMFS
