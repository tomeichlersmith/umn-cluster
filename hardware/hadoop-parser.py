import sys
import csv

with open(sys.argv[1]) as f :
    input_lines = f.readlines()

current_host = None
sizes = []
with open(sys.argv[1].replace('txt','csv'),'w',newline='') as f :
    csv_f = csv.writer(f)
    csv_f.writerow(['Host','HDFS Participant','Disk Size'])
    for l in input_lines :
        if l[0] == ' ' :
            # new hostname
            if current_host is not None :
                print(current_host,sizes)
                if len(sizes) > 0 :
                    for s in sizes :
                        csv_f.writerow([current_host,True,s])
                else :
                  csv_f.writerow([current_host,False,0])
            current_host = l.strip()
            sizes = []
        elif l.startswith('Filesystem') :
            continue
        elif l.startswith('/dev/') :
            # extract size
            sizes.append(l.split()[1])
        elif l == 'NA' :
            continue

