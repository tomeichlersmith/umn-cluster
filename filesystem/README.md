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
In this directory, there is a python script [reader.py](reader.py) and a job description file [benchmark.sub](benchmark.sub). This python script assumes that it has access to ROOT's python bindings so that it can read through a TTree inside of a ROOT file. Since the system install of ROOT does not have python bindings available, I run this script inside of a container with ROOT available.

The submission file has a few command line parameters allowing the user to decide which case to test. These parameters are provided _in between_ the `condor_submit` command and the description file.
For example, in order to test reading directly, you only need to provide the directory of files to read:
```
condor_submit dir=/full/path/to/dir/to/read benchmark.sub
```
On the other hand, this same directory can be tested with copying and then reading localy by providing one more parameter.
```
condor_submit dir=/full/path/to/dir/to/read cp_to_local=yes benchmark.sub
```
The file system being tested is "chosen" based on the directory input.

By default, we read all of the branches within the input ROOT file.
A more realistic test is to only read a subset of these branches,
you can limit the number of branches read to at most N branches using another command line parameter.
```
condor_submit dir=/full/path/to/dir/to/read max_branches=N benchmark.sub
```

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
HDFS All Branches Local  | 2/19 09:32 | 2/19 12:21
ZFS All Branches Remote  | 2/25 10:12 | NA
ZFS All Branches Local   | NA | NA

## Data Samples
- Mohammad: `/hdfs/cms/user/wadud/anTGC/ntuplesUL/ntuples2018UL/EGammaRun2018*`
- Michael: `/hdfs/cms/user/revering/dphoton/MuPlusXSkim/RunA2018UL/`

## Converting JSON data to CSV
- [Helpful answer](https://stackoverflow.com/a/32965227/17617632)
- [jq](https://stedolan.github.io/jq/manual/)

Convert a JSON file with a list of JSON entries. This overwrites `data.csv` and includes the headers of the columns.
```
jq -r '(map(keys) | add | unique) as $cols | map(. as $row | $cols | map($row[.])) as $rows | $cols, $rows[] | @csv' data.json > data.csv
```
This put the headers in alphabetical order, so you can "append" a new JSON entry to `data.csv`, being careful to have the order of the keys correct.
```
jq -r '[.filesystem, .local, .size, .time] | @csv' new-entry.json >> data.csv
```

## Converting ROOT macro output to CSV
The ROOT macro analysim.C prints out the resulting CSV row at the end of processing;
therefore, we can grab the last line of the output files and append them to the merged data file.
```
find . -maxdepth 1 -type f -name "*.out" -exec tail -n 1 {} >> data.csv ';' -delete
```
