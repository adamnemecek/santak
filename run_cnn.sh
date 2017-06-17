#!/bin/bash

script=cnn/run_cnn.py
data=data/100_square_greyscale/train_test.npz
graph_loc=graphs/santak-01
load_loc=$graph_loc/santak-cnn


#python $script --data $data --save $save_loc

python $script --data $data --load $load_loc
