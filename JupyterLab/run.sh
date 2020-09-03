#!/bin/bash

. ./config.sh

pip3 install --upgrade jupyterlab notebook pythonic pillow jupyterlab-git jupyterlab_github jupyterlab-debugger jupyterlab_hdf dataregistry-extension

# serverextension enable --py jupyterlab --sys-prefix

jupyter lab --notebook-dir=${WORKSPACE} &


sleep 2
echo -e "***** STARTED Juypter notebook ***** \n "
