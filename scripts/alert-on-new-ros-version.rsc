# Alert upon new version

# requirement/s: $adminEmailAddress
:local adminEmailAddress "admin@example.com"

:log info "Checking for new version of RouterOS..."

# if you run this script at "startup",
# the following indicates the time for the internet to go "up"
:delay 60s

/system package update

check-for-updates once

:local verionStatus

:do {
  :delay 2s

  :set $versionStatus [get status]
  # alternative way to get the above info
  # :set $versionStatus ([print as-value]->"status")
} while=( $versionStatus = "finding out latest version..." )

# for debugging
# :put $versionStatus
# :put $adminEmailAddress

:if ( $versionStatus = "New version is available" ) do={
# alternative method
# :if ( [get installed-version] != [get latest-version] ) do={
    :log info "A new firmware is available for Router OS and an email is probably sent to $adminEmailAddress."
    /tool e-mail send to="$adminEmailAddress" \
      subject="[Mikrotik] Software Update is Available" \
      body="A new update is available for your MikroTik device"
} else={
  :log info "System is already up to date"
}
