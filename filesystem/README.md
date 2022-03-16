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

## Running
In this directory, there is a ROOT macro [analysim.C](analysim.C) and a job description file [benchmark.sub](benchmark.sub). We assume that we have access to CVMFS and my personal install of ROOT in my directory in /local/cms/user.
The output of the condor jobs expect the directory `output` to already exist.

The submission file has a few command line parameters allowing the user to decide which case to test. These parameters are provided _in between_ the `condor_submit` command and the description file.
For example, in order to test reading all of the branches from the files on hdfs:
```
condor_submit benchmark.sub
```
A more realistic test is to only read a subset of these branches,
you can limit the number of branches read to at most N branches using another command line parameter.
```
condor_submit max_branches=N benchmark.sub
```
The other paramters are in the table below.

Parameter | Description
---|---
`zfs` | If defined, use data in local rather than hdfs.
`cp_to_scratch` | If defined, copy data file to scratch before processing
`no_proc` | If defined, don't process data file during job at all
`max_branches` | Defined to maximum number of branches to process

### Batch of Clusters
Running the following will get a survey of the 4 different situations given that you want to be reading N branches.
```
condor_submit max_branches=N benchmark.sub # hdfs remote
condor_submit max_branches=N cp_to_scratch=yes benchmark.sub # hdfs to scratch
condor_submit max_branches=N zfs=yes benchmark.sub # zfs via nfs remote
condor_submit max_branches=N zfs=yes cp_to_scratch=yes benchmark.sub # zfs via nfs to scratch
```
Additional situations to include.
```
condor_submit zfs=yes cp_to_scratch=yes no_proc=yes benchmark.sub # just do the copy to scratch
```
We've settled into two values of `max_branches` `-1` to test the maximum analysis where all branches are necessary and `50` to test and average analysis were a large subset is required. 
This means to rerun _all_ of the benchmark tests, you need to submit the following 9 clusters of jobs.
```
condor_submit max_branches=-1 benchmark.sub # hdfs remote
condor_submit max_branches=-1 cp_to_scratch=yes benchmark.sub # hdfs to scratch
condor_submit max_branches=-1 zfs=yes benchmark.sub # zfs via nfs remote
condor_submit max_branches=-1 zfs=yes cp_to_scratch=yes benchmark.sub # zfs via nfs to scratch
condor_submit max_branches=50 benchmark.sub # hdfs remote
condor_submit max_branches=50 cp_to_scratch=yes benchmark.sub # hdfs to scratch
condor_submit max_branches=50 zfs=yes benchmark.sub # zfs via nfs remote
condor_submit max_branches=50 zfs=yes cp_to_scratch=yes benchmark.sub # zfs via nfs to scratch
condor_submit zfs=yes cp_to_scratch=yes no_proc=yes benchmark.sub # just do the copy to scratch
```

In addition, we can check the load on the ZFS disks without interference from the variable disks holding the scratch space
by copying the file to `/dev/null`.
```
condor_submit cp_dev_null.sub
```
The output of these jobs is different from `benchmark.sub` and requires a bit more manipulation.
```
find output/ -type f -exec head -n 1 {} ';' | cut -d ' ' -f 2 | sed 's/system/,<delay-time>/' >> cp_dev_null.csv
```
where `<delay-time>` is the value of the `next_job_start_delay` parameter in `cp_dev_null.sub`.

### Important Note
A **big** parameter is the `next_job_start_delay` parameter. 
This allows us to space out the start time of the jobs so that the servers we are reading from aren't all hammered at once. 
For these tests, I have set this parameter to `5` (seconds) which means the jobs take longer to get going but it keeps the load on the servers hosting the files low.
The [HTCondor documentation](https://htcondor.readthedocs.io/en/feature/man-pages/condor_submit.html?#submit-description-file-commands) points out that this parameter can be completely avoid through more specific tuning of `condor_schedd`.
> This command is no longer useful, as throttling should be accomplished through configuration of the condor\_schedd daemon. 

The [Admin Manual](https://htcondor.readthedocs.io/en/feature/admin-manual/configuration-macros.html) provides two configuration parameters allowing for us to apply a blanket job-start-throttling policy for all cluster users.
> `JOB_START_COUNT` This macro works together with the `JOB_START_DELAY` macro to throttle job starts. The default and minimum values for this integer configuration variable are both 1.
>
> `JOB_START_DELAY` This integer-valued macro works together with the `JOB_START_COUNT` macro to throttle job starts. The `condor_schedd` daemon starts `$(JOB_START_COUNT)` jobs at a time, then delays for `$(JOB_START_DELAY)` seconds before starting the next set of jobs. This delay prevents a sudden, large load on resources required by the jobs during their start up phase. The resulting job start rate averages as fast as `($(JOB_START_COUNT)/$(JOB_START_DELAY))` jobs/second. This setting is defined in terms of seconds and defaults to 0, which means jobs will be started as fast as possible. If you wish to throttle the rate of specific types of jobs, you can use the job attribute `NextJobStartDelay`.

**TODO**: Run some jobs without this parameter to confirm this hypothesis that the load will see a dramatic spike without the spacing.

### Server Load

While the jobs are running, we also want to gather data on the nodes hosting the filesystem involved.
For ZFS, this is simply whybee1 while for HDFS these are the "name nodes" hdfs-nn1 and hdfs-nn2. gc1-se is the "storage element" which may be needed as well.
In order to collect load information during the job, it is important to start logging _before_ the jobs are submitted so that we can get a "baseline". During the HDFS runs that read all the branches from the input files, Chad ran the `sar` command on hdfs-nn1 and we saw CPU usage stay > 98% idle for a vast majority of the run (full `sar` log sampling every 20s in file hdfs-nn1-sar.log).

To help parse the logs, the table below lists the runs that were submitted in clusters and the time they were submitted.

Run | Submission Time | Last Job Completed
----|-----------------|-------------------
HDFS All Branches Remote | 2/18 13:35 | 2/18 17:11
HDFS All Branches cp to scratch  | 2/19 09:32 | 2/19 12:21
ZFS All Branches Remote  | 2/25 10:12 | 2/25 13:57
ZFS All Branches cp to scratch   | NA | NA

**Note**: The logs were generated using a python script reading the ROOT files via the python bindings. 
This was expected to be slow, so I am repeating the jobs with the ROOT macro.
Local testing does show a pretty good speed improvement when using a ROOT macro (or similar speed improvement
when using `SetBranchStatus` instead of constructing/deleting Python objects on each loop).

## Converting ROOT macro output to CSV
The ROOT macro analysim.C prints out the resulting CSV row at the end of processing;
therefore, we can grab the last line of the output files and append them to the merged data file.
```
find output/ -type f -name "*.out" -exec tail -n 1 {} ';' | grep -v "Processing" >> data.csv
```
