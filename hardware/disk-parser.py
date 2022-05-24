import sys
import csv

with open(sys.argv[1]) as f :
    input_lines = f.readlines()

possible_host = None
current_host = None
current_size = None
current_category = None
with open(sys.argv[1].replace('txt','csv'),'w',newline='') as f :
    csv_f = csv.writer(f)
    csv_f.writerow(['Host','Category','Size'])
    for l in input_lines :
        if l[0] == ' ':
            # possible new hostname
            possible_host = l.strip()
        elif l.startswith('NAME') :
            # table header output of lsblk
            if current_size is not None :
                csv_f.writerow([current_host,current_category,current_size])
                current_size = None
                current_category = None
            current_host = possible_host
        else :
            cols = l.split()
            print(cols)
            if len(cols) < 6 :
                print('too short')
                pass
            elif cols[5] == 'disk' :
                # new disk
                print('disk')
                if current_size is not None :
                    csv_f.writerow([current_host,current_category,current_size])
                current_size = cols[3]
                current_category = None
            elif cols[5] == 'part' :
                print('partition')
                # deduce usage category for disk
                if len(cols) < 7 :
                    current_category = 'nomount'
                elif 'hadoop' in cols[6] :
                    current_category = 'hdfs'
                elif 'scratch' in cols[6] :
                    current_category = 'scratch'
                elif current_category is None :
                    current_category = cols[6]
    csv_f.writerow([current_host,current_category,current_size])
