#!/bin/bash

set -e

####################################################################################################
# dd.sh 
#   Time a dd copy from /local/ to /export/scratch and then removing it.
#   A bs=5M was found from a rough optimization of copying a 2.2GB file manually.
####################################################################################################

_file=$1
_scratch=/export/scratch/users/$USER

if [[ ! -d ${_scratch} ]]; then
  mkdir -p ${_scratch}
fi

_filename=$(basename ${_file})

if time dd bs=5M if=${_file} of=${_scratch}/${_filename}; then
  rm ${_scratch}/${_filename}
fi
