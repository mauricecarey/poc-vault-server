include:
  - docker
  - consul-dnsmasq

/etc/vault/salt_file:
  file.managed:
    - contents:
      - some random value
    - user: root
    - group: root
    - mode: 644
    - makedirs: True

/etc/vault/base_subnet_file:
  file.managed:
    - contents:
      - 172.28.128
    - user: root
    - group: root
    - mode: 644
    - makedirs: True

/vault/configure-vault-app-ids.sh:
  file.managed:
    - source: salt://vault-server/files/configure-vault-app-ids.sh
    - template: jinja
    - user: root
    - group: root
    - mode: 755
    - makedirs: True
    - defaults:
        salt_file: /etc/vault/salt_file
        base_subnet_file: /etc/vault/base_subnet_file

/vault/vault-initial-setup.sh:
  file.managed:
    - source: salt://vault-server/files/vault-initial-setup.sh
    - user: root
    - group: root
    - mode: 755
    - makedirs: True
