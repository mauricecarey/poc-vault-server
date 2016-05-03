#!/bin/bash

APP_NAME=$1
SALT=$(cat {{ salt_file }})
USER_NAME=$(cat {{ local_ip_file }})
VAULT_ADDR={{ vault_url }}
APP_ID=$(echo "${APP_NAME}-${SALT}" | shasum -a 256 | awk '{print $1}')
echo "App ID: ${APP_ID}"
USER_ID=$(echo "${USER_NAME}-${SALT}" | shasum -a 256 | awk '{print $1}')
echo "User ID: ${USER_ID}"
JSON_RESPONSE=$(curl -X POST -d "{\"app_id\": \"${APP_ID}\", \"user_id\": \"${USER_ID}\"}" "${VAULT_ADDR}/v1/auth/app-id/login")
echo "JSON Response from Vault: ${JSON_RESPONSE}"
export VAULT_TOKEN=$(echo ${JSON_RESPONSE} | python -c 'import json,sys;obj=json.load(sys.stdin);print obj["auth"]["client_token"]')
echo "Using token: ${VAULT_TOKEN}"
consul-template -config /consul-template/consul-template.cfg
