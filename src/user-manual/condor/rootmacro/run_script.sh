#!/bin/bash

####################################################################################
# run ROOT macro 
#
# INPUTS:
#   1 - comma-separated list of input file names (condor copies them to CWD)
#   2 - output file name (condor copies them out of CWD)
#   3 - xsec
#   4 - MC pileup file
####################################################################################

set -e

source /cvmfs/cms.cern.ch/cmsset_default.sh

echo -e "Running job on machine:"
hostname

cd /local/cms/user/wadud/aNTGCmet/CMSSW_10_6_24/src
eval `scramv1 runtime -sh`
cd -

# write the local file listing the input data files (one per line)
echo "$1" | tr , '\n' > $2.inputfiles.list

root -l -b -q "/local/cms/user/eichl008/umn-cluster/user-manual/condor/rootmacro/anamacro.C(\"$2.inputfiles.list\",\"$2\",$3,\"$4\")"

