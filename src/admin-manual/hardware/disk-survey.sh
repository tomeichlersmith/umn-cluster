#!/bin/bash

# ssh to every node in our cluster and get their stats

# loop over hosts executing the passed arguments on each host in sequence
__loop_over_hosts__() {
  for h in  \
            cdms-04-{1..4} \
           cdms{1,3} \
           gopher-{01..11}-{1..4} \
           gopher-12-{1..3} \
           scorpion{1..48} \
           zebra0{1..4} \
           spa-cdms2 \
           twins-a{07..24} \
           twins-b{01..23} \
           wn01-{1,2,4} wn02-2
  do
    printf "%12s\n" $h
    if ! ssh -q -o "StrictHostKeyChecking no" -o "ConnectTimeout 5" $h $@; then
      printf "NA\n"
    fi
  done
}

#Host nproc RAM CVMFS HDFS scratch sing OS
__loop_over_hosts__ lsblk
