#!/bin/bash
# this script should be run after Vault is initialized and unsealed, but before vault is used by
# the hello app or initialized with app-id and user-ids.

docker run -it -e VAULT_ADDR=${VAULT_ADDR} -e VAULT_TOKEN=${VAULT_TOKEN} --rm cgswong/vault auth-enable app-id
docker run -it -e VAULT_ADDR=${VAULT_ADDR} -e VAULT_TOKEN=${VAULT_TOKEN} --rm cgswong/vault mount -path=hello-db postgresql
docker run -it -e VAULT_ADDR=${VAULT_ADDR} -e VAULT_TOKEN=${VAULT_TOKEN} --rm cgswong/vault write hello-db/config/connection \
    connection_url="postgresql://vault:Passw0rd@postgres.service.consul:5432/hello?sslmode=disable"
docker run -it -e VAULT_ADDR=${VAULT_ADDR} -e VAULT_TOKEN=${VAULT_TOKEN} --rm cgswong/vault write hello-db/roles/readwrite \
    sql="CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}';
    GRANT SELECT, UPDATE, INSERT ON ALL TABLES IN SCHEMA public TO \"{{name}}\";"
