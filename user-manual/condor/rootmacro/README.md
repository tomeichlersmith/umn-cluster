# Analysis with a ROOT Macro
Running a ROOT macro over a set of input parameters and files is a common
analysis strategy within HEP.

### Table of Contents
- run\_script.sh : The actual executable run by condor. It sets up the environment and runs `root`.
- anamacro.C : The ROOT macro that is being run. It imports that analyzer defined elsewhere and then
  gives the parameters parsed from the command line.
- ana.sub : The condor sumbission file
- list-queue.sh : The script that parses `jobList.txt` for the input parameters, printing one line
  per job.

