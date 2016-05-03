#!/bin/bash
# Before running this script create the file /etc/vault/salt_file and /etc/vault/base_subnet_file
# and initialize the vault configuration.
#
# salt_file contains the salt for hashing the app_id and user_ids.
# This should be the same on all nodes.
#
# base_subnet_file will contain a string based on the Subnet CIDR.
# For example if the CIDR is 10.20.0.0/24 then echo '10.20.0' > /etc/vault/base_subnet_file
# Note this currently only works for /24 subnets.

APP_NAME=$1
SALT=$(cat {{ salt_file }})
BASE_IP=$(cat {{ base_subnet_file }})

APP_ID=$(echo "${APP_NAME}-${SALT}" | shasum -a 256 | awk '{print $1}')

docker run -it -e VAULT_ADDR=${VAULT_ADDR} -e VAULT_TOKEN=${VAULT_TOKEN} --rm cgswong/vault \
  write auth/app-id/map/app-id/${APP_ID} value=root display_name=${APP_NAME}

for i in {1..253}; do
  USER_NAME="${BASE_IP}.${i}";
  USER_ID=$(echo "${USER_NAME}-${SALT}" | shasum -a 256 | awk '{print $1}');
  docker run -it -e VAULT_ADDR=${VAULT_ADDR} -e VAULT_TOKEN=${VAULT_TOKEN} --rm cgswong/vault \
    write auth/app-id/map/user-id/${USER_ID} value=${APP_ID};
done
