:local installedFirmware;
:local latestFirmware;

set $installedFirmware ([/int lte info lte1 once as-value]->"revision");
:put "   Installed Firmware: $installedFirmware";

set $latestFirmware ([/int lte firmware-upgrade lte1 as-value]->"latest");
:put "      Latest Firmware: $latestFirmware";

:if ($installedFirmware != $latestFirmware) do={
  :log info "A firmware update is available!!";
} else={
  :log info "The installed firmware is the latest firmware!";
}
