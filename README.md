# A PoC for Vault
This project demonstrates a proof-of-concept for using Vault to distribute dynamically generated secrets to services. For more information on the motivation, problem space, etc. check out [my blog on the subject](http://www.mauricecarey.com/2016/05/03/distributing-secrets/).

## Prerequisites
To run this project you'll need Git, Vagrant, and Virtualbox installed on your system.

## Getting Started

1. Clone the project:

        git clone --recursive https://github.com/mauricecarey/poc-vault-server.git

2. Open a new terminal and execute the following to start the vault and database machines, and begin initial configuration:

        vagrant up vault db
        vagrant ssh vault
        alias vault='docker run -it -e VAULT_ADDR=${VAULT_ADDR} -e VAULT_TOKEN=${VAULT_TOKEN} --rm cgswong/vault'
        export VAULT_ADDR="http://192.168.50.3:8200"
        vault init
        export VAULT_TOKEN='the root token generated in previous command'

3. Next we unseal Vault, you'll want to keep track of the unseal keys generated in the last step for at least as long as you want to play with this environment. To unseal use the following command with as many keys as required (3 by default):

        vault unseal

4. To finish the Vault initialization for this PoC run the following two scripts:

        /vault/vault-initial-setup.sh
        /vault/configure-vault-app-ids.sh hello

5. In a new terminal window execute the following:

        vagrant up service
        vagrant ssh service
        export VAULT_ADDR="http://consul.service.consul:8200"
        sudo -E /consul-template/start-consul-template.sh hello

    The last command can be moved to the background once you've verified it is executing correctly, or you can simply kill the process if you are not interested in seeing updates to the Vault generated credentials.

6. Next we start our hello world service:

        docker run -d -p 8080:8080 --dns=$(dig +short consul.service.consul) \
          -v /consul-template/postgres.properties:/app/config/application.properties \
          --name hello-world mmcarey/microservice-hello-world

7. Finally we can test that everything is working correctly (it is if the get a 200 response):

        curl -i http://microservice-hello-world.service.consul:8080/health

## Digging In
To see what is happening here it is best to read the scripts used in each step of the process above. It is easiest to view the scripts in the running environment after SaltStack has done it's magic.
