:global country "India";
:global identity "Mikrotik";
# override the default values here
:set identity "Mikrotik SXT LTE";

# Custom subnet
:global customSubnetCIDR "10.88.50.0/24";
:global dhcpServerIP "10.88.50.1";
:global dhcpPoolRange "10.88.50.88-10.88.50.254";
:global dhcpName "custom-dhcp";
:global customBridgeAddress "10.88.50.1/24";

# SSH
:global sshUserName "pothi";

### ------------------------------------------------------------------------------------ ###
#                                   Generic Tweaks                                         #
### ------------------------------------------------------------------------------------ ###

# Configure Identity
/system identity set name=$identity

# Change subnet
/ip pool add name=$dhcpName ranges=$dhcpPoolRange;
/ip pool remove default-dhcp;

/ip dhcp-server remove defconf;
/ip dhcp-server add name=$dhcpName address-pool=$dhcpName interface=bridge lease-time=10m disabled=no;

/ip dhcp-server network add address=$customSubnetCIDR gateway=$dhcpServerIP dns-server=$dhcpServerIP;
/ip dhcp-server network remove [find dns-server=192.168.88.1];

/ip address add address=$customBridgeAddress interface=bridge;
/ip address remove [find address="192.168.88.1/24"]

#change static DNS entry for router.lan
/ip dns static set numbers=[find name=router.lan] address=$dhcpServerIP;

# Configure Guest Network and Firewall

# Wireless tweaks

# install public SSH key
/tool fetch https://launchpad.net/~pothi/+sshkeys dst-path=pothi-ssh-key-rsa;
:delay 5s;
/user ssh-keys import public-key-file=pothi-ssh-key-rsa;
/file remove pothi-ssh-key-rsa;

# Reduce disk activity
/ip dhcp-server config set store-leases-disk=never;

# Configure NTP Client
/system ntp client set primary-ntp=[ :resolve pool.ntp.org ];
/system ntp client set secondary-ntp=[ :resolve time.cloudflare.com ];
/system ntp client set server-dns-names=time.google.com,time.apple.com;

### ------------------------------------------------------------------------------------ ###
#                               Specific to LTE Products                                   #
### ------------------------------------------------------------------------------------ ###
# SMS Receive capability
/tool sms set auto-erase=yes receive-enabled=yes secret=0000 port=lte1;
