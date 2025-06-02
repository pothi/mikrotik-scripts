The following DoH services can be automated for now...

- [Cloudflare](https://github.com/pothi/mikrotik-scripts/blob/main/doh-scripts/cloudflare.rsc)
- [Google](https://github.com/pothi/mikrotik-scripts/blob/main/doh-scripts/google.rsc)
- [NextDNS](https://github.com/pothi/mikrotik-scripts/blob/main/doh-scripts/nextdns.rsc)

Incompatible / buggy implementation...

- [Quad9](https://github.com/pothi/mikrotik-scripts/blob/main/doh-scripts/quad9.rsc)

Or you may use the [generic script](https://github.com/pothi/mikrotik-scripts/blob/main/doh-scripts/generic.rsc).

Officially incompatible DoH servers... https://help.mikrotik.com/docs/spaces/ROS/pages/37748767/DNS#DNS-Knowncompatible/incompatibleDoHservices

Relevant thread in MikroTik forums... https://forum.mikrotik.com/viewtopic.php?f=2&t=160243#p799274

Remember that DoH depends on the correct time on your MikroTik device. So, make sure that the NTP client is configured and is working. The MikroTik's Cloud NTP client service requires a working DNS that in turn requires a working NTP client. So, please don't depend on MikroTik's Cloud NTP sync service.

Root CA certificates that we can use...

- https://www.digicert.com/kb/digicert-root-certificates.htm (Download DigiCert Global Root CA)
    - https://cacerts.digicert.com/DigiCertGlobalRootCA.crt.pem
    - works **only** for 1.1.1.1 DoH

The following don't work for unknown reason...

- https://pki.goog/repository/
- https://support.globalsign.com/ca-certificates/root-certificates/globalsign-root-certificates
- https://www.amazontrust.com/repository/

Or download most (if not all) root CA certificates from https://curl.se/ca/cacert.pem

Recommended - https://pki.goog/repo/certs/gtsr4.pem (validity: 2038)

NextDNS recommends https://curl.se/ca/cacert.pem too.

