TODO:

- DoH script for nextdns

Important thread... https://forum.mikrotik.com/viewtopic.php?f=2&t=160243#p799274

Remember that DoH depends on correct time. So, make sure NTP client is configured. The MikroTik Cloud NTP client service required DNS that in turn requires a working NTP client. So, don't depend on MikroTik Cloud NTP client service.

NextDNS recommends https://curl.se/ca/cacert.pem too.

Root CA certificates that we can use...

- https://www.digicert.com/kb/digicert-root-certificates.htm (Download DigiCert Global Root CA)
    - https://cacerts.digicert.com/DigiCertGlobalRootCA.crt.pem
    - works **only** for 1.1.1.1 DoH

# the following don't work for unknown reason...

- https://pki.goog/repository/
- https://support.globalsign.com/ca-certificates/root-certificates/globalsign-root-certificates
- https://www.amazontrust.com/repository/

Or download most (if not all) root CA certificates from https://curl.se/ca/cacert.pem

Recommended - https://pki.goog/repo/certs/gtsr4.pem (validity: 2038)
