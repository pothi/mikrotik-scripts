# Verify the connection at https://1.1.1.1/help

# cloudflare-dns.com is the default DNS server (at least as of May 2025), in place of (still working) 1.1.1.1 and one.one.one.one.

# disable doh (temporarily)

/ip dns set verify-doh-cert=no

# update the caCertURL depending on what's used at https://1.1.1.1/dns-query

:local caCertURL https://cacerts.digicert.com/DigiCertGlobalRootG2.crt.pem

:local result [ /tool fetch url=$caCertURL dst-path=cert.pem as-value ];
:do { :delay 2s } while=( $result->"status" != "finished" )

/certificate remove [find name~"cert.pem"]
/certificate import file-name=cert.pem passphrase=""
# no longer needed for RouterOS v7
# /file remove cert.pem

# since RouterOS v7.19...
# /certificate/settings/set builtin-trust-anchors=trusted

# Add static DNS entries for the DoH server
/ip dns static remove [find name=cloudflare-dns.com]
# use the following two entries if IPv6 is available on your internet
# /ip dns static add address=2606:4700::6810:f8f9 name=cloudflare-dns.com comment="DoH"
# /ip dns static add address=2606:4700::6810:f9f9 name=cloudflare-dns.com comment="DoH"
/ip dns static add address=104.16.248.249 name=cloudflare-dns.com comment="DoH"
/ip dns static add address=104.16.249.249 name=cloudflare-dns.com comment="DoH"

/ip dns set use-doh-server=https://cloudflare-dns.com/dns-query verify-doh-cert=yes

# optional steps
# use the following if IPv6 is available on your internet
# /ip dns set servers="2606:4700:4700::1111,2606:4700:4700::1001,1.1.1.1,1.0.0.1"
/ip dns set servers="1.1.1.1,1.0.0.1"
/ip dhcp-client set use-peer-dns=no [find]

# flush existing cache
/ip dns cache flush
