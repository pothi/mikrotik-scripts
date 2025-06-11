# Inspired by https://forum.mikrotik.com/viewtopic.php?t=40507#p841720

# :local full "7.0.1"
:local full [/system/routerboard/get current-firmware]

:local length [:len $full]
:local major
:local minor
:local patch

:put "Full version: $full"

:local pos [:find $full "."]

:set major [:pick $full 0 $pos]

:put "Major: $major"

:local minorPatch [:pick $full ($pos +1) $length]

# :put $minorPatch

:local pos [:find $minorPatch "."]

:set minor [:pick $minorPatch 0 $pos]

:put "Minor: $minor"

:set length [:len $minorPatch]
:set patch [:pick $minorPatch ($pos +1) $length]

:put "Patch: $patch"
