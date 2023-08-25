# TODO: Verify the connection if possible
# https://dns.nextdns.io/xxxxxx - see https://my.nextdns.io/setup

# Variables
:local nextdnsID
:local deviceName
:set nextdnsID "abc123"
# Avoid spaces or use unicode
:local deviceName "MikroTik-AX2"

# disable doh (temporarily)

/ip dns set verify-doh-cert=no

# Quad9 uses DigiCert like CloudFlare.
:local result [ /tool fetch url=http://crt.usertrust.com/USERTrustECCAddTrustCA.crt dst-path=ssl.pem as-value ];
:do { :delay 2s } while=( $result->"status" != "finished" )

/certificate remove [find]
/certificate import file-name=ssl.pem passphrase=""
/file remove ssl.pem

/ip dns
    static remove [find name="dns.quad9.net"]
    static add name=dns.nextdns.io address=45.90.28.0 type=A
    static add name=dns.nextdns.io address=45.90.30.0 type=A
    static add name=dns.nextdns.io address=2a07:a8c0:: type=AAAA
    static add name=dns.nextdns.io address=2a07:a8c1:: type=AAAA

:if ( $deviceName == "" ) do={
    set use-doh-server="https://dns.nextdns.io/$nextdnsID" verify-doh-cert=yes
} else={
    set use-doh-server="https://dns.nextdns.io/$nextdnsID/$deviceName" verify-doh-cert=yes
}

# optional steps
/ip dns set servers=""
/ip dhcp-client set use-peer-dns=no [find]

# flush existing cache
/ip dns cache flush

# Post-install step: remove this file manually
# /file remove nextdns.rsc
