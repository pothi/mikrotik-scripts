# Disable WiFi interfaces at night via scheduler (cron).

# To avoid being locked out, make sure to run a script to enable wifi interfaces when you wake up.
# Also, put the wifi-enabler script in a button of your choice. Mode button or reset button. Mode button is recommended.
# See below...

/system scheduler
add comment="Shutdown WiFi @night to avoid electronic interference!" interval=1d name="WiFi Disable" on-event=\
    "/int disable [find type~\"wifi|wlan\"]"\
    policy=ftp,reboot,read,write,policy,test start-date=sep/03/2023 start-time=23:04:00

# /system routerboard mode-button set enabled=yes on-event="wifi-disable"
