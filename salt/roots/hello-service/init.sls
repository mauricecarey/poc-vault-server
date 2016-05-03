{% set domain = salt['grains.get']('domain', '').replace('.','_') %}
{% set interfaces = salt['grains.get']('ip4_interfaces', {'eth1':['127.0.0.1']}) %}
{% set local_ip = interfaces['eth1'][0] %}
{% set consul_server_ip = '192.168.50.3' %}
include:
  - docker
  - consul-dnsmasq
  - consul-template

create-consul-data-directory:
  file.directory:
    - name: /opt/consul
    - user: root
    - group: root
    - dir_mode: 755
    - file_mode: 644
    - makedirs: True

create-consul-configuration:
  file.managed:
    - name: /etc/consul/consul.json
    - source: salt://hello-service/files/consul.json
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - makedirs: True

/etc/consul/consul_server_ip:
  file.managed:
    - contents:
      - {{ consul_server_ip }}
    - user: root
    - group: root
    - mode: 644
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

/etc/vault/salt_file:
  file.managed:
    - contents:
      - some random value
    - user: root
    - group: root
    - mode: 644
    - makedirs: True

consul-template-config:
  file.managed:
    - name: /consul-template/consul-template.cfg
    - source: salt://hello-service/files/consul-template.cfg
    - template: jinja
    - mode: 644
    - makedirs: True
    - defaults:
        local_ip: {{ local_ip }}
        vault_url: http://consul.service.consul:8200
        container_name: hello-world

docker-restart-script:
  file.managed:
    - name: /consul-template/docker-restart.sh
    - source: salt://hello-service/files/docker-restart.sh
    - mode: 755
    - makedirs: True

postgres-properties-template:
  file.managed:
    - name: /consul-template/postgres-properties.ctmpl
    - source: salt://hello-service/files/postgres-properties.ctmpl
    - mode: 644
    - makedirs: True

consul-template-start-script:
  file.managed:
    - name: /consul-template/start-consul-template.sh
    - source: salt://hello-service/files/start-consul-template.sh
    - template: jinja
    - mode: 755
    - makedirs: True
    - defaults:
        local_ip_file: /etc/consul/local_ip
        salt_file: /etc/vault/salt_file
        vault_url: http://consul.service.consul:8200
