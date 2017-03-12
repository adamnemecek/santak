#producing train/test split from data

import numpy as np
from argparse import ArgumentParser
from sys import argv

def parse(args):
    parser = ArgumentParser()
    parser.add_argument("--data", help=".npz file with data and labels")
    parser.add_argument("--pct_test", help="testing percentage", type=float)
    parser.add_argument("--outfile", help="folder for output")
    return parser.parse_args(args)


def run(args):
    #load files

    print "loading {}".format(args.data)
    data = np.load(args.data) #n_data x img_dim x img_dim

    #produce permutation of indices (to keep data/label alignment)

    num_data = data['labels'].shape[0]
    inds = np.random.permutation(num_data)

    permuted_data = data['data'][inds,:,:]
    permuted_labels = data['labels'][inds]

    test_max = int(num_data*args.pct_test)

    #get training and test split
    test_data = permuted_data[0:test_max, :, :]
    test_labels = permuted_labels[0:test_max]

    train_data = permuted_data[test_max:, :, :]
    train_labels = permuted_labels[test_max:]

    #saving

    print "saving train/test split to {}".format(args.outfile)
    np.savez_compressed(args.outfile, train_data=train_data, train_labels=train_labels, test_data=test_data, test_labels=test_labels, num_test=test_max)




if __name__=="__main__":
    run(parse(argv[1:]))
