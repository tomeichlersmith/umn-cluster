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

#### zfs snapshots
[ZFS takes "snapshots"](https://docs.oracle.com/cd/E23824_01/html/821-1448/gbciq.html)
of the data-on-disk periodically in order to prevent unintentional dataloss.
The size of these snapshots roughly scale with the size of any _changes_ in data-on-disk, so large
snapshots will clutter the disks if we remove a lot of data at once. CSE-IT can manually remove ZFS
snapshots if we ask them to.

It is important to keep these snapshots in mind when inspecting the available space on `/local/`.
ZFS _does not_ include these snapshots in the total size of the filesystem since (for most situations)
are negligible. Generally, you can think of the following equation.

Total Raw Disk Space = (ZFS Snapshot Size) + (Size reported from `df`)

This means you will want to ask CSE IT to manually drop snapshots if you intentionally delete
a large amount of data.

**These snapshots are not meant as a form of backup. They are only useful for restoring _the entire
filesystem_ to a previous state.**

#### singularity details
The container runner we have installed on the cluster is called `apptainer` and is a fork of `singularity`;
therefore, it can be accessed under the program name `singularity` as well.

For extra confusion, there is another fork of `singularity` maintained by SyLabs called SingularityCE
(CE for Community Edition) which _has not_ been renamed.

- [Singularity (software) Wikipedia](https://en.wikipedia.org/wiki/Singularity_(software))
- [SingularityCE vs Apptainer Difference](https://groups.google.com/g/singularity-ce/c/WNkeJ43M6Bo)

#### sudo access
A select few members of the research group are given "intermediate" sudo access by the IT administrators.
If you wish to be apart of this group, you should contact IT (specifically Chad).
If you are apart of this group, you can list the commands you have sudo access to with `sudo -l`.

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

#### agedu
[agedu](https://www.chiark.greenend.org.uk/~sgtatham/agedu/manpage.html) is a helpful tool that indexes all data-on-disk according to size _and_ age.
This is very useful for our use case. It operates by scanning an input directory, generating a data file storing this index and 
then opens a rudimentary web page for exploring the data.

It is not available already installed on our systems, but it is relatively easy to build.
_Build and run `agedu` from `/export/scratch` to avoid having it's data file clutter `/local/`_.
```
git clone https://git.tartarus.org/simon/agedu.git
cd agedu
cmake -B build -S . -DCMAKE_C_STANDARD=99
cd build
make
```

Scanning a directory looks like the following.
This is the command that will take a long time to run since it has to go through all files in the provided directory.
```
./agedu/build/agedu --scan /local/cms/user/
```
There are many options for tuning the scan. Look at the online manual or the `--help` option for details.

After the scan is done, you can open up a local, simple web page for exploring the data.
```
./agedu/build/agedu --web
```
