# Ref: https://wiki.mikrotik.com/wiki/Manual:Upgrading_RouterOS#RouterOS_auto-upgrade
# https://help.mikrotik.com/docs/spaces/ROS/pages/328142/Upgrading+and+installation#Upgradingandinstallation-Standardupgrade

/system package update
check-for-updates once
# adjust the delay based on your network speed
:delay 9s;
:if ( [get status] = "New version is available") do={ install }
