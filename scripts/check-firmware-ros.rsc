# Alert upon new Router OS Version

# requirement/s:
#   policy: read, write, policy, test
#   active internet
#   $adminEmail

:global adminEmail
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
