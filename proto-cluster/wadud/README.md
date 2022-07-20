# Compare Actual Analysis

We want to look at how the performance changes when running analyses on the new cluster with the copy-to-scratch compared to the old cluster reading directly from HDFS. We are expecting jobs to take longer since they have an extra task, but we would like to quantify the difference.

The file `condor_history_wadud_scorpion1.log` lists the job IDs, their submission, start, and end times for all of Mohammad's jobs
submitted from scorpion1 that were still kept in the condor spool as of July 20, 2022. We can extract batches of jobs from the 
submission times and then study how long they took to run as well as how long the entire campaign ran.

### Usage Notes
I've pulled out the stuff from Mohammad's submission script so that I can give more control to Condor for later file copying. The basic usage is 

```
# choose a job list
ln -sf <job-list.txt> jobList.txt
# write submission file and create working directories
cp ana.sub ana-<name>.sub
./list-queue.sh >> ana-<name>.sub
# submit to condor
condor_submit ana-<name>.sub
```

### July 13, 2022 Meeting with Mohammad
Learn how someone does an actual CMS analysis so I can replicate it in this test.

- NTuples on HDFS are simulations of various processes related to analysis (including some data)
- NTuples consist of lots of vector<float> for various physics objects on event-by-event basis
- Usually only looking at a subset of these events matching certain quality criteria
- store objects of interest after selection in new set of smaller ntuples for later plotting

- with HDFS the skimming takes ~3 hours for whole group of jobs to finish (<30min per file)
- about 4k jobs to skim all of run 3

Mohammad runs the following script which relies on some other files in the same directory.

/data/cmszfs1/user/wadud/aNTGCmet/aNTGC_analysis/Systematics/batch/csub.sh

