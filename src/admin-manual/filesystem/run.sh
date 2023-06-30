#!/bin/bash

set -e

####################################################################################################
# run.sh
#   This run script uses an old ROOT install in my /local/cms/user/ directory.
#   It may be broken in the future if that install does not exist.
####################################################################################################

_root_dir="/local/cms/user/eichl008/root/6.22.06/install"

# location of cms shared libraries
# use this to specifiy which gcc should be used in compilation
_cvmfs_dir="/cvmfs/cms.cern.ch/slc7_amd64_gcc820"
export GCCDIR="$_cvmfs_dir/external/gcc/8.2.0"

# Setup the input package
#   if the path contains 'cvmfs', then we assume we are given
#     a path to cvmfs package and source the corresponding init.sh
#   otherwise, source the input
ldmx-env-source() {
  _file_to_source="$1"
  if [[ "$1" == *"cvmfs"* ]]
  then
    _file_to_source=$1/etc/profile.d/init.sh
  fi
  
  source ${_file_to_source}
}

## Initialize libraries/programs from cvmfs and /local/cms
# all of these init scripts add their library paths to LD_LIBRARY_PATH
ldmx-env-source $_cvmfs_dir/external/cmake/3.17.2 #cmake
ldmx-env-source $_cvmfs_dir/external/bz2lib/1.0.6 #bz2lib
ldmx-env-source $_cvmfs_dir/external/zlib/1.0     #zlib
ldmx-env-source $GCCDIR                           #gcc
ldmx-env-source $_root_dir/bin/thisroot.sh        #root 

root.exe -l -b -q $@
