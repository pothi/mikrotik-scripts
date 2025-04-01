# Verify the connection at TODO

# disable doh (temporarily)
/ip dns set verify-doh-cert=no

:local result [/tool fetch url=https://i.pki.goog/r4.pem as-value]
:do { :delay 2s } while=( $result->"status" != "finished" )

/certificate remove [find name~"r4.pem"]
/certificate import file-name=r4.pem passphrase=""
# /file remove r4.pem

# Add static DNS entries for the DoH server
/ip dns static remove [find name=dns.google]
/ip dns static add address=8.8.8.8 name=dns.google
/ip dns static add address=8.8.4.4 name=dns.google

# let's enable DoH
/ip dns set use-doh-server=https://dns.google/dns-query verify-doh-cert=yes

# optional steps
# /ip dns set servers=""
# /ip dhcp-client set use-peer-dns=no [find]

# flush existing cache
/ip dns cache flush

# remove this file manually
# /file remove google.rsc
