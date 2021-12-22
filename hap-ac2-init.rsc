:global myCountry "India";
:global myTimezone "Asia/Kolkata";
:global myIdentity "Mikrotik";
:global mySSID "Mikrotik";
:global myPassword;

# please change passwords to something unique
:global mainWIFIpass "RouterOSv6";
:global guestWIFIpass "ROS6Guests";

# override the default values here
:set myIdentity "Mikrotik #1 hAP ac2";
:set mySSID "mikro1"

:set myPassword    [:pick ([/cert scep-server otp generate as-value minutes-valid=1]->"password") 0 20]
:set mainWIFIpass  [:pick ([/cert scep-server otp generate as-value minutes-valid=1]->"password") 0 20]
:set guestWIFIpass [:pick ([/cert scep-server otp generate as-value minutes-valid=1]->"password") 0 20]

# my subnet
:global mySubnetPrefix "10.88.21";
:global mySubnetCIDR "10.88.210.0/24";
:global dhcpServerIP "10.88.210.1";
:global dhcpPoolRange "10.88.210.88-10.88.210.254";
:global dhcpName "my-dhcp";
:global myBridgeAddress "10.88.210.1/24";

# Guest subnet
:global guestSubnetCIDR "10.88.211.0/24";
:global guestPoolRange "10.88.211.88-10.88.211.254";
:global guestNetworkName "Mikrotik-Guests";

# SSH
:global sshUserName "pothi";

### ------------------------------------------------------------------------------------ ###
#                                   Generic Tweaks                                         #
### ------------------------------------------------------------------------------------ ###

# Configure Identity
/system identity set name=$myIdentity;

# Change subnet
/ip pool add name=$dhcpName ranges=$dhcpPoolRange;
/ip pool remove default-dhcp;

/ip dhcp-server remove defconf;
/ip dhcp-server add name=$dhcpName address-pool=$dhcpName interface=bridge lease-time=10m disabled=no;

/ip dhcp-server network add address=$mySubnetCIDR gateway=$dhcpServerIP dns-server=$dhcpServerIP;
/ip dhcp-server network remove [find dns-server=192.168.88.1];

/ip address add address=$myBridgeAddress interface=bridge;
/ip address remove [find address="192.168.88.1/24"];

/ip dns static set numbers=[find name=router.lan] address=$dhcpServerIP;

# Configure Guest Network and Firewall

# Wireless tweaks

# install public SSH key
:put "Configuring SSH...";
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

# Enable mode-button
:global modeButtonScriptName "wifi-enable";
/system script add name=$modeButtonScriptName source={/interface wireless enable [find];};
/system routerboard mode-button set on-event=$modeButtonScriptName enabled=yes;

# WiFi
# WiFi Channels
/interface wireless channels
add band=2ghz-onlyn frequency=2412 list="2.4ghz list" name=channel-1 width=20
add band=2ghz-onlyn frequency=2437 list="2.4ghz list" name=channel-6 width=20
add band=2ghz-onlyn frequency=2462 list="2.4ghz list" name=channel-11 width=20

/interface wireless
set [ find default-name=wlan1 ] band=2ghz-onlyn country=india disabled=no installation=indoor mode=ap-bridge ssid=$mySSID wireless-protocol=802.11 \
    wmm-support=enabled wps-mode=disabled scan-list="2.4ghz list"
set [ find default-name=wlan2 ] band=5ghz-n/ac country=india disabled=no installation=indoor mode=ap-bridge ssid=$mySSID wireless-protocol=802.11 \
    wmm-support=enabled wps-mode=disabled skip-dfs-channels=all
/interface wireless security-profiles
set [ find default=yes ] mode=dynamic-keys authentication-types=wpa2-psk wpa2-pre-shared-key=$mainWIFIpass

# Cron
/system scheduler
add interval=1d name=wifi-enable on-event="/interface wireless enable [find];" policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon start-date=dec/11/2021 \
    start-time=05:55:51
add interval=1d name=wifi-disable on-event="/interface wireless disable [find];" policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon start-date=dec/11/2021 \
    start-time=23:06:25
