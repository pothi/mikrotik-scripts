# Used to fill logs at every few seconds to find when the cloud timesync happens in RouterOS v6
# It can be used for multiple other use cases too.

:local i 0

:do {
  :delay 10s
  :set i ($i+10)
  :log info "Time passed since boot: $i seconds"
} while ($i < 600)
