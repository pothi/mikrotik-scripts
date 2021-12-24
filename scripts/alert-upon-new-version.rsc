# Using: https://wiki.mikrotik.com/wiki/Manual:Upgrading_RouterOS#RouterOS_auto-upgrade
:global emailAddress "noreply@example.com";

/system package update;
check-for-updates once;
:delay 10s;
:if ( [get status] = "New version is available") do={
    /tool e-mail send to="$emailAddress" subject="[Mikrotik] Software Up\
    date Available" body="A new update is available for your MikroTik device"
}
