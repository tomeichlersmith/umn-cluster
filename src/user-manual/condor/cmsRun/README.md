# cmsRun within Condor
A few different scripts used to generate `condor_submit` and CMSSW configurations for 
submitting CMSSW jobs to our condor cluster.

Example usage:
```bash
perl condor_filelist.perl \
  python/ConfFile_MyCmsConfif_cfg.py \
  datafiles/ListOfFiles.txt \
  {CMS run options} \
  --prodSpace /local/cms/user/{username}/jobName \
  --batch 10 \
  --jobname JobName
```

You must run cmsenv (in your desired CMSSW distribution!) before calling `condor_filelist.perl`. 
`condor_filelist.perl` will then group the files in your input file list into batches based 
on the batch size, and generate cfg files for each job in `<prodSpace>/<jobName>/cfg`. 
Upon submission to condor, `batch_cmsRun` (which expects to be moved to `~/bin/batch_cmsRun`) 
will be called for each job to set up the environment and run cmssw.

This version is set up for running on the UMN cluster, and uses the built-in file transferring 
utilities of condor to move the input files. In addition, each job generates a new executable 
named after the job name which calls `batch_cmsRun` from within a slc7 cmssw singularity container. 

### batch_cmsRun
```bash
{{#include batch_cmsRun}}
```

### condor_filelist.perl

```perl
{{#include condor_filelist.perl}}
```
