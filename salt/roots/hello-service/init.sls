include:
  - docker
  - dnsmasq

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

consul-dnsmasq-config:
  file.managed:
    - name: /etc/dnsmasq.d/consul.conf
    - source: salt://hello-service/files/dnsmasq-consul.conf
    - template: jinja
    - mode: 664
