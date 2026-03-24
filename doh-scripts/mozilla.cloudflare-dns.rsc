# Ref: https://forum.mikrotik.com/t/267846/
# Verify the connection at https://1.1.1.1/help

# cloudflare-dns.com is the default DNS server (at least as of May 2025), in place of (still working) 1.1.1.1 and one.one.one.one.

# disable doh (temporarily)
/ip dns set verify-doh-cert=no

# update the caCertURL depending on what's used at https://mozilla.cloudflare-dns.com/dns-query
:local caCertURL https://ssl.com/repo/certs/SSLcomRootCertificationAuthorityECC.pem

:local result [ /tool fetch url=$caCertURL dst-path=cert.pem as-value ];
:do { :delay 2s } while=( $result->"status" != "finished" )

/certificate remove [find name~"cert.pem"]
/certificate import file-name=cert.pem passphrase=""
# no longer needed for RouterOS v7
# /file remove cert.pem

# since RouterOS v7.19...
# NOT in builtin trust store.
# /certificate/settings/set builtin-trust-store=all

# Add static DNS entries for the DoH server
/ip dns static remove [find name=mozilla.cloudflare-dns.com]
# use the following two entries if IPv6 is available on your internet
/ip dns static add address=2803:f800:53::4 name=mozilla.cloudflare-dns.com comment="DoH"
/ip dns static add address=2a06:98c1:52::4 name=mozilla.cloudflare-dns.com comment="DoH"
/ip dns static add address=162.159.61.4 name=mozilla.cloudflare-dns.com comment="DoH"
/ip dns static add address=172.64.41.4 name=mozilla.cloudflare-dns.com comment="DoH"

/ip dns set use-doh-server=https://mozilla.cloudflare-dns.com/dns-query verify-doh-cert=yes

# optional steps
# use the following if IPv6 is available on your internet
# /ip dns set servers="2606:4700:4700::1111,2606:4700:4700::1001,1.1.1.1,1.0.0.1"
/ip dns set servers="1.1.1.1,1.0.0.1"
/ip dhcp-client set use-peer-dns=no [find]

# flush existing cache
/ip dns cache flush
