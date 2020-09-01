#!/bin/sh
clear
DATE_TIME=`date '+%Y-%m-%d %H:%M:%S'`
CURRENT_PATH=`pwd`

echo -e '\n\n ************************************************************* \n'
echo -e " ********** JUPYTER **********\n "
echo -e '\n ************************************************************* \n\n'


PY_HOME=/Library/Frameworks/Python.framework/Versions/3.8/bin
PIP_HOME=$PY_HOME/

R_HOME=/Library/Frameworks/R.framework/Resources/bin

export PATH=$PY_HOME:$R_HOME:$PATH

PY_VER=`python3 -V`
PIP_VER=`pip3 -V`
R_VER=`R --version| grep -Eo 'R version [0-9.]+ \([0-9]{4}-[0-9]{2}-[0-9]{2}\)';`

# upgrade pip
# pip3 install --upgrade pip

printf "\n%s\n%s\n" " Python Version: ${PY_VER} " " PIP Version: ${PIP_VER} "
printf "\n%s\n" " ${R_VER} "
