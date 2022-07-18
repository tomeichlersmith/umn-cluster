#!/bin/bash

####################################################################################
# run Mohammad's systematics analyzer
#
# INPUTS:
#   1 - text file listing input files
#   2 - full path to output file
#   3 - xsec
#   4 - pileup file
####################################################################################

scratch_dir=/export/scratch/users/$USER
[ -d ${scratch_dir} ] || mkdir -p ${scratch_dir} || { echo "Could not create scratch dir!"; exit 1; }

set -e

source /cvmfs/cms.cern.ch/cmsset_default.sh

echo -e "Running job on machine:"
hostname

cd /local/cms/user/wadud/aNTGCmet/CMSSW_10_6_24/src
eval `scramv1 runtime -sh`
cd -

working_path=${scratch_dir}/$(basename $2)

root -l -b -q "/local/cms/user/eichl008/umn-cluster/proto-cluster/wadud/anamacro.C(\"$1\",\"${working_path}\",$3,\"$4\")"

cp ${working_path} $2
