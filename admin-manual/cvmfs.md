# CVMFS
CVMFS works well most of the time, but we do see a lot of instability on various machines.
I am simply collecting notes here for trying to understand what is going on.

- [CernVM-FS Troubleshooting](https://cvmfs.readthedocs.io/en/stable/cpt-quickstart.html#troubleshooting)

### CVMFS Reboot
If `/cvmfs/cms.cern.ch` is not present but `/cvmfs/cvmfs-config.cern.ch` is, then something went wrong.
The following does a hard reboot of CVMFS which has fixed the problem.
```
sudo service autofs restart && sudo cvmfs_config wipecache
```
Investigation into why this problem arises is still ongoing.

### Static Mount
Due to investigation studying [CVMFS Instability](https://github.com/tomeichlersmith/umn-cluster/issues/20),
we switched to static-mounting CVMFS repositories within `/etc/fstab` rather than using autofs.
This was done to avoid the periodic CVMFS dropping we were observing and was feasible since our
group only uses a handful (~5) of set CVMFS repositories.

EL9 kernels have a patch to autofs that should resolve this dropping issue, so once we update the
cluster operating system we can possibly switch back to autofs.
