
### Contents
1. [Requirements](#requirements)
2. [Basic installation](#installation)
3. [Usage](#usage)
4. [**Results**](#results)
5. [Evaluation](#evaluation)
6. [GUI](#gui)

**If you have any questions with this repository, please feel free to contact me at zhucz13@mails.tsinghua.edu.cn**

### Requirements

1. Requirements for `Caffe` and `pycaffe` (see: [Caffe installation instructions](http://caffe.berkeleyvision.org/installation.html))

  **Note:** Caffe *must* be built with support for Python layers!

  ```make
  # In your Makefile.config, make sure to have this line uncommented
  WITH_PYTHON_LAYER := 1
  # Unrelatedly, it's also recommended that you use CUDNN
  USE_CUDNN := 1
  ```

2. Python packages you might not have: `cython`, `python-opencv`, `easydict`
3. [Optional] MATLAB is required for **official** PASCAL VOC evaluation only. The code now includes unofficial Python evaluation code.

### Installation

1. Clone the Kitti repository
  ```Shell
  # Make sure to clone with --recursive
  git clone --recursive https://github.com/czhu95/kitti.git
  cd kitti
  git checkout master
  ```

2. We'll call the directory that you cloned `KITTI_ROOT`

   *Ignore notes 1 and 2 if you followed step 1 above.*

   **Note 1:** If you didn't clone KITTI with the `--recursive` flag, then you'll need to manually clone the `caffe-fast-rcnn` submodule:
    ```Shell
    git submodule update --init --recursive
    ```
    **Note 2:** The `caffe-fast-rcnn` submodule needs to be on the `faster-rcnn` branch (or equivalent detached state). This will happen automatically *if you followed step 1 instructions*.

3. Build the Cython modules
    ```Shell
    cd $KITTI_ROOT/lib
    make
    ```

4. Build Caffe and pycaffe
    ```Shell
    cd $KITTI_ROOT/caffe-fast-rcnn
    # Now follow the Caffe installation instructions here:
    #   http://caffe.berkeleyvision.org/installation.html

    # If you're experienced with Caffe and have all of the requirements installed
    # and your Makefile.config in place, then simply do:
    make -j8 && make pycaffe
    ```

5. Download pre-computed Faster R-CNN detectors
    ```Shell
    cd $KITTI_ROOT
    ./data/scripts/fetch_faster_rcnn_models.sh
    ```

    Please download the pre-computed kitti model here:  
        http://pan.baidu.com/s/1dEZOXOl password: w8n4  
    And place the .caffenet model file under KITTI_ROOT/data/kitti_models/

6. Create symlinks for the kitti dataset (Not necessary if you wish only to run test)
    ```Shell
      cd $KITTI_ROOT/data
      ln -s $kitti kitti
      ```
    Please make sure the kitti dataset has this basic structure

    ```Shell
      $kitti/                         # kitti dataset
      $kitti/image                    # holds all the images
      $kitti/image/train              # training images
      #kitti/label                    # text annotations
      ``` 

### Usage

To train a kitti vehicle detector.

```Shell
cd $KITTI_ROOT
mkdir output
./experiments/scripts/train_kitti.sh [GPU_ID] 
# GPU_ID is the GPU you want to train on
```
Output will be in KITTI_ROOT/output/

To test a kitti vehicle detector.

```Shell
cd $KITTI_ROOT
mkdir results
./experiments/scripts/test_kitti.sh [GPU_ID] [TEST_DIR]
# GPU_ID is the GPU you want to train on
# TEST_DIR is the directory containing test images (default to data/kitti/image/test)
```
Output will be in TEST_DIR/label. If TEST_DIR is not specified, output will be stored at 
KITTI_ROOT/results/ 

### Results

We ran our detector on a test image set given by TA. If you wish to evaluate the results, please download here:  
    http://pan.baidu.com/s/1hsc0Fzu password: 4pny  
**Note:** These results do not include class specification. If you want the alternative, please re-run the test procedure as described above.

### Evaluation

We implemented matlab code to draw PR curve given test text files. Please refer to ./evaluation for codes and furthur instructions.  
**Note:** This implementation is for results with classifications.

### GUI

We wrote a matlab gui program to display detection results. Please refer to ./gui for
codes and furthur instructions.  
**Note:** This implementation is for results with classifications.