# Condor Usage

HTCondor has a wonderful [manual](https://htcondor.readthedocs.io/en/latest/) for both users and admins.
For users, I would specifically highlight the 
[Submitting a Job](https://htcondor.readthedocs.io/en/latest/users-manual/submitting-a-job.html) page,
which goes into more explanation and offers more examples than I do here.

## Common Workflows

From the perspective of condor the big difference between different batch running modes
is whether or not the individual jobs are reading input data files during processing.
All jobs will have to read files at the start of a job (i.e. to launch the software
that is doing the work); nevertheless, the continual reading of a file during a job
is what has the potential to lock-up our shared data space.

Just to have a short-hand, I am going to call "production" jobs ones that do not
require reading of input data files during processing (e.g. generation of simulated
data) and "analysis" jobs ones that do require reading of input data (e.g. reconstruction
of data, calculating analysis variables, filling histograms). For the purposes of this
cluster, "input data files" are ones stored here on our cluster. If your job is downloading
data from some other cluster to run over, these jobs are effectively "production" jobs from
our perspective. Condor has several helpful features that we can utilize to make submission 
of clusters of similar jobs easier.

Besides the existence of input data files, another separation between job types is the
"foundation" of the software that is being run. Many CMS users utilize CVMFS to run CMSSW
or related tools -- these will be called "cmssw" jobs even if they are not literally running
CMSSW -- while other users run containerized applications via singularity -- these will be 
called "singularity" jobs.

In summary, we have four distinct job categories.
1. Production via cmssw
2. Production via singularity
3. Analysis via cmssw
4. Analysis via singularity

This document is focused on detailing how to accomplish each of the four job categories listed
above. A vast majority of batch jobs already fall into one of the above categories and this
cluster effectively assumes that all batch jobs _will_ be in one of these categories.[^1]

Generally, the difference between production and analysis jobs can be handled by using
different queue commands (more explanation below), while the difference between cmssw
and singularity running can be handled by using different executables that the
jobs use during running.

**Note** In order to help meter the load on `/local/cms/...`, we give control of file transfering
over to condor. This allows the file transfer to be centrally maintained so that we can keep
it below configurable thresholds so users can still interact with `/local/cms/...` while jobs
are running.

[^1]: This assumption is not formally required. Jobs not in one of these categories will not
be prevented from running; nevertheless, the cluster is designed with these job-types in mind
so jobs not conforming to them may be more difficult to configure properly.

### Queue Commands
The `queue` command in a condor submit file has multiple different argument options, two are
of particular interest to us.

First (and more simply), we can use the basic integer argument for "production" style jobs.
This will allow define a unique integer `$(Process)` that we can use elsewhere in our submit
script to make sure the jobs produce unique simulated data (e.g. as a random seed number).
The command below would submit 200 jobs where the value of `$(Process)` would range from 0 to 199.
```
queue 200
```

Next, we can have condor create a job for each file matching a certain shell "glob" pattern.
The command below would submit a job for each `.root` file in the listed directory defining
the value of `$(input_file)` to be the file.
```
queue input_file matching files /full/path/to/directory/*.root
```

Finally, for more complicated situations, we can call a shell script to print out the argument
lines for the `queue` command. This is helpful for situations where we need more than one changing
argument per job (for example, some input files have a certain parameter while others have a different
parameter).
```
queue arg1, arg2, arg3 from list_args.sh |
```
The arguments `argN` are comma separated and simply taken from the lins printed by `list_args.sh` to
the terminal. This is also a helpful setup because you can run `list_args.sh` directly to see the
list of job arguments before submitting them.

### Executables

## Examples
- [Analysis with a ROOT Macro](rootmacro)
- [Analysis with cmsRun](cmsRun)
- [Production with a container](container)

#### Analysis Submit Script
```
# analysis.sub - run as condor_submit analysis.sub

# the "initialdir" is used as the default directory for relative paths in a lot of condor_submit stuff
#   for us this is the relative path for output files so set this to the full path to the output directory
initialdir = /full/path/to/output/directory/

# the executable we are using is whatever bash script you have written to setup the environment and run cmssw
# the executable needs to follow these criteria:
#    1. have the output files written to the directory it is launched from (i.e. don't `cd` anywhere)
#    2. assume the input file has been copied to the current directory as well
#    3. DONT copy input files or output files anywhere, let condor handle it
executable = /full/path/to/executable.sh
transfer_executable = yes # we want a copy on the worker nodes

# the arguments list to the executable
#   you can add other arguments, but I'm just assuming that the only argument you care about is
#   the input file. I use the condor "macro" BASENAME here since the input file will be copied to
#   the working directory by condor.
arguments = "$BASENAME(input_file)"

# the input files you want transferred to the working directory by condor
#    this is a comma-separated list of files
#    things on /local that are only used at the beginning of the job can probably stay there
#    since they are only read for a short time and we can stagger the job starts
transfer_input_files = $(input_file)

# stagger job starts so that the multiple jobs can read from the config/software files
#    on /local at the start of each job without overloading /local
# hopefully, we will replace this by a centrally controlled job stagger so this can be omitted by users
next_job_start_delay = 5

# submit a job for each file matching the glob pattern
#    this 'input_file' "variable" is what I use above in arguments and transfer_input_files
queue input_file matching files /full/path/to/input/dir/*.root
```
