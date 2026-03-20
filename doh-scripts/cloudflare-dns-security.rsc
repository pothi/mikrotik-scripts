# Verify the connection at https://1.1.1.1/help

# cloudflare-dns.com is the default DNS server (at least as of May 2025), in place of (still working) 1.1.1.1 and one.one.one.one.
# security.cloudflare-dns.com blocks malware.
# ref: https://developers.cloudflare.com/1.1.1.1/setup/#dns-over-https-doh

# disable doh (temporarily)
/ip dns set verify-doh-cert=no

# since RouterOS v7.19...
:local rosVersion
:set rosVersion [:pick [/system/routerboard/get current-firmware] 0 1]

:if ($rosVersion != 7) do={
  :error "We need Router OS version 7 to run this script - current ROS version $rosVersion."
}
:put "Router OS Version: 7"

:local rosVersionMinor
:set rosVersionMinor [:pick [/system/routerboard/get current-firmware] 2 4]
:put "Router OS Minor Version: $rosVersionMinor"

:if ( $rosVersionMinor >= 19 ) do={
    :put "We have the required Router OS version (or greater) - $rosVersion.$rosVersionMinor, to enable built-in CA root certificates."
    /certificate/settings/set builtin-trust-store=all
} else={
    :put "We use the Router OS version $rosVersion.$rosVersionMinor that is less than the required version (7.19)."

    # update the caCertURL depending on what's used at https://doh.opendns.com/dns-query
    :local caCertURL https://cacerts.digicert.com/DigiCertGlobalRootG2.crt.pem

    :local result [ /tool fetch url=$caCertURL dst-path=cert.pem as-value ];
    :do { :delay 2s } while=( $result->"status" != "finished" )

    /certificate remove [find name~"cert.pem"]
    /certificate import file-name=cert.pem passphrase=""
}

# Add static DNS entries for the DoH server
/ip dns static remove [find name=security.cloudflare-dns.com]
# use the following two entries if IPv6 is available on your internet
# /ip dns static add address=2606:4700:4700::1112 name=security.cloudflare-dns.com comment="DoH"
# /ip dns static add address=2606:4700:4700::1002 name=security.cloudflare-dns.com comment="DoH"
/ip dns static add address=1.1.1.2 name=security.cloudflare-dns.com comment="DoH"
/ip dns static add address=1.0.0.2 name=security.cloudflare-dns.com comment="DoH"
:put "Static DNS entries are added for security.cloudflare-dns.com"

/ip dns set use-doh-server=https://security.cloudflare-dns.com/dns-query verify-doh-cert=yes
:put "DoH is configured."

# optional steps
# use the following if IPv6 is available on your internet
# /ip dns set servers="2606:4700:4700::1112,2606:4700:4700::1002,1.1.1.2,1.0.0.2"
/ip dns set servers="1.1.1.2,1.0.0.2"
/ip dhcp-client set use-peer-dns=no [find]
:put "Custom DNS servers are configured."

# flush existing cache
/ip dns cache flush
:put "DNS cache is flushed."
