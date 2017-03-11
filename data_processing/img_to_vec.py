#convering images to vectors, saving as .npy file

import numpy as np
from argparse import ArgumentParser
from skimage import io, transform, color
from sys import argv
from os import listdir, path

def parse(args):
    parser = ArgumentParser()
    parser.add_argument("--folder", help="Folder where square images are stored")
    parser.add_argument("--outdata", help="folder for compressed .npz archive")
    parser.add_argument("--dim", help="desired output dimension of square images, will resize if different from input", type=int)
    return parser.parse_args(args)

def run(args):
    #iterate through all images, reshape, add to array

    label_list = [] #convert char number to label number
    #preallocating output arrays:

    imgs = [img for img in listdir(args.folder) if path.splitext(img)[1] == ".jpeg"]

    img_vecs = np.zeros((len(imgs), args.dim, args.dim), dtype=np.int32)
    img_labels = np.zeros((len(imgs),), dtype=np.int32)
    print "loading {} images".format(len(imgs))

    for i, img in enumerate(imgs):

        label = img.split()[0]

        if label not in label_list:
            label_list.append(label)
        #load image, convert to greyscale, resize to output dim
        img_arr = io.imread("{}/{}".format(args.folder, img))
        processed = transform.resize(color.rgb2grey(img_arr), (args.dim, args.dim))

        img_vecs[i,:, :] = processed
        img_labels[i] = label_list.index(label)



    #saving
    print "saving data to {}".format(args.outdata)
    np.savez_compressed(args.outdata, data=img_vecs, labels=img_labels)










if __name__=="__main__":
    run(parse(argv[1:]))
