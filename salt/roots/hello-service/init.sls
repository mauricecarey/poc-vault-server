include:
  - docker
  - dnsmasq

consul-dnsmasq-config:
  file.managed:
    - name: /etc/dnsmasq.d/consul.conf
    - source: salt://hello-service/files/dnsmasq-consul.conf
    - template: jinja
    - mode: 664
