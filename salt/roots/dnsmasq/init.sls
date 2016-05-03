dnsmasq-config-dir:
  file.directory:
    - name: /etc/dnsmasq.d
    - mode: 755
    - makedirs: True

/etc/dnsmasq.d/default:
  file.managed:
    - source: salt://dnsmasq/files/default
    - template: jinja
    - require:
      - file: dnsmasq-config-dir

/etc/dnsmasq.conf:
  file.managed:
    - source: salt://dnsmasq/files/dnsmasq.conf
    - mode: 644
    - require:
      - pkg: dnsmasq

dnsmasq:
  pkg:
    - name: dnsmasq
    - installed
  service:
    - running
    - watch:
      - file: /etc/dnsmasq.d/*
      - file: /etc/dnsmasq.conf
    - require:
      - pkg: dnsmasq
