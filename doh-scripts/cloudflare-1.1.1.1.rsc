# Verify the connection at https://1.1.1.1/help

# disable doh (temporarily)

/ip dns set verify-doh-cert=no

# update the caCertURL depending on what's used at https://1.1.1.1/dns-query

:local caCertURL
:set caCertURL https://cacerts.digicert.com/DigiCertGlobalRootG2.crt.pem

:local result [ /tool fetch url=$caCertURL dst-path=root-ca-cert.pem as-value ];
:do { :delay 2s } while=( $result->"status" != "finished" )

/certificate remove [find name~"root-ca-cert.pem"]
/certificate import file-name=root-ca-cert.pem passphrase=""
/file remove root-ca-cert.pem

/ip dns set use-doh-server=https://1.1.1.1/dns-query verify-doh-cert=yes

# optional steps
/ip dns set servers="1.1.1.1,1.0.0.1"
/ip dhcp-client set use-peer-dns=no [find]

# flush existing cache
/ip dns cache flush
