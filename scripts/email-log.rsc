# Email the generic-log when it reaches the threshold!

# one-time process to be done when bootstrapping the device
# :local logTopics {"info"; "error"; "warning"; "critical"}
# :foreach topic in=$logTopics do={ :system logging add topics=$topic action=disk }

# Requirements: adminEmail, logTopics
:global adminEmail

:if ([:typeof $adminEmail] = "nothing" || $adminEmail = "") do={
  :log error "adminEmail is not defined or nil."; :error "Error: Check the log"; }

:local emailStatus
:local logFile "log.1.txt"

# check for "flash" folder
:do {
  /file get "flash/log.0.txt"
  :set logFile "flash/log.1.txt"
  :put "Flash folder found!"
} on-error={
  :put "Flash folder doesn't exist!"
}

:do {
  /file get "$logFile"
} on-error={
  # :log info "$logFile file isn't created yet!";
  :error "$logFile file isn't created yet!";
}

# The following gets executed only if the log file is ready!

:log info "Emailing the log file..."

/tool e-mail

:do {
  send file="$logFile" subject="Log" body="See sub!" to=$adminEmail
} on-error={ :log error "The log file could not be sent by email." }

:do { :delay 3s; :set emailStatus [get last-status] } while=( $emailStatus = "in-progress" )

:if ( $emailStatus = "succeeded" ) do={
  :log info "The log file is sent to $adminEmail."
} else={
  :log error "Email failed!"
}

/file remove "$logFile"
