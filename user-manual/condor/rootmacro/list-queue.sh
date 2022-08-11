#!/bin/bash

# list job queue for analysis

outputDir=/local/cms/user/eichl008/umn-cluster/user-manual/condor/rootmacro/output
sample_file=/local/cms/user/gsorrent/antgc_analysis/samples/aNTGC_Samples-ntuples_2017UL.csv
job_list=/local/cms/user/gsorrent/antgc_analysis/hltSF/UL17/batch/jobList.txt
splitfiles=1

readarray -t jobList < ${job_list}
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
    # make sure any data path left on HDFS is updated to its new location on LOCAL
    #   also write the input file list to a file for later reading
    sed "s|/hdfs/cms/user/wadud/anTGC|/local/cms/user/wadud/aNTGCmet|" ${singleJobFileList} > ${jobOutDir}/input_files.list

    i=0
    while read input_file; do
      i=$((i+1))
      # skip files that don't exist
      [ -f ${input_file} ] || continue
      # print row of inputs to run script
      echo "${input_file}, $(printf "%s_%05d.root" ${jobBaseName} ${i}), ${xSec}, ${mcPUfile}"
    done < ${jobOutDir}/input_files.list
  done
} < ${sample_file}

exit 0
