# Filesystem Benchmarking
In order to inform our filesystem storage decision, we should benchmark our specific use case.

Specifically, I am interested in comparing _reading_ access between ZFS and HDFS both of which are installed at scale currently.
We expect reading access to be more important because we do not have the cores necessary to perform large scale data generation runs;
therefore, we expect only moderate data generation runs or generation done at another cluster with the results copied here for analysis.

## Situation
We have hundreds if not thousands of files that we are reading. 
Most often, only one job will be reading individual files because the whole analysis run is meant to iterate over all of the files.
I forsee two different methods for reading a file within a single job.
1. Read directly from the file stored on a remote mount
2. Copy the file to local scratch space before processing

Both of these reading methods also could be used on both of the different FS options, so we have four test cases.
1. Read direct on ZFS
2. Copy from ZFS and then read local
3. Read direct on HDFS
4. Copy from HDFS and then read local

## Tools
It looks like there are many commands available to report the CPU usage. These are the ones installed on my computer:
- `sar`
- `mpstat`
- `top`
- `htop`
From playing on my computer, it looks like `sar` will work best, but I will update with the actual plan.

## Plan
1. Develop a non-interactive script which makes consistent reads to a ROOT file located somewhere on a remote mount.
2. Wrap this "reader" in a script which can put that process into the background and monitor the CPU usage as well as time it.
3. Launch a large HTCondor campaign of these jobs in collaboration with Chad so he can monitor servers hosting the remote mount
