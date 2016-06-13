./tools/test_kitti.py --gpu $1 \
    --def ./models/kitti/faster_rcnn_end2end/test.prototxt  \
    --net ./data/kitti_models/vgg16_faster_rcnn_iter_70000.caffemodel \
    --cfg ./experiments/cfgs/kitti.yml \
    --path $2
