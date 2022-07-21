#!/bin/bash

# list job queue for analysis

outputDir=/local/cms/user/eichl008/umn-cluster/proto-cluster/wadud/output
splitfiles=1

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
    sed "s|/hdfs/cms/user/wadud/anTGC|/local/cms/user/wadud/aNTGCmet|" ${singleJobFileList} > ${jobOutDir}/input_files.list

    i=0
    while read input_file; do
      i=$((i+1))
      echo "${input_file}, $(printf "%s_%05d.root" ${jobBaseName} ${i}), ${xSec}, ${mcPUfile}"
    done < ${jobOutDir}/input_files.list
  done
} < ntuples_RunIIUL.csv

exit 0
