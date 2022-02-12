# Alert upon new version
# requirement $adminEmailAddress or configure it below
# :local adminEmailAddress "admin@example.com"

# if you run this script at "startup",
# the following indicates the time for the internet to go "up"
:delay 60s

/system package update

check-for-updates once

:local verionStatus
:set $versionStatus [get status]
# alternative way to get the above info
# :set $versionStatus ([print as-value]->"status")

:put $versionStatus
:put $adminEmailAddress

:if ( $versionStatus = "New version is available" ) do={
# alternative method
# :if ( [get installed-version] != [get latest-version] ) do={
    /tool e-mail send to="$adminEmailAddress" \
      subject="[Mikrotik] Software Up date Available" \
      body="A new update is available for your MikroTik device"
}
