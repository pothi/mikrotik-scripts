# Notify to upgrade RouterBoard Firmware

# requirement/s:
#   policy: read, write, policy, test
#   active internet
#   $adminEmail

:global adminEmail
:local oldVersion
:local newVersion

:log info "\nChecking Routerboard Firmware versions..."

/system routerboard
  :set oldVersion [get current-firmware]
  :set newVersion [get upgrade-firmware]

:if ( $oldVersion != $newVersion ) do={
  :log info "RouterBoard firmware can be upgraded from $oldVersion to $newVersion \n"
  /tool e-mail send to="$adminEmail" subject="RouterBoard firmware upgrade!" \
    body="An upgrade from $oldVersion to $newVersion is pending!"
} else={
  :log info "RouterBoard Firmware is up to date.\n"
}
