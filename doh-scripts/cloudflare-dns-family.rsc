# Verify the connection at https://1.1.1.1/help

# cloudflare-dns.com is the default DNS server (at least as of May 2025), in place of (still working) 1.1.1.1 and one.one.one.one.
# family.cloudflare-dns.com blocks malware and adult content.
# ref: https://developers.cloudflare.com/1.1.1.1/setup/#dns-over-https-doh

# disable doh (temporarily)
/ip dns set verify-doh-cert=no

# since RouterOS v7.19...
/certificate/settings/set builtin-trust-anchors=trusted

# Add static DNS entries for the DoH server
/ip dns static remove [find name=family.cloudflare-dns.com]
# use the following two entries if IPv6 is available on your internet
# /ip dns static add address=2606:4700:4700::1113 name=family.cloudflare-dns.com comment="DoH"
# /ip dns static add address=2606:4700:4700::1003 name=family.cloudflare-dns.com comment="DoH"
/ip dns static add address=1.1.1.3 name=family.cloudflare-dns.com comment="DoH"
/ip dns static add address=1.0.0.3 name=family.cloudflare-dns.com comment="DoH"

/ip dns set use-doh-server=https://family.cloudflare-dns.com/dns-query verify-doh-cert=yes

# optional steps
# use the following if IPv6 is available on your internet
# /ip dns set servers="2606:4700:4700::1113,2606:4700:4700::1003,1.1.1.3,1.0.0.3"
/ip dns set servers="1.1.1.3,1.0.0.3"
/ip dhcp-client set use-peer-dns=no [find]

# flush existing cache
/ip dns cache flush
