./tools/test_kitti.py --gpu $1 \
    --def ./models/kitti/faster_rcnn_end2end/test.prototxt  \
    --net ./data/models/VGG16.v2.caffemodel \
#    --net ./output/vgg16_faster_rcnn_iter_30000.caffemodel \
    --cfg ./experiments/cfgs/kitti.yml \
    --path $2
