# Condor Usage

## Example Analysis Submit Script
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
