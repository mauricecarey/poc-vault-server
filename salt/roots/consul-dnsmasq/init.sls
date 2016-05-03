include:
  - dnsmasq

consul-dnsmasq-config:
  file.managed:
    - name: /etc/dnsmasq.d/consul.conf
    - source: salt://consul-dnsmasq/files/dnsmasq-consul.conf
    - template: jinja
    - mode: 664
