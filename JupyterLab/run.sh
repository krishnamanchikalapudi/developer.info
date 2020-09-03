#!/bin/bash

. ./config.sh

pip3 install --upgrade jupyter jupyterlab notebook pythonic pillow jupyterlab-git jupyterlab-github jupyterlab-widgets jupyterlab-hdf jupyterlab-autoversion  jupyterlab-scheduler

# jupyter lab build

jupyter lab --notebook-dir=${WORKSPACE} &


sleep 2
echo -e "***** STARTED Juypter notebook ***** \n "
