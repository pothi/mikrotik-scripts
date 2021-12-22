# Ref: https://wiki.mikrotik.com/wiki/Manual:Upgrading_RouterOS#RouterOS_auto-upgrade
/system package update
check-for-updates once
:delay 3s;
:if ( [get status] = "New version is available") do={ install }
