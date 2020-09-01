#!/bin/sh
clear
DATE_TIME=`date '+%Y-%m-%d %H:%M:%S'`
CURRENT_PATH=`pwd`
WORKSPACE="${CURRENT_PATH}/workspace"

printf "\n\n ************************************************************* \n"
printf " ********** JUPYTER ********** "
printf "\n ************************************************************* \n\n"


PY_HOME=/Library/Frameworks/Python.framework/Versions/3.8/bin
PIP_HOME=$PY_HOME/


R_HOME=/Library/Frameworks/R.framework/Resources/bin

export PATH=$PY_HOME:$R_HOME:$PATH

PY_VER=`python3 -V`
PIP_VER=`pip3 -V`
IPYTHON_VER=`IPython -V`
JUPYTER_VER=`jupyter --version`
R_VER=`R --version| grep -Eo 'R version [0-9.]+ \([0-9]{4}-[0-9]{2}-[0-9]{2}\)';`

# upgrade pip
# pip3 install --upgrade pip

printf "\n *************************************************************"
printf "\n        ********** Software Versions ********** "
printf "\n%s\n%s" " Python Version: ${PY_VER} " " PIP Version: ${PIP_VER} "
printf "\n%s\n%s\n" " IPython Version: ${IPYTHON_VER} " " ${JUPYTER_VER}"
printf "\n%s" " ${R_VER} "
printf "\n ************************************************************* \n\n"

mkdir -p $WORKSPACE
