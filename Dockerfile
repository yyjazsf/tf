FROM tensorflow/tensorflow:nightly-py3-jupyter

RUN mkdir /lab
WORKDIR /lab

# ENV DEBIAN_FRONTEND=noninteractive 
COPY sources.list /etc/apt/sources.list
COPY zoneinfo/PRC /usr/share/zoneinfo/PRC
COPY models.zip /lab

ENV TZ=Asia/Shanghai
RUN mkdir -p /usr/share/zoneinfo/Asia \
     && ln -snf /usr/share/zoneinfo/PRC /usr/share/zoneinfo/$TZ \
     && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
     && echo $TZ > /etc/timezone

RUN  pip install pip -U \
     && pip config set global.index-url https://mirrors.aliyun.com/pypi/simple/

RUN  apt-get update
RUN apt-get install -y apt-utils \
     && apt-get install -y \
     git \
     wget \
     unzip \
     protobuf-compiler \
     python-pil \
     python-lxml python-tk \
     cmake \ 
     && pip install tensorflow \
     && pip install Cython contextlib2 matplotlib pillow lxml

# RUN wget -O protobuf.zip https://github.com/google/protobuf/releases/download/v3.0.0/protoc-3.0.0-linux-x86_64.zip \
#     unzip protobuf.zip \
#     cd protobuf 

RUN  cd /lab \
     && wget -q -P /lab --no-check-certificate https://github.com/cocodataset/cocoapi/archive/master.zip \
     && unzip master.zip -d /lab \
     && mv cocoapi-master cocoapi \
     && unzip models.zip -d /usr/local/lib/python3.6/dist-packages/tensorflow/ \
     && rm -fr master.zip models.zip \
     && cd /lab/cocoapi/PythonAPI \
     && make
RUN cd /usr/local/lib/python3.6/dist-packages/tensorflow/models \
     mkdir -p research/pycocotools \
     && cp -r /lab/cocoapi/PythonAPI/pycocotools research/pycocotools \
     && cd research \
     && wget -O protobuf.zip https://github.com/google/protobuf/releases/download/v3.0.0/protoc-3.0.0-linux-x86_64.zip \
     && unzip protobuf.zip \
     && rm -fr protobuf.zip \
     && ./bin/protoc object_detection/protos/*.proto --python_out=.

RUN (apt-get autoremove -y; \
     apt-get autoclean -y)

RUN ln -s /usr/local/lib/python3.6/dist-packages/tensorflow/models /tf/tensorflow-models

ENV PYTHONPATH "$PYTHONPATH:/usr/local/lib/python3.6/dist-packages/tensorflow/models/research:/usr/local/lib/python3.6/dist-packages/tensorflow/models/research/slim"
