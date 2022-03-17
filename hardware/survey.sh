#!/bin/bash

# ssh to every node in our cluster and get their stats

# loop over hosts executing the passed arguments on each host in sequence
__loop_over_hosts__() {
  for h in cdms-04-{1..4} \
           cdms{1,3} \
           gopher-{01..12}-{1..4} \
           scorpion{1..48} \
           zebra0{1..4} \
           spa-cdms2 \
           twins-a{07..24} \
           twins-b{01..23} \
           wn01-{1,2,4} wn02-2
  do
    printf "%12s\t" $h
    if ! ssh -q -o "StrictHostKeyChecking no" -o "ConnectTimeout 5" $h $@; then
      printf "%5s\t%5s\t%5s\t%4s\t%7s\t%4s\t%s\n" NA NA NA NA NA NA NA
    fi
  done
}

#Host nproc RAM CVMFS HDFS scratch sing OS
printf "%12s\t%5s\t%5s\t%5s\t%4s\t%7s\t%4s\t%s\n" Host nproc RAM CVMFS HDFS scratch sing OS
__loop_over_hosts__ \
  printf \"\%5d\\t\" \$\(nproc\) \;\
  awk \'\/MemTotal\/\{printf \"%2d GB\\t\", \$2\/1024\/1024\}\' /proc/meminfo \;\
  printf \"\%5s\\t\%4s\\t\" '$(if [[ -d /cvmfs/cms.cern.ch ]]; then echo "yes"; else echo "no"; fi;)' '$(if [[ -d /hdfs/cms/user ]]; then echo "yes"; else echo "no"; fi;)' \;\
  printf \"\%7s\\t\" '$(df -h /export/scratch | sed 1d | tr -s " " | cut -d " " -f 2)' \;\
  printf \"\%4s\\t\" '$(if hash singularity &> /dev/null; then echo "yes"; else echo "no"; fi;)' \;\
  printf \"\%s\\n\" '"$(lsb_release -d | sed "s/Description:[ \t]*//")"' \;\

