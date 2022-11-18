# Initialize the router with default values, run backup scripts and check for updates!

# Version: 2

# changelog
# version: 2
#   - date: 2022-11-18
#   - introduction of timeout to check internet

:global adminEmail "noreply@example.com"
:global cloudPass ""

:local isUP 0
:local timeout 5

/interface/detect-internet
  set detect-interface-list=WAN
  state

:do {
  :delay 60s
  :set $internetStatus ([:pick [print as-value] 0]->"state")
  # :log info "Waiting for internet..."

  :set isUP ($isUP+1)
  :if ($isUP = $timeout) do={ :error "Internet timed out after $timeout minutes!" }

} while ($internetStatus != "internet")

# :log info "Connected to internet."

:log info "Init script started."

/system script

:local commonScripts {"backup-buttons"; "backup-cron"; "backup-scripts"; "cloud-backup"; "firmware-check"}
:local initScripts ("enable-wifi", $commonScripts)

:foreach scriptName in $initScripts do={
  :do { run $scriptName } on-error={:log error "Error running $scriptName"}
  :delay 30s
}

:log info "Init script ended."
