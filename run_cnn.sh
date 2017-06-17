#!/bin/bash

script=cnn/run_cnn.py
data=data/100_square_greyscale/train_test.npz
save_loc=graphs/santak-01

python $script --data $data --save $save_loc
