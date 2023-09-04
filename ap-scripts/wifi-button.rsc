# Only for Router OS v6
# Ref: https://gist.github.com/sebastian13/47e788371474d73552593b621eeacd33

:log info message=("mode button was pressed");
:local i

:if ( [/int wir get 0 disabled ] = true ) do={
  :foreach i in= [ /int wir find ] do={ :int wir enable $i };
} else={
  :foreach i in= [ /int wir find ] do={ :int wir disable $i };
}

# Wifi disable
# :if ( [/int wir get 0 disabled ] = true ) do={} else={
  # :foreach i in= [ /int wir find ] do={ :int wir disable $i };
# }

# Wifi enable
# :if ( [/int wir get 0 disabled ] = true ) do={
  # :foreach i in= [ /int wir find ] do={ :int wir enable $i };
# }
