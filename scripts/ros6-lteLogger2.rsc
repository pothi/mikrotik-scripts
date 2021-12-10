# Source: https://forum.mikrotik.com/viewtopic.php?t=178312

/system script job remove [find script=lteLogger2]

/system scheduler
remove [find name=lteLogger2]
add interval=1m name=lteLogger2 on-event="#Script WatchDog for script name:\r\
    \nlocal ScriptName lteLogger2\r\
    \n\r\
    \n\r\
    \nlocal ScriptRuningInstances [:len [system script job find script=\$ScriptName]]\r\
    \nif ( \$ScriptRuningInstances = 0) do={/system script run \$ScriptName};\r\
    \nif ( \$ScriptRuningInstances = 1) do={};\r\
    \nif ( \$ScriptRuningInstances >= 2) do={system script job remove [find script=\$ScriptName]};\r\
    \n\r\
    \n" policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon start-date=dec/23/2019 start-time=07:31:44

    
/system script
remove [find name=lteLogger2]
add name=lteLogger2 source="#:local watchItems pin-status,functionality,registra\
    tion-status,current-cellid,enb-id,sector-id,phy-cellid,access-technology,primary-band,ca-band,rssi\r\
    \n:local watchItems current-cellid,enb-id,primary-band,ca-band\r\
    \n:local watchFreq 3s\r\
    \n:local lteInfo\r\
    \n:local prevLteInfo ({})\r\
    \n:while (true) do={\r\
    \n\t:do {:set lteInfo [/interface lte info lte1 once as-value]} on-error={}\r\
    \n\t:foreach m in=\$watchItems do={\r\
    \n\t\t:if ((\$lteInfo->\$m)!=(\$prevLteInfo->\$m)) do={\r\
    \n\t\t\t:put (\$m.\": \".(\$prevLteInfo->\$m).\" -> \".(\$lteInfo->\$m))\r\
    \n\t\t\t:log warning (\$m.\": \".(\$prevLteInfo->\$m).\" -> \".(\$lteInfo->\$m))\r\
    \n\t\t\tlocal mpprev (\$prevLteInfo->\$m);\r\
    \n\t\t\tlocal mpnext (\$lteInfo->\$m);\r\
    \n\t\t\t:set (\$prevLteInfo->\$m) (\$lteInfo->\$m)\r\
    \n\t\t\t}\r\
    \n\t\t}\r\
    \n\t:delay \$watchFreq\r\
    \n\t}\r\
    \n\r\
    \n"
