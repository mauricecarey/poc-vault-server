{% set domain = salt['grains.get']('domain', '').replace('.','_') %}
{% set interfaces = salt['grains.get']('ip4_interfaces', {'eth1':['127.0.0.1']}) %}
{% set local_ip = interfaces['eth1'][0] %}
include:
  - docker
  - consul-dnsmasq

/opt/consul:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 755
    - file_mode: 644
    - makedirs: True

/etc/consul/domain:
  file.managed:
    - contents:
      - {{ domain }}
    - user: root
    - group: root
    - mode: 644
    - makedirs: True

/etc/consul/local_ip:
  file.managed:
    - contents:
      - {{ local_ip }}
    - user: root
    - group: root
    - mode: 644
    - makedirs: True

/vault/vault.hcl:
  file.managed:
    - source: salt://vault-server/files/vault.hcl
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - makedirs: True
    - defaults:
        local_ip: {{ local_ip }}

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
