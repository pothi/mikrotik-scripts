:local lteFirmwareInfo [/interface lte firmware-upgrade lte1 as-value];

:local lteInstalledVer ($lteFirmwareInfo->"installed");
:local lteLatestVer ($lteFirmwareInfo->"latest");

:if ( $lteInstalledVer != $lteLatestVer ) do={
  /tool e-mail send to="$emailAddress" subject="[Mikrotik] A new FIRMWARE update is available for (SXT) LTE." body="See subject!"
  :log info "A new firmware is available for LTE modem."
} else={
  :log info "No new firmware update for LTE."
  :log info "LTE Installed Firmware Version: $lteInstalledVer"
  :log info "LTE Latest Firmware Version: $lteLatestVer"
}
