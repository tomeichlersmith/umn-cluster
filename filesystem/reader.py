"""Let's loop through a ROOT file."""

import ROOT
import os
import argparse
import sys
import timeit
import json

def analysim(cli_args) :
    """simulate an analysis that loads all branches

    Parameters
    ----------
    cli_args : Namespace
        Namespace as returned by ArgumentParser.parse_args
    """
    input_file = cli_args.input_file
    if cli_args.cp_to_local :
        # do copy
        input_file = f'{cli_args.scratch_dir}/{os.path.basename(cli_args.input_file)}'
        rc = os.system(f'cp {cli_args.input_file} {input_file}')
        if rc != 0 :
            sys.exit(rc)
            

    f = ROOT.TFile(input_file)
    t = f.Get(cli_args.tree_name)

    branch_list = [ b.GetName() for b in t.GetListOfBranches() ]

    for e in t :
        # do something to force branches loaded into memory
        attrs = [getattr(e,b) for b in branch_list]
        # slow down reading with some dummy calculations?

if __name__ == '__main__':
    parser = argparse.ArgumentParser(f'ldmx python3 {sys.argv[0]}', description='Loop through a ROOT file.')
    parser.add_argument('input_file', help='an input file to loop over')
    parser.add_argument('--tree_name', required=True, help='tree to read')
    parser.add_argument('--cp_to_local', action='store_true', help='copy file to local scratch space')
    parser.add_argument('--scratch_dir', default='/export/scratch/users/eichl008', help='scratch space')

    parser.add_argument('--trials', type=int, default=1, help='Number of reads on file to perform')
    arg = parser.parse_args()

    s = os.path.getsize(arg.input_file)
    t = timeit.timeit(lambda: analysim(arg), number=arg.trials)
    l = arg.cp_to_local

    results = json.dumps({'size' : s, 'time' : t, 'local' : l})
    print(results)
