from fast_rcnn.config import cfg
import numpy as np
import cv2
import caffe
import cPickle
from utils.blob import im_list_to_blob
import os
import random


class KittiDataLayer(caffe.Layer):
    def get_roidb(self):
        return self.roidb

    def filter_roidb(self):
        before = len(self.roidb)
        after_roidb = []
        for i in xrange(before):
            filename = self.roidb[i]
            label_file = self._kitti_dir + 'label/' + filename + '.txt'
            with open(label_file, 'r') as f:
                l = f.read()

            if not l.startswith('DontCare'):
                after_roidb.append(filename)

        self.roidb = after_roidb
        after = len(self.roidb)

        print "Filtered roidb: {}->{}".format(before, after)

    def _shuffle_roidb_inds(self):
        self._perm = np.random.permutation(np.arange(len(self.roidb)))
        self._cur = 0

    def _get_image_blob(self, im):
        im = im.astype(np.float32, copy=True)
        im -= cfg.PIXEL_MEANS

        processed_ims = []
        processed_ims.append(im)

        # Create a blob to hold the input images
        blob = im_list_to_blob(processed_ims)

        return blob

    def _get_roi_blob(self, rois):
        cls_labels = {'Car': 1, 'Truck': 2, 'Misc': 3, 'DontCare': -1}
        blob = np.zeros([len(rois), 5], dtype=np.float32)
        for i, roi in enumerate(rois):
            s = roi.split()
            if s[0] == 'DontCare' and cfg.TRAIN.IGNORE == False:
                continue
            blob[i, 4] = cls_labels[s[0]]
            blob[i, 0] = float(s[1])
            blob[i, 1] = float(s[2])
            blob[i, 2] = float(s[3])
            blob[i, 3] = float(s[4])

        gt_inds = np.where(blob[:, 4] != 0)[0]
        blob = blob[gt_inds, :]

        return blob


    def setup(self, bottom, top):
        self._kitti_dir = '/space3/mark/datasets/kitti/'
        image_list = os.listdir(self._kitti_dir + 'image/train/')

        self.roidb = []
        for name in image_list:
           if name.endswith('.png'):
               self.roidb.append(name.rstrip('.png'))

        self.filter_roidb()

        self._name_to_top_map = {}
        idx = 0
        top[idx].reshape(cfg.TRAIN.IMS_PER_BATCH, 3,
            max(cfg.TRAIN.SCALES), cfg.TRAIN.MAX_SIZE)
        self._name_to_top_map['data'] = idx
        idx += 1


        top[idx].reshape(1, 3)
        self._name_to_top_map['im_info'] = idx
        idx += 1

        top[idx].reshape(1, 4)
        self._name_to_top_map['gt_boxes'] = idx
        idx += 1

        print 'RoiDataLayer: name_to_top:', self._name_to_top_map
        # assert len(top) == len(self._name_to_top_map)

        self._shuffle_roidb_inds()

    def _get_next_minibatch_inds(self):
        """Return the roidb indices for the next minibatch."""
        if self._cur + 1 >= len(self.roidb):
            self._shuffle_roidb_inds()

        db_inds = self._perm[self._cur:self._cur + 1]
        self._cur += 1
        return db_inds

    def _get_next_minibatch(self):
        """Return the blobs to be used for the next minibatch.

        If cfg.TRAIN.USE_PREFETCH is True, then blobs will be computed in a
        separate process and made available through self._blob_queue.
        """
        ind = self._get_next_minibatch_inds()

        filename = self.roidb[ind]
        im_file = self._kitti_dir + 'image/train/' + filename + '.png'
        label_file = self._kitti_dir + 'label/' + filename + '.txt'

        # print 'filename: {}'.format(filename)

        im = cv2.imread(im_file)
        top_blobs = {}
        top_blobs['data'] = self._get_image_blob(im)

        im_shape = top_blobs['data'].shape;
        top_blobs['im_info'] = np.array(
            [[im_shape[2], im_shape[3], 1.0]])
        with open(label_file, 'r') as f:
            labels = f.readlines()
        top_blobs['gt_boxes'] = self._get_roi_blob(labels)

        if cfg.TRAIN.USE_FLIPPED and random.choice([True, False]):
            top_blobs['data'] = top_blobs['data'][:,:,:,::-1]
            top_blobs['gt_boxes'][:,[0,2]] = im_shape[3] - top_blobs['gt_boxes'][:,[2,0]]

        return top_blobs

    def forward(self, bottom, top):
        """Get blobs and copy them into this layer's top blob vector."""
        blobs = self._get_next_minibatch()

        for blob_name, blob in blobs.iteritems():
            top_ind = self._name_to_top_map[blob_name]
            # Reshape net's input blobs
            top[top_ind].reshape(*(blob.shape))
            # Copy data into net's input blobs
            top[top_ind].data[...] = blob.astype(np.float32, copy=False)

    def backward(self, top, propagate_down, bottom):
        """This layer does not propagate gradients."""
        pass

    def reshape(self, bottom, top):
        """Reshaping happens during the call to forward."""
        pass



