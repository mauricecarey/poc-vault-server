install-consul-template:
  archive.extracted:
    - name: /usr/local/bin/
    - source: https://releases.hashicorp.com/consul-template/0.14.0/consul-template_0.14.0_linux_amd64.zip
    - source_hash: sha256=7c70ea5f230a70c809333e75fdcff2f6f1e838f29cfb872e1420a63cdf7f3a78
    - archive_format: zip
    - if_missing: /usr/local/bin/consul-template
  cmd.run:
    - name: /bin/chmod +x /usr/local/bin/consul-template
