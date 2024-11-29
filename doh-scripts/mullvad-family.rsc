# Mullvad requires HTTP2 that is not supported by MikroTik, yet!




# TODO: Verify the connection if possible
# Ref: https://mullvad.net/en/help/dns-over-https-and-dns-over-tls

# disable doh (temporarily)

/ip dns set verify-doh-cert=no

# Mullvad uses LetsEncrypt certs that in turn uses ISRG Root X1 as of Nov 2024
:local result [ /tool fetch url=https://letsencrypt.org/certs/isrgrootx1.pem dst-path=mullvad-x1.pem as-value ];
:do { :delay 2s } while=( $result->"status" != "finished" )
# Let's prepare for the transition (to ISRG Root X2), though; ref: https://letsencrypt.org/certificates/
:local result [ /tool fetch url=https://letsencrypt.org/certs/isrg-root-x2.pem dst-path=mullvad-x2.pem as-value ];
:do { :delay 2s } while=( $result->"status" != "finished" )

/certificate remove [find name~"mullvad-x1.pem"]
/certificate remove [find name~"mullvad-x2.pem"]
/certificate import file-name=mullvad-x1.pem passphrase=""
/certificate import file-name=mullvad-x2.pem passphrase=""
/file remove mullvad-x1.pem
/file remove mullvad-x2.pem

/ip dns
    static remove [find name="family.dns.mullvad.net"]
    static add name=family.dns.mullvad.net address=194.242.2.6          comment="mullvad IPv4"
    # static add name=family.dns.mullvad.net address=149.112.112.112  comment="mullvad IPv4 - secondary"
    static add name=family.dns.mullvad.net address=2a07:e340::6       comment="mullvad IPv6"
    # static add name=family.dns.mullvad.net address=2620:fe::fe      comment="mullvad IPv6 - secondary"

    set use-doh-server=https://family.dns.mullvad.net/dns-query verify-doh-cert=yes

# optional steps
/ip dns set servers="2a07:e340::6,194.242.2.6"
/ip dhcp-client set use-peer-dns=no [find]

# flush existing cache
/ip dns cache flush

# Post-install step: remove this file manually
# /file remove mullvad.rsc
