
# download software https://github.com/minishift/minishift/releases/latest
# install instructions https://docs.okd.io/latest/minishift/getting-started/quickstart.html 



echo '\n\n -------- minishift start -------- \n'
minishift start &

sleep 10

echo '\n\n -------- minishift oc-env -------- \n'
minishift oc-env export PATH="~/TOOLS/minishift-1.29.0/cache/oc/v1.5.0:$PATH" &

echo '\n\n -------- minishift pid -------- \n'
ps -ef | grep minishift | awk '{print $3}'

