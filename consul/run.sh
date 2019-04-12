
# https://learn.hashicorp.com/consul/getting-started/agent

export WEB_ADDR='http://127.0.0.1:8500'

echo '\n -------- Starting consul -------- \n'

./consul  agent -dev -bootstrap-expect=1 -bind=127.0.0.1 -data-dir=consul-data -config-dir=consul-data -enable-script-checks=true &

sleep 10

echo '\n -------- consul members -------- \n'
consul members & 



sleep 5
open -a 'Google Chrome' $WEB_ADDR
