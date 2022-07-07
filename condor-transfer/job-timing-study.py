import htcondor
import classad
import csv
import argparse

parser = argparse.ArgumentParser(description = 'Get timing information for completed jobs in requested cluster')
parser.add_argument('cluster',type=int,help='cluster ID number to look at')
parser.add_argument('--output',default='timing-{cluster}.csv',help='output file with {cluster} replaced by cluster number')
arg = parser.parse_args()

items_of_interest = ['ClusterId','ProcId','ExitCode','TransferInputSizeMB','JobStartDate','TransferInStarted','TransferInFinished','TransferOutStarted','TransferOutFinished']
schedd = htcondor.Schedd()

with open(arg.output.format(cluster=arg.cluster),'w') as out_f :
    csv_f = csv.writer(out_f)
    csv_f.writerow(items_of_interest)
    for h in schedd.history(classad.Attribute('ClusterId') == arg.cluster,items_of_interest) :
        csv_f.writerow([h.get(k) for k in items_of_interest])
