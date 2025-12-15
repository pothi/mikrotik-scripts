# Alert upon new Router OS Version

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

:local updateStatus "incomplete"
:do {
  :delay 2s

  :set $updateStatus [get status]

  :if ($updateStatus = "ERROR: no internet connection") do={ :error "ERROT: no internet connection"; }
  :if ($updateStatus = "ERROR: connection timed out")   do={ :error "ERROR: connection timed out"; }

  :if ($updateStatus = "getting changelog...")          do={ :set $updateStatus "incomplete" }
  :if ($updateStatus = "finding out latest version...") do={ :set $updateStatus "incomplete" }

  :if ($updateStatus = "New version is available" )     do={ }
  :if ($updateStatus = "System is already up to date" ) do={ }

} while=( $updateStatus = "incomplete" )

:local installedVersion [get installed-version]
:local latestVersion [get latest-version]

# alternative method
# :if ( $updateStatus = "New version is available" ) do={
:if ( installedVersion != $latestVersion ) do={
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
