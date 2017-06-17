#testing the CNN character classifier.

from argparse import ArgumentParser
import numpy as np
import character_classifier as cc
from sys import argv


def parse(args):
    parser = ArgumentParser()
    parser.add_argument("--data", help="npz data archive", required=True)
    parser.add_argument("--save", help="location of output graph structure", required=False, default=None)
    parser.add_argument("--load", help="location of output graph structure", required=False, default=None)
    return parser.parse_args(args)

def run(args):

    #load data
    print "loading {}".format(args.data)
    data_dict = np.load(args.data)

    classifier = cc.CharacterClassifier(data_dict, args.save, args.load)

    #training
    if args.save:
        classifier.train()
    
    classifier.test()

if __name__=="__main__":
    run(parse(argv[1:]))
