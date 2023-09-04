# Enable WiFi in the morning

# using mode button
# /system routerboard mode-button set enabled=yes on-event=":log info \"Mode button pressed\"; /int wifiwave2 enable [find]; /int wireless enable [find];"

# as a cron event
# /system scheduler
# add comment="Enable WiFi @morning" interval=1d name="WiFi Enable" on-event="/int wifiwave2 enable [find]; /int wireless enable [find];" \
    # policy=read,write,policy,test start-date=jan/03/2022 start-time=05:30:00

# as a script to be used

# Enable wireless / wifiwav2 interfaces if disabled.

:local interfaces
:local interface

# :do { wifiwave2 enable [find]; } on-error={ :log info "Error enabling wifiwave2 interfaces" }
:do {
  :set interfaces [/int wifiwave2 print as-value]

} on-error={

  :log info "Wifiwave2 doesn't exist!";

  :do {
    :set interfaces [/int wireless print as-value]
  } on-error={ :error "Wireless doesn't exist"; }

}

/interface
:foreach interface in=$interfaces do={
  :local wifiName ($interface->"name")
  :if ( [get $wifiName disabled] = true ) do={
    enable $wifiName
    :log info "$wifiName is enabled";
  } else={ :log info "$wifiName is already running" }
}
