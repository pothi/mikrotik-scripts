# Modified from https://forum.mikrotik.com/viewtopic.php?t=181433

:global adminEmail

# :log info "Success"

/ip dhcp-server lease
:if (($leaseBound=1) && ([find where dynamic mac-address=$leaseActMAC]!="")) do {
    :local leaseHostName $"lease-hostname"
    :do {
        :tool e-mail send \
            to=$adminEmail \
            subject="Unknown Device Alert [MAC: $leaseActMAC]" \
            body="The following unknown device received a dynamic IP address:
                Mac: $leaseActMAC
                Ip: $leaseActIP,
                Host: $leaseHostName,
                Bound: $leaseBound"
        :log info "Unknown Device: $leaseActMAC, $leaseActIP, $leaseHostName"
    } on-error={:log error "Failed to send alert email upon unknown device."}
}}

