#!/bin/bash

# ssh to every node in our cluster and get their stats

# loop over hosts executing the passed arguments on each host in sequence
__loop_over_hosts__() {
  for h in cdms-04-{1..4} cdms{1,3} gopher-{01..12}-{1..4} scorpion{1..6} scorpion{8..48} zebra0{1..4} spa-cdms2 twins-a{07..24} twins-b{01..23} wn01-{1,2,4} wn02-2; do
    printf "%12s  " $h
    if ! ssh -q -o "StrictHostKeyChecking no" $h $@; then
      echo "can't connect"
    fi
  done
}

__check_connection__() {
  __loop_over_hosts__ echo connected
}

__check_cmssw__() {
  __loop_over_hosts__ 'if [[ -d /cvmfs/cms/cern.ch ]]; then echo "no cvmfs"; elif [[ ! -d /hdfs/cms/user ]]; then echo "no hdfs"; else echo "cvmfs and hdfs"; fi'
}

__scratch_space__() {
  __loop_over_hosts__ 'df -h /export/scratch | sed 1d'
}

__available_memory__() {
  __loop_over_hosts__ awk \'\/MemTotal\/\{printf \"%d GB\\n\", \$2\/1024\/1024\}\' /proc/meminfo
}

__available_cpus__() {
  __loop_over_hosts__ nproc
}

#Host nproc RAM scratch CVMFS HDFS
printf "%12s\t%5s\t%5s\t%5s\t%4s\t%7s\n" Host nproc RAM CVMFS HDFS scratch
__loop_over_hosts__ \
  printf \"\%5d\\t\" \$\(nproc\) \;\
  awk \'\/MemTotal\/\{printf \"%2d GB\", \$2\/1024\/1024\}\' /proc/meminfo \;\
  printf \"\%5s\\t\%4s\\t\" \$\(if [[ -d /cvmfs/cms.cern.ch ]]; then echo "yes"; else echo "no"; fi;\) \$\(if [[ -d /hdfs/cms/user ]]; then echo "yes"; else echo "no; fi;\) \;\
  'df -h /export/scratch | sed 1d | tr -s " " | cut -d " " -f 2'
  #printf "\n"

