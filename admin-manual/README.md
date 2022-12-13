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

## Helpful Tips

#### Disk Usage Report
Need to itemize the space used by folks? Go to that directory and use `du -sh`. Pipe the output to a file for persistency.
**For example**:
```
eichl008@spa-cms017 /local/cms/user> du -sh * | tee /export/scratch/users/eichl008/local_usage.txt 
```

#### Disk Access Report
This is helpful for seeing how long its been since folks have accessed a particular set of files.
Maybe if it has been a long time we can remove those files in order to make space for future files.
`stat -c %X <file>` gives the time of last access in seconds since the Unix epoch, we can use this
in conjuction with `find` (or its parallelized sibling [`fd`](https://github.com/sharkdp/fd)) to
find the file that was last accessed within a certain directory. `awk` can do some simple programming
(like finding a maximum value) and can format the epoch time into human readable.
```
fd -tf -x stat -c '%X' | awk 'BEGIN {t=0} {if ($1 > t) t = $1 fi} END {print strftime("%c",t)}'
```
I can use this behemoth to assign a "last accessed" time stamp to a specific directory. For example,
I've done this for getting "last accessed" time stamps for various user directories.
```
eichl008@spa-cms017 /local/cms/user> for d in *; do
> [ -d $d ] || continue
> last_access=$(cd $d && fd -tf -x stat -c '%X' | awk 'BEGIN {t=0} {if ($1 > t) t = $1 fi} END {print strftime("%c",t)}')
> echo "$d ${last_access}"
> done | tee /export/scratch/users/eichl008/local_access.txt
```
