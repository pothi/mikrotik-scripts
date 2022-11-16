# Email the generic-log when it reaches the threshold!

# Exclusive for RouterOS v7

# Requirements: adminEmail, logTopics
:global adminEmail

# one-time process to be done when bootstrapping the device
# :local logTopics {"info"; "error"; "warning"; "critical"}
# :foreach topic in=$logTopics do={ :system logging add topics=$topic action=disk }

:local emailStatus
:local logFile "log.1.txt"

# :log info "Checking for $logFile file"

:do {
  /file get "$logFile"
} on-error={
    :error "Log files isn't created yet, because it isn't big enough!";
#  :log warning "Log file isn't created yet, because it isn't big enough!"
}

# The following gets executed only if the log file is ready!

:log info "\nEmailing the log file..."

/tool e-mail

:do {
  send file="$logFile" subject="Log" body="See sub!" to=$adminEmail
} on-error={ :log error "The log file could not be sent by email." }

:do { :delay 1s; :set emailStatus [get last-status] } while=( $emailStatus = "in-progress" )

:if ( $emailStatus = "succeeded" ) do={
  :log info "The log file is sent to $adminEmail."
} else={
  :log error "Email failed!"
}

/file remove "$logFile"

