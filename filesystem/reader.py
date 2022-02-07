"""Let's loop through a ROOT file."""

import ROOT

def read(fn,tn) :
    """Assumes all branches in tree can be summed together

    Parameters
    ----------
    fn : str
        name of root file to read
    tn : str
        name of tree to read
    """
    f = ROOT.TFile(fn)    
    t = f.Get(tn)

    branch_list = [ b.GetName() for b in t.GetListOfBranches() ]

    for e in t :
        # do something to force branches loaded into memory
        attrs = [getattr(e,b) for b in branch_list]

if __name__ == '__main__':
    import argparse, sys
    parser = argparse.ArgumentParser(f'ldmx python3 {sys.argv[0]}', description='Loop through a ROOT file.')
    parser.add_argument('input_file', help='an input file to loop over')
    parser.add_argument('--tree_name', required=True, help='tree to read')
    parser.add_argument('--trials', type=int, default=1, help='Number of reads on file to perform')
    arg = parser.parse_args()

    import timeit
    t = timeit.timeit(lambda: read(arg.input_file,arg.tree_name), number=arg.trials)
    print(t)
