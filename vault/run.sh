# 

#export VAULT_DEV_ROOT_TOKEN_ID=s.2BTYTVtKXj5cDsILkFk81ht4
#export VAULT_DEV_UNSEAL_KEY=zUq7u9BaI4MAZrzLN1srbSu+axusSYvpnI9j59YmsJA=
#export VAULT_API_ADDR=

echo '\n -------- Starting vault -------- \n'

vault server -dev &
#./vault server -config vault.conf &

sleep 10
export WEB_ADDR=http://127.0.0.1:8200
echo '\n -------- vault status -------- \n'
vault status & 

sleep 5
echo '\n\n -------- vault pid -------- \n'
lsof -nP -iTCP:8200


# Writing a Secret
# vault kv put secret/springbootvault user=HelloName password=HelloPassword
# Getting a Secret
# vault kv get secret/springbootvault

sleep 5
open -a 'Google Chrome' $WEB_ADDR


