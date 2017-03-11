#!/bin/bash

folder=../data/sheared_300_300
outdata=../data/100_square_greyscale/all_data.npz

python img_to_vec.py --folder $folder --outdata $outdata --dim 100
