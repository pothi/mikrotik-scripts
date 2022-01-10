:global country "India";
:global identity "Mikrotik";
:global myPassword;

# override the default values here
:set identity "SXT LTE Kit";
:set myPassword [:pick ([/cert scep-server otp generate as-value minutes-valid=1]->"password") 0 20]
:put "Your new password is..."
:put $myPassword

# my subnet
:global mySubnetCIDR "10.88.50.0/24";
:global dhcpServerIP "10.88.50.1";
:global dhcpPoolRange "10.88.50.88-10.88.50.100";
:global dhcpName "my-dhcp";
:global myBridgeAddress "10.88.50.1/24";

# SSH
:global sshUserName "pothi";

### ------------------------------------------------------------------------------------ ###
#                                   Generic Tweaks                                         #
### ------------------------------------------------------------------------------------ ###

# Configure Identity
/system identity set name=$identity

# Wireless tweaks

# install public SSH key
:put "Importing SSH key..."
{
    :local result [ /tool fetch https://launchpad.net/~pothi/+sshkeys dst-path=pothi-ssh-key-rsa as-value];
    :while ($result->"status" != "finished") do={ :delay 2s }
}
:delay 1s
/user ssh-keys import public-key-file=pothi-ssh-key-rsa;
:delay 1s
/file remove pothi-ssh-key-rsa;
:put "Done importing SSH key."

# Reduce disk activity
/ip dhcp-server config set store-leases-disk=never;

# Configure NTP Client
/system ntp client set primary-ntp=[ :resolve pool.ntp.org ];
/system ntp client set secondary-ntp=[ :resolve time.cloudflare.com ];
/system ntp client set enabled=yes;

### ------------------------------------------------------------------------------------ ###
#                               Specific to LTE Products                                   #
### ------------------------------------------------------------------------------------ ###
# SMS Receive capability
/tool sms set auto-erase=yes receive-enabled=yes secret=0000 port=lte1;

:put "Changing the sim slot to 'b'."
/system routerboard modem set sim-slot=b

# Change subnet
#change static DNS entry for router.lan
/ip dns static set numbers=[find name=router.lan] address=$dhcpServerIP;

/ip pool add name=$dhcpName ranges=$dhcpPoolRange;
/ip dhcp-server network add address=$mySubnetCIDR gateway=$dhcpServerIP dns-server=$dhcpServerIP;
/ip address add address=$myBridgeAddress interface=bridge;
# /ip dhcp-server add name=$dhcpName address-pool=$dhcpName interface=bridge lease-time=10m disabled=no;
/ip dhcp-server set [find name=defconf] address-pool=my-dhcp
:put "Subnet changed."

:put "Removing old subnet."
:put "This will make the current SSH session unresponsive."
:put "Renew or release the IP in DHCP client in the router or disble & enable DHCP client to make everything work again."
/ip pool remove default-dhcp;
/ip dhcp-server network remove [find dns-server=192.168.88.1];
/ip address remove [find address="192.168.88.1/24"]
# /ip dhcp-server remove defconf;

