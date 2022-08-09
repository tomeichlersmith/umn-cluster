#!/bin/bash

####################################################################################
# run cmsRun
#
# INPUTS:
#   1 - CMSSW directory on /local to be running with
#   2+ - arguments to cmsRun
####################################################################################

set -e

source /cvmfs/cms.cern.ch/cmsset_default.sh

echo -e "Running job on machine:"
hostname

cd $1
eval 'cmsenv'
cd -

cmsRun ${@:2}
