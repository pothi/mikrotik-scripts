# List of public servers... https://gist.github.com/mutin-sa/eea1c396b1e610a2da1e5550d94b0453

# variables
# timezone
:local tz "+05:30"

# To be used as the primary NTP server
# IP based NTP server - when DNS is unavailable.
:local ipMainNTP "14.139.60.103"
:local ipMainNTPcomment "time.nplindia.in"

# To be used as the secondary NTP server
:local poolNTPorg
:set poolNTPorg [:resolve pool.ntp.org]

# To be used for DNS based NTP servers
:local ntp1 "time.nplindia.com"
:local ntp2 "time.cloudflare.com"
:local ntp3 "time.google.com"

:put "Primary NTP: $ipMainNTP ($ipMainNTPcomment)"
:put "Secondary NTP: $poolNTPorg (pool.ntp.org)"
:put "DNS NTP 1: $ntp1"
:put "DNS NTP 2: $ntp2"
:put "DNS NTP 3: $ntp3"

# configure timezone
/system clock manual set time-zone=$tz
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
        add address=$ipMainNTP comment=$ipMainNTPcomment
        add address=[ :resolve pool.ntp.org ] comment="pool.ntp.org"
        add address=$ntp1
        add address=$ntp2
        add address=$ntp3
}

/system ntp client set enabled=yes


:put "NTP client info..."
/system ntp client print
