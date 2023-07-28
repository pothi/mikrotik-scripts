# Generic DoH script

# disable doh (temporarily)
/ip dns set verify-doh-cert=no

# curl.haxx.se/ca/cacert.pem contains all the certificates in the world - 100+
:local result [ /tool fetch url=https://curl.haxx.se/ca/cacert.pem as-value ];
:do { :delay 2s } while=( $result->"status" != "finished" )

/certificate remove [find name~"cacert.pem"]
/certificate import file-name=cacert.pem passphrase=""
/file remove cacert.pem

# you may use any DoH server
# https://dns.google/dns-query - see https://forum.mikrotik.com/viewtopic.php?f=2&t=160243#p787666
# https://dns.nextdns.io/xxxxxx - see https://my.nextdns.io/setup
# https://dns.quad9.net/dns-query - see https://www.quad9.net/news/blog/doh-with-quad9-dns-servers/

# let's use Cloudflare DoH
/ip dns set use-doh-server=https://1.1.1.1/dns-query verify-doh-cert=yes

# optional steps
/ip dns set servers=""
/ip dhcp-client set use-peer-dns=no [find]

# flush existing cache
/ip dns cache flush

# remove this file manually
# /file remove generic.rsc
