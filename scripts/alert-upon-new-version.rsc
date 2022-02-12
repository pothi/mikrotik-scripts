# Alert upon new version
# requirement $adminEmailAddress or configure it below
# :local adminEmailAddress "admin@example.com"

/system package update

# check-for-updates once
# :delay 10s
:local verionStatus

:set $versionStatus [get status]
# alternative way to get the above info
# :set $versionStatus ([print as-value]->"status")

:put $versionStatus
:put $adminEmailAddress

# alternative method
# :if ( [get installed-version] != [get latest-version] ) do={
:if ( $versionStatus = "New version is available" ) do={
    /tool e-mail send to="$adminEmailAddress" \
      subject="[Mikrotik] Software Up date Available" \
      body="A new update is available for your MikroTik device"
}
