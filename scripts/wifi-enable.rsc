# Enable WiFi in the morning

# as a cron event
/system scheduler
add comment="Enable WiFi @morning" interval=1d name="WiFi Enable" on-event="/int wifiwave2 enable [find]; /int wireless enable [find];" \
    policy=read,write,policy,test start-date=jan/03/2022 start-time=05:30:00


# as a script to be used

/interface wifiwave2
  enable [find]

/interface wireless

# Enable all WiFi interfaces
# :if ( [get wifi2g disabled] = true ) do={ enable [find] }

# Enable selective WLANs

:if ( [get wifi2g disabled] = true ) do={ enable wifi2g } else={ :log info "wifi2g is already running" }

:if ( [get wifi5g disabled] = true ) do={ enable wifi5g } else={ :log info "wifi5g is already running" }

# :if ( [get [find master-interface=wifi2g] disabled] = true ) do={ enable [find master-interface=wifi2g] } else={ :log info "guest2g is already running." }

# :if ( [get [find master-interface=wifi5g] disabled] = true ) do={ enable [find master-interface=wifi5g] } else={ :log info "guests2g is already running." }
