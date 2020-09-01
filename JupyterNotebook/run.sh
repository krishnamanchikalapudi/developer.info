#!/bin/bash

. ./config.sh

pip3 install --upgrade jupyter jupyterlab nodebook pythonic pillow

jupyter notebook &

sleep 2
echo -e "***** STARTED Juypter notebook ***** \n "
