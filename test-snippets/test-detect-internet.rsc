# requirement: /interface detect-internet set detect-interface-list=WAN

/interface detect-internet
  # set detect-interface-list=WAN
  state

:do {
  :log info "Waiting for internet..."
  :set $internetStatus ([:pick [print as-value] 0]->"state")
  :delay 3s
} while ($internetStatus != "internet")

:log info "Connected to internet."
