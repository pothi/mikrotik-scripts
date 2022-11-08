# Alert upon new Router OS Version and pending RouterBoard firmware update!

# requirement/s:
#   policy: read, write, policy, test
#   active internet
#   $adminEmail

:global adminEmail
:if ([:typeof $adminEmail] = "nothing" || $adminEmail = "") do={
  :log error "adminEmail is not defined or nil."; :error "Error: Check the log"; }

:local versionStatus

:log info "\nChecking for new version of Router OS..."

/system package update
check-for-updates once

:do {
  :delay 3s

  :set $versionStatus [get status]
  # alternative way to get the above info
  # :set $versionStatus ([print as-value]->"status")
} while=( $versionStatus = "finding out latest version..." )

:local installedVersion [get installed-version]
:local latestVersion [get latest-version]

:if ( $versionStatus = "New version is available" ) do={
# alternative method
# :if ( installedVersion != $latestVersion ) do={
    :log info "A new update is available for Router OS."
    /tool e-mail send to="$adminEmail" \
      subject="Software Update is Available" \
      body="A new Router OS update is available...

      Installed Version: $installedVersion
          Latest Version: $latestVersion
      "
} else={
  :log info "Router OS is up to date."
}

# Notify to upgrade RouterBoard Firmware

# requirement/s:
#   policy: read, write, policy, test
#   active internet
#   $adminEmail

:global adminEmail
:local oldVersion
:local newVersion

:log info "\nChecking for pending Routerboard firmware update..."

/system routerboard
  :set oldVersion [get current-firmware]
  :set newVersion [get upgrade-firmware]

:if ( $oldVersion != $newVersion ) do={
  :log info "RouterBoard firmware can be upgraded from $oldVersion to $newVersion \n"
  /tool e-mail send to="$adminEmail" subject="RouterBoard firmware upgrade!" \
    body="An upgrade from $oldVersion to $newVersion is pending!"
} else={
  :log info "RouterBoard Firmware is up to date."
}
