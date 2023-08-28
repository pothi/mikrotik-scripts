# Verify the connection at https://1.1.1.1/help

# disable doh (temporarily)

/ip dns set verify-doh-cert=no

/tool fetch url=https://cacerts.digicert.com/DigiCertGlobalRootCA.crt.pem
/certificate remove [find name~"DigiCertGlobalRootCA.crt.pem"]
/certificate import file-name=DigiCertGlobalRootCA.crt.pem passphrase=""
/file remove DigiCertGlobalRootCA.crt.pem

/ip dns set use-doh-server=https://1.1.1.1/dns-query verify-doh-cert=yes 

# optional steps
/ip dns set servers=""
/ip dhcp-client set use-peer-dns=no [find]

# flush existing cache
/ip dns cache flush
