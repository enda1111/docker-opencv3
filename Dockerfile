FROM python:3.6.3-alpine3.6

RUN echo http://dl-cdn.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories && \
    echo http://dl-cdn.alpinelinux.org/alpine/edge/community >> /etc/apk/repositories

RUN apk add --update --no-cache --virtual .build-deps \
    	build-base \
	clang \
	clang-dev \
	cmake \
	git \
	wget \
	unzip

RUN apk add --update --no-cache \
    	libtbb \
	libtbb-dev \
	libjpeg \
	libjpeg-turbo-dev \
	libpng-dev \
	jasper-dev \
	tiff-dev \
	libwebp-dev \
	clang-dev \
	linux-headers

RUN pip install numpy wheel

ENV CC /usr/bin/clang
ENV CXX /usr/bin/clang++

ENV SRC_DIR /tmp
ENV OPENCV_VERSION 3.3.0

RUN mkdir -p ${SRC_DIR} && \
    cd ${SRC_DIR} && \
    wget https://github.com/opencv/opencv/archive/${OPENCV_VERSION}.zip && \
    unzip ${OPENCV_VERSION}.zip && \
    rm ${OPENCV_VERSION}.zip && \
    mv opencv-${OPENCV_VERSION} opencv && \
    wget https://github.com/opencv/opencv_contrib/archive/${OPENCV_VERSION}.zip && \
    unzip ${OPENCV_VERSION}.zip && \
    rm ${OPENCV_VERSION}.zip && \
    mv opencv_contrib-${OPENCV_VERSION} opencv_contrib && \
    mkdir -p ${SRC_DIR}/opencv/build && \
    cd ${SRC_DIR}/opencv/build && \
    cmake \
	-D CMAKE_BUILD_TYPE=RELEASE \
	-D CMAKE_INSTALL_PREFIX=/usr/local \
	-D WITH_FFMPEG=NO \
	-D WITH_IPP=NO \
	-D WITH_OPENEXR=NO \
	-D WITH_TBB=YES \
	-D BUILD_EXAMPLES=NO \
	-D BUILD_ANDROID_EXAMPLES=NO \
	-D INSTALL_PYTHON_EXAMPLES=NO \
	-D BUILD_DOCS=OFF \
	-D BUILD_opencv_python2=NO \
	-D BUILD_opencv_python3=ON \
	-D PYTHON3_EXECUTABLE=/usr/local/bin/python \
	-D PYTHON3_INCLUDE_DIR=/usr/local/include/python3.6m/ \
	-D PYTHON3_LIBRARY=/usr/local/lib/libpython3.so \
	-D PYTHON_LIBRARY=/usr/local/lib/libpython3.so \
	-D PYTHON3_PACKAGES_PATH=/usr/local/lib/python3.6/site-packages/ \
	-D PYTHON3_NUMPY_INCLUDE_DIRS=/usr/local/lib/python3.6/site-packages/numpy/core/include/ \
        -D OPENCV_EXTRA_MODULES_PATH=../../opencv_contrib/modules/ \
	.. && \
    make -j4 && \
    make install && \
    cd ~ && \
    rm -rf ${SRC_DIR} && \
    apk del --purge .build-deps
