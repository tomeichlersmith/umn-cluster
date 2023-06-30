# Common Issues

### cmssw startup
> When I try to start the container with `cmssw-cc7...` I get the following error:
```
bash: /local/grid/cmssoft/cms/cmsset_default.sh: No such file or directory
```

The command `cmssw-cc7` is simply a bash script that tries to recreate your _current_ environment
within a CentOS7 container. This means it will re-source `cmsset_default.sh` from whichever directory
you originally sourced it. The symlink at `/local/grid/cmssoft/cms/` simply points to /cvmfs/cms.cern.ch/`
however, this means it uses the wrong directory within the container and you see this error.

### CVMFS Instability
For some reason, the CVMFS mount is failing to reinitialize after it enters some error states.
This causes some machines to occasionally lose access to CVMFS. You can check if CVMFS is available
by running the following command. If CVMFS is operational on that machine, you will see a long
list of different software options provided by CVMFS.
```
ls /cvmfs/cms.cern.ch
```

