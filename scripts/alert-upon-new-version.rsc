/system package update check-for-updates once; :delay 10s;

:if ( [get status] = "New version is available") do={
  /tool e-mail send to="$emailAddress" subject="[Mikrotik] A new update is available" body="See subject!"
}
