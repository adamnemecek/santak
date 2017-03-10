#!/bin/bash

folder=../data/sheared_300_300
outdata=../data/300_300_vectorized/img_data.npy
outlabels=../data/300_300_vectorized/img_labels.npy

python img_to_vec.py --folder $folder --outdata $outdata --outlabels $outlabels
