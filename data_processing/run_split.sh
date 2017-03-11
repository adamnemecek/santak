#!/bin/bash

datafolder=../data/100_square_greyscale

python train_test_split.py --data $datafolder/all_data.npz --pct_test 0.2 --outfile $datafolder/train_test.npz
