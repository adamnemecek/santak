#convering images to vectors, saving as .npy file

import numpy as np
from argparse import ArgumentParser
from skimage import io
from sys import argv
from os import listdir, path

def parse(args):
    parser = ArgumentParser()
    parser.add_argument("--folder", help="Folder where images are stored")
    parser.add_argument("--outdata", help="folder for output .npy file containing data")
    parser.add_argument("--outlabels", help="folder for output .npy file containing labels")
    return parser.parse_args(args)

def run(args):
    #iterate through all images, reshape, add to array

    imgs = []
    labels = [] #convert char number to label number
    for img in listdir(args.folder):
        filename, ext = path.splitext(img)
        if ext == ".jpeg":
            #split name
            char_num = filename.split("_")[0]

            if char_num not in labels:
                labels.append(char_num)
            print "loading {}".format(img)
            img = io.imread("{}/{}".format(args.folder, img))
            imgs.append(img.flatten())
            labels.append(labels.index(char_num))

    final_imgs = np.stack(imgs)
    final_labels = np.array(labels)

    np.save(args.outdata, final_imgs)
    print "saved to {}".format(args.outdata)
    np.save(args.outdata, final_labels)
    print "saved to {}".format(args.outlabels)

if __name__=="__main__":
    run(parse(argv[1:]))
