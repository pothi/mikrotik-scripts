# Verify the connection at TODO

# disable doh (temporarily)

/ip dns set verify-doh-cert=no

/tool fetch url=https://pki.goog/repo/certs/gtsr1.pem once
:delay 5s
/certificate remove [find name~"gtsr1.pem"]
/certificate import file-name=gtsr1.pem passphrase=""
/file remove gtsr1.pem

/ip dns static add address=8.8.8.8 name=dns.google
/ip dns static add address=8.8.4.4 name=dns.google
/ip dns set use-doh-server=https://dns.google/dns-query verify-doh-cert=yes

# optional steps
/ip dns set servers=""
/ip dhcp-client set use-peer-dns=no [find]

# flush existing cache
/ip dns cache flush
