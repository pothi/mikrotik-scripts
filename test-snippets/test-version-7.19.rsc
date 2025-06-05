# find RouterOS version

:local rosVersion
:set rosVersion [:pick [/system/routerboard/get current-firmware] 0 1]

:if ($rosVersion != 7) do={
  :error "We need Router OS version 7 to run this script - current ROS version $rosVersion."
}

:local rosVersionMinor
:set rosVersionMinor [:pick [/system/routerboard/get current-firmware] 2 4]

:if ($rosVersionMinor >= 19) do={
  :put "We have the required Router OS version (or greater) - $rosVersion.$rosVersionMinor"
} else={
  :put "We use the Router OS version $rosVersion.$rosVersionMinor that is less than the required version (7.19)."
}
