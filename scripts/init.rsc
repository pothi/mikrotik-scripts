# Initialize the router with default values, run backup scripts and check for updates!

:global adminEmail "noreply@example.com"
:global cloudPass ""

/interface/detect-internet
  set detect-interface-list=WAN
  state
:do {
  :delay 60s
  :set $internetStatus ([:pick [print as-value] 0]->"state")
  # :log info "Waiting for internet..."
} while ($internetStatus != "internet")
# :log info "Connected to internet."

:log info "Init script started."

/system script

:local commonScripts {"backup-cron"; "backup-scripts"; "cloud-backup"; "firmware-check"}
:local initScripts ("enable-wifi", $commonScripts)

:foreach scriptName in $initScripts do={
  :do { run $scriptName } on-error={:log error "Error running $scriptName"}
  :delay 30s
}

:log info "Init script ended."
