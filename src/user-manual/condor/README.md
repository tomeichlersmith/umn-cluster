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
Generally, the executable that condor actually runs for each job is a script (e.g. bash or python)
and not the main executable of our programs. This is because we usually need to set-up some sort
of specialized environment before running the program itself (e.g. by calling `cmsenv` inside of
the correct CMSSW distribution). 

In order to be usable with Condor (which handles the file transfer), we have some requirements 
for these "run scripts" which I list here for future reference.

**Requirements**
- Able to be run in a non-interactive shell
- The input file(s) are in the current working directory.
  - Condor copies them there before the script is started.
- The output file(s) are written to the current working directory.
  - Condor copies all generated files in that directory after the script exits

## Interactive "Job"
HTCondor doesn't really have a defined method for spawning an interactive job.
You may want an interactive job so that you can walk through executing your program manually
to debug what is going wrong. You can spawn an interactive job pretty easily by
having condor run a job that just sleeps indefinitely and then using `condor_ssh_to_job` to
connect to that job in its environment where you can start walking through your job script.
```bash
condor_submit interactive.sub
condor_ssh_to_job <job-number-from-above>
# make sure to remove idle job when you return
condor_rm <job-number-from-above>
```

### interactive.sub
```
executable = /bin/bash
transfer_executable = no
arguments = "-c 'while true; do sleep 20; done'"
queue
```

## Examples
The linked directories below are _examples_ and are not usable out of the box.
These are here just to help explain how to get set up with your own batch ecosystem.

- [Analysis with a ROOT Macro](rootmacro)
- [Analysis with cmsRun](cmsRun)
- [Production with a container](container)
