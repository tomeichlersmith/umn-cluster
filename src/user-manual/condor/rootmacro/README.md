# Analysis with a ROOT Macro
Running a ROOT macro over a set of input parameters and files is a common
analysis strategy within HEP.

## Table of Contents
- run\_script.sh : The actual executable run by condor. It sets up the environment and runs `root`.
- anamacro.C : The ROOT macro that is being run. It imports that analyzer defined elsewhere and then
  gives the parameters parsed from the command line.
- ana.sub : The condor sumbission file
- list-queue.sh : The script that parses job and sample listing files for the input parameters and
  prints the arguments one line per job

The job submission is separated out like this so that you can do a series of tests to make sure
that things are operating as expected.
1. Make sure `anamacro.C` runs through ROOT as you are developing your analyzer.
2. Make sure `run_script.sh` runs the same to make sure it sets up the correct environment
3. Run `list-queue.sh` to make sure that the jobs are being fed the correct parameters
4. Submit to the cluster

### run_script.sh
```bash
{{#include run_script.sh}}
```

### anamacro.C
```c
{{#include anamacro.C}}
```

### ana.sub
```
{{#include ana.sub}}
```

### list-queue.sh
```bash
{{#include list-queue.sh}}
```
