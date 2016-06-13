#!/bin/bash
set -x
set -e
time ./tools/train_kitti.py --gpu 0 \
    --solver models/kitti/raw/solver.prototxt \
    --iters 70000 \
    --weights data/imagenet_models/VGG16.v2.caffemodel \
    --cfg experiments/cfgs/raw.yml
