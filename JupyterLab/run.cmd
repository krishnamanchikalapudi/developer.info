set WORKSPACE="/workspace"

mkdir -p %WORKSPACE%


pip install --upgrade jupyterlab


jupyter-lab --notebook-dir=%WORKSPACE% &


sleep 2
echo -e "***** STARTED Juypter notebook ***** \n "
