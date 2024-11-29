# List of public servers... https://gist.github.com/mutin-sa/eea1c396b1e610a2da1e5550d94b0453

# variables
# timezone
:local tz
:set tz "+05:30"

# To be used as the primary NTP server
:local ipNTP
:local ipNTPcomment
# IP based NTP server - when DNS is unavailable.
:set ipNTP "128.138.140.44"
:set ipNTPcomment "From https://tf.nist.gov/tf-cgi/servers.cgi"

# To be used as the secondary NTP server
:local poolNTPorg
:set poolNTPorg [:resolve pool.ntp.org]

# To be used for DNS based NTP servers
:local ntp1
:local ntp2
:set ntp1 "time.cloudflare.com"
:set ntp2 "time.google.com"

:put "Primary NTP: $ipNTP ($ipNTPcomment)"
:put "Secondary NTP: $poolNTPorg (pool.ntp.org)"
:put "DNS NTP 1: $ntp1"
:put "DNS NTP 2: $ntp2"

# configure timezone
# /system clock manual set time-zone=$tz
:put "Timezone: $tz\n"
:put "Clock info..."

/system clock print

# Find Router OS version

:local rosVersion
:set rosVersion [:tonum [:pick [/system resource get version] 0 1]]
# following works as well.
# :set rosVersion [:pick [/system/routerboard/get current-firmware] 0 1]

:put "\nRouter OS Version: $rosVersion\n"


if ( $rosVersion = 7 ) do={
    /system ntp client servers
        add address=128.138.140.44 comment="NIST.gov"
        add address=[ :resolve pool.ntp.org ] comment="pool.ntp.org"
        add address=time.google.com
        add address=time.cloudflare.com
}

/system ntp client set enabled=yes


:put "NTP client info..."
/system ntp client print
