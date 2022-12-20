# Verify the connection at https://1.1.1.1/help

/tool fetch url=https://curl.se/ca/cacert.pem
/certificate remove [find name~"cacert.pem"]
/certificate import file-name=cacert.pem passphrase=""

/ip dns set use-doh-server=https://1.1.1.1/dns-query verify-doh-cert=yes 

# optional steps
/ip dns set servers=""
/ip dhcp-client set use-peer-dns=no [find]
