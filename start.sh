#!/usr/bin/bash

git clone https://github.com/tensorflow/models.git
zip -r models.zip models

docker build -t tf .
