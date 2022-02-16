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

## Data Samples
Mohammad: `/hdfs/cms/user/wadud/anTGC/ntuplesUL/ntuples2018UL/EGammaRun2018*`
Michael: `/hdfs/cms/user/revering/dphoton/MuPlusXSkim/RunA2018UL/`
