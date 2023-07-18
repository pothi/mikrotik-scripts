# TODO: Verify the connection if possible
# Ref: https://www.quad9.net/news/blog/doh-with-quad9-dns-servers/

# disable doh (temporarily)

/ip dns set verify-doh-cert=no

# Quad9 uses DigiCert like CloudFlare.
:local result [ /tool fetch url=https://cacerts.digicert.com/DigiCertGlobalRootCA.crt.pem dst-path=ssl.pem as-value ];
:do { :delay 2s } while=( $result->"status" != "finished" )

/certificate remove [find]
/certificate import file-name=ssl.pem passphrase=""
/file remove ssl.pem

/ip dns
    static remove [find name="dns.quad9.net"]
    static add address=9.9.9.9          name=dns.quad9.net comment="Quad9 IPv4"
    static add address=149.112.112.112  name=dns.quad9.net comment="Quad9 IPv4 - secondary"
    static add address=2620:fe::9       name=dns.quad9.net comment="Quad9 IPv6"
    static add address=2620:fe::fe      name=dns.quad9.net comment="Quad9 IPv6 - secondary"

    set use-doh-server=https://dns.quad9.net/dns-query verify-doh-cert=yes

# optional steps
/ip dns set servers="2620:fe::9,9.9.9.9"
/ip dhcp-client set use-peer-dns=no [find]

# flush existing cache
/ip dns cache flush

# Post-install step: remove this file manually
# /file remove quad9.rsc
