FROM nvidia/cuda:7.5-cudnn4-devel-ubuntu14.04
MAINTAINER caffe-maint@googlegroups.com

RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        cmake \
        git \
        wget \
        vim \
        libatlas-base-dev \
        libboost-all-dev \
        libgflags-dev \
        libgoogle-glog-dev \
        libhdf5-serial-dev \
        libleveldb-dev \
        liblmdb-dev \
        libopencv-dev \
        libprotobuf-dev \
        libsnappy-dev \
        python-opencv \
        protobuf-compiler \
        python-dev \
        python-numpy \
        python-pip \
        python-skimage \
        python-scipy \
        curl

RUN pip install cython easydict

ENV CAFFE_ROOT=/opt/caffe
WORKDIR $CAFFE_ROOT

# FIXME: clone a specific git tag and use ARG instead of ENV once DockerHub supports this.
ENV CLONE_TAG=master

RUN git clone -b ${CLONE_TAG} --recursive https://github.com/tianchenwang/kitti.git . && \
     for req in $(cat caffe-fast-rcnn/python/requirements.txt) pydot; do pip install $req; done

WORKDIR $CAFFE_ROOT/lib
RUN make

WORKDIR $CAFFE_ROOT/caffe-fast-rcnn
#     mkdir build && cd build && \
#     cmake -DUSE_CUDNN=1 .. && \
RUN cp ../Makefile.config ./
RUN make -j"$(nproc)" && make pycaffe

ENV PYCAFFE_ROOT $CAFFE_ROOT/caffe-fast-rcnn/python
ENV PYTHONPATH $PYCAFFE_ROOT:$PYTHONPATH
ENV PATH $CAFFE_ROOT/caffe-fast-rcnn/build/tools:$PYCAFFE_ROOT:$PATH
RUN echo "$CAFFE_ROOT/caffe-fast-rcnn/build/lib" >> /etc/ld.so.conf.d/caffe.conf && ldconfig

WORKDIR /workspace
