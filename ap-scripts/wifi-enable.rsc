# Enable WiFi in the morning

# Version: 2.0
# changelog
# version: 2.0
#   - date: 2023-09-10
#   - check for wifiwave2 at first.
#   - improve naming scheme.

# using mode button
# /system routerboard mode-button set enabled=yes on-event="wifi-enable"

# as a cron event
# /system scheduler
# add comment="Enable WiFi @morning" interval=1d name="WiFi Enable" on-event="wifi-enable" \
    # policy=read,write,policy,test start-date=jan/03/2022 start-time=05:30:00

# as a script to be used

# Enable wifiwave2/wireless interface/s if disabled.

:local allwlans
:local wlan

:do {
  :set allwlans [/int wifiwave2 print as-value]
} on-error={
  :log info "No wifiwave2";

  :do {
    :set allwlans [/int wireless print as-value]
  } on-error={ :error "No wireless either!"; }
}

/interface
:foreach wlan in=$allwlans do={
  :local wlanName ($wlan->"name")
  :if ( [get $wlanName disabled] = true ) do={
    enable $wlanName
    :log info "$wlanName: Enabled";
  } else={ :log info "$wlanName: Already enabled" }
}
