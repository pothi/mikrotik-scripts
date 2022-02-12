# Alert upon new firmware for LTE Modem

# Ref: https://wiki.mikrotik.com/wiki/Manual:Interface/LTE#Modem_firmware_upgrade
:local adminEmailAddress "admin@example.com"

:log info "Checking for new firmware for LTE Modem..."

# if you run this script at "startup",
# the following indicates the time for the internet to go "up"
:delay 60s

:local lteFirmwareInfo [/interface lte firmware-upgrade lte1 as-value];

:local lteInstalledVer ($lteFirmwareInfo->"installed");
:local lteLatestVer ($lteFirmwareInfo->"latest");

:if ( $lteInstalledVer != $lteLatestVer ) do={
  /tool e-mail send to="$adminEmailAddress" subject="[Mikrotik] A new FIRMWARE update is available for (SXT) LTE." body="See subject!"
  :log critical "A new firmware is available for LTE modem and an email is probably sent to '$adminEmailAddress'."
} else={
  :log info "No new firmware update for LTE."
  :log info "LTE Installed Firmware Version: $lteInstalledVer"
  :log info "   LTE Latest Firmware Version: $lteLatestVer"
}
