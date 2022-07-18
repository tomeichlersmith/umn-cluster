#!/bin/bash

# list job queue for analysis

outputDir=/local/cms/user/eichl008/umn-cluster/proto-cluster/wadud
splitfiles=1

echo "queue input_file, output_file, xsec, pileup_file from ("

readarray -t jobList < jobList.txt
{
  read
  while IFS=, read -r shortName dataset xSec xSecUnc singleJobFileList mcPUfile Nevents SumW SumW2 Neff lumi || [ -n "$shortName" ];
  do
    if [[ ! " ${jobList[@]} " =~ " ${shortName} " ]]; then
      continue
    fi

    jobBaseName=$(basename "${singleJobFileList}")
    jobBaseName="${jobBaseName%.*}"
    jobOutDir=${outputDir}/${jobBaseName}

    # create job directories
    [ -d "${jobOutDir}" ] || mkdir -p "${jobOutDir}"

    nFiles=$(sed -n '=' ${singleJobFileList} | wc -l)
    split -d -a 5 -l ${splitfiles} ${singleJobFileList} "${jobOutDir}/${jobBaseName}_"

    for subJobList in $(find "${jobOutDir}" -name "${jobBaseName}_*" | sort);
    do
      jobName=$(basename ${subJobList})
      jobName="${jobName%.*}"
      outputFile=${jobOutDir}/${jobName}.root
      echo "  ${subJobList}, ${outputFile}, ${xSec}, ${mcPUfile}"
    done
  done
} < ntuples_RunIIUL.csv

echo ")"
exit 0
