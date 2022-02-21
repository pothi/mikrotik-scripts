# Alert upon new Router OS Version

# requirement/s:
# policy: read, write, policy, test
:local adminEmail "admin@example.com"
:local startDelay "90s"

# if you run this script at "startup",
# the following indicates the time for the internet to go "up"
# ToDo: Find it out dynamically
# :delay $startDelay

:log info "Checking for new version of RouterOS..."

/system package update

check-for-updates once

:local versionStatus
:local deviceIdentity [/system identity get name]

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
    :log info "A new update is available for Router OS and an email is probably sent to $adminEmail."
    /tool e-mail send to="$adminEmail" \
      subject="[Mikrotik $deviceIdentity] Software Update is Available" \
      body="A new update is available for your MikroTik device: \"$deviceIdentity\" ...

      Installed Version: $installedVersion
          Latest Version: $latestVersion
      "
} else={
  :log info "Router OS is already up to date."
}
