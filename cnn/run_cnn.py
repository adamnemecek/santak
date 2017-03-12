#testing the CNN character classifier.

from argparse import ArgumentParser
import numpy as np
import character_classifier as cc
from sys import argv


def parse(args):
    parser = ArgumentParser()
    parser.add_argument("--data", help="npz data archive")
    return parser.parse_args(args)

def run(args):

    #load data
    print "loading {}".format(args.data)
    data_dict = np.load(args.data)

    classifier = cc.CharacterClassifier(data_dict)

    #training
    classifier.train()
    classifier.test()

if __name__=="__main__":
    run(parse(argv[1:]))
