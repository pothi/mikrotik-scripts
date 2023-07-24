# Find temparature and alert if threshold is reached.

:local t
:local threshold 60

:do {
  :set t [/system health get value-name=value number=[find name=cpu-temperature]]
} on-error={ :set t -1 }

:put $t

:if ( $t < 0 ) do={
  :log warn "Temparature reading could not be fetched."
  :error "Temparature reading could not be fetched."
}

:if ( $t > $threshold ) do={
  :put "Temp exceeded the limit ($limit)."
  :log warning "Temp exceeded the limit ($threshold)."
}
:log info "Current temparature: $t"
