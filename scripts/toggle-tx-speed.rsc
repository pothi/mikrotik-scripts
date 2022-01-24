# Script to toggle wlan speeds.

:log info "Toggle TX Limits script is executed."

:local txLimit

:set txLimit [/interface/wireless/get [find] default-ap-tx-limit]

:tonum $txLimit

:if ( $txLimit = 0 ) do={ 
    /interface/wireless/set [find] default-ap-tx-limit=2M
    :log info "Wlan speed is restricted to 2Mbps."
} else={
    /interface/wireless/set wlan1 default-ap-tx-limit=0
    :log info "Wlan doesn't have speed limits now."
}
