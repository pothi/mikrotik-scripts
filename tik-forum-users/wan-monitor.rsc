# ref: https://forum.mikrotik.com/viewtopic.php?p=671934
# date: Feb 2018

:if ([:len [/system scheduler find name=wanmonitor]]=0) do={
    :log warning "creating wan monitor scheduler"
    /system scheduler add name=wanmonitor interval=1h on-event="/system script run wanmonitor" start-time=startup comment="'wanmonitor' checking internet connection(s)"
} else={
    :if ([/system scheduler get value-name=on-event [/system scheduler find name=wanmonitor]]!="/system script run wanmonitor") do={
        :log warning "updating wan monitor scheduler"
        /system scheduler set on-event="/system script run wanmonitor" [/system scheduler find name=wanmonitor]
    }
}

:local wmCheck do={
    #Configuration
    :local fconfig [:parse [/system script get wanmonitor.cfg source]]
    :local cfg [$fconfig]
    :local WANS ($cfg->"Interfaces")
    :local RUNONUP ($cfg->"ScriptOnUp")
    :local STORAGE ($cfg->"Storage")
    :local TGID ($cfg->"Telegram")

    #Inputs
    :local Wan [:tostr $1]
    :local Hosts [:toarray $2]
    :if ([:len $Hosts]=0) do={
        :set $Hosts "64.6.64.6,4.2.2.1"
    }

    #Settings
    :local Runtime 0
    :local Retries 2

    #Counters
    :local Checks 0
    :local Failures 0

    #telegram command
    :local telegram
    :if ([:len [/system script find name=telegram]]>0) do={
        :set telegram [:parse [/system script get telegram source]]
    }

    ## Get gateway ip address
    :local wmGateway do={
        :if ([:len [/ip dhcp-client find where interface=$wan]]>0) do={
            :return [/ip dhcp-client get value-name=gateway [find interface=[:tostr $wan]]]
        } else={
            :return [$wan]
        }
    }

    ## Get public ip
    :local wmAddress do={
        ## Check if interface have dhcp-client return address via myip.dnsomatic.com
        :if ([:len [/ip dhcp-client find where interface=$wan]]>0) do={
            :local count 0
            :local wgate [/ip dhcp-client get value-name=gateway [find interface=[:tostr $wan]]]
            /ip route add comment="tempory route for 'dnsomatic.com'..." distance=1 dst-address=[:resolve "myip.dnsomatic.com"] gateway=$wgate
            /ip route add comment="tempory route for 'dnsomatic.com'..." distance=2 dst-address=[:resolve "myip.dnsomatic.com"] type=blackhole
            :while (([:len [/file find name="wan.ip"]]=0) and ($count<10)) do={
                :delay 1s
                /tool fetch url="http://myip.dnsomatic.com/" mode=http dst-path="wan.ip"
                :set count ($count+1)
            }
            /ip route remove [/ip route find where comment="tempory route for 'dnsomatic.com'..."]
            :if ([:len [/file find name="wan.ip"]]>0) do={
                :local results [file get "wan.ip" contents];
                /file remove [/file find name="wan.ip"]
                :return $results
            }
        }
        ## Check if interface have ip address
        :if ([:typeof [/ip address get value-name=address [/ip address find interface=$wan]]]!="nil") do={
            :return [:pick [/ip address get value-name=address [/ip address find interface=$wan]] 0 [:find [/ip address get value-name=address [/ip address find interface=$wan]] "/"]]
        } else={
            :return "0.0.0.0"
        }
    }

    ## Wan enable/disable
    :local wmMode do={
        :local count
        ## Set firewall nat 'masquerade' enable or disable
        :if ([:len [/ip firewall nat find where out-interface=$wan and action=masquerade]]>0) do={
            if ([:tostr $mode]="enable") do={
                :local masquerade false
            } else={
                :local masquerade true
            }
            /ip firewall nat set disabled=$masquerade [/ip firewall nat find where out-interface=$wan and action=masquerade]
        }
        ## Set add-default-route yes or no / true or false
        :if ([:pick [/interface get value-name=type $wan] ([:find [/interface get value-name=type $wan] "-"]+1) [:len [/interface get value-name=type $wan]]]="out") do={
            :local drc
            if ([:tostr $mode]="enable") do={
                :set $drc true
            } else={
                :set $drc false
            }
            :if (([:pick [/interface get value-name=type $wan] 0 [:find [/interface get value-name=type $wan] "-"]]="pppoe") && ([/interface pppoe-client get value-name=add-default-route $wan]!=$drc)) do={
                /interface pppoe-client set add-default-route=$drc $wan
            }
            :if (([:pick [/interface get value-name=type $wan] 0 [:find [/interface get value-name=type $wan] "-"]]="l2tp") && ([/interface l2tp-client get value-name=add-default-route $wan]!=$drc)) do={
                /interface l2tp-client set add-default-route=$drc $wan
            }
            :if (([:pick [/interface get value-name=type $wan] 0 [:find [/interface get value-name=type $wan] "-"]]="ppp") && ([/interface ppp-client get value-name=add-default-route $wan]!=$drc)) do={
                /interface ppp-client set add-default-route=$drc $wan
            }
            :if (([:pick [/interface get value-name=type $wan] 0 [:find [/interface get value-name=type $wan] "-"]]="sstp") && ([/interface sstp-client get value-name=add-default-route $wan]!=$drc)) do={
                /interface sstp-client set add-default-route=$drc $wan
            }
            :log warning ("interface $[:pick [/interface get value-name=type $wan] 0 [:find [/interface get value-name=type $wan] "-"]]-client '$wan' set 'add-default-route' to '$drc'");
        } else={
            :if ([:len [/ip dhcp-client find interface=$wan]]>0) do={
                :local drd
                if ([:tostr $mode]="enable") do={
                    :set $drd "yes"
                } else={
                    :set $drd "no"
                }
                :if ([/ip dhcp-client get value-name=add-default-route [/ip dhcp-client find interface=$wan]]!=$drd) do={
                    /ip dhcp-client set add-default-route=$drd [/ip dhcp-client find interface=$wan]
                    :log warning ("'$wan' dhcp-client (".[/interface get value-name=type $wan].") set 'add-default-route' to '$drd'")
                }
            }
        }
    }

    ## Reset interface
    :local wmReset do={
        :local count
        :if ([/interface get value-name=type $wan]="lte") do={
            /system routerboard usb power-reset duration=1s
            :log warning "usb power ('$wan') reset..."
            :delay 3s
            :set count 0
            :while (([:len [/interface find name=$wan]]=0) and ($count<30)) do={
                :delay 1s
                :set count ($count+1)
            }
            :log warning "usb device ('$wan') was connected"
            :set count 0
            :while (([/interface get value-name=running [/interface find name=$wan]]=false) and ($count<30)) do={
                :delay 1s
                :set count ($count+1)
            }
            :log warning "interface ('$wan') is running"
            :delay 3s
            :if ([:len [/ip dhcp-client find interface=$wan]]>0) do={
                :delay 3s
                :set count 0
                :while (([/ip dhcp-client get value-name=status [/ip dhcp-client find interface=$wan]]!="bound") and ($count<30)) do={
                    :delay 1s
                    :set count ($count+1)
                }
                :log warning "dhcp-client ('$wan') bounded"
            }
        } else={
            /interface disable $wan
            :log warning "interface '$wan' was disabled"
            :delay 500ms
            /interface enable $wan;
            :log warning "interface '$wan' was enabled"
            :delay 3s
            :if ([:len [/ip dhcp-client find interface=$wan]]>0) do={
                :set count 0
                :while (([/ip dhcp-client get value-name=status [/ip dhcp-client find interface=$wan]]!="bound") and ($count<30)) do={
                    :delay 1s
                    :set count ($count+1)
                }
                :log warning "dhcp-client ('$wan') bounded"
                :delay 3s
            }
            :if ([:pick [/interface get value-name=type $wan] ([:find [/interface get value-name=type $wan] "-"]+1) [:len [/interface get value-name=type $wan]]]="out") do={
                :set count 0
                :while (([/interface get value-name=running [/interface find name=$wan]]=false) and ($count<30)) do={
                    :delay 1s
                    :set count ($count+1)
                }
                :log warning "interface ('$wan') is running"
                :delay 3s
            }
        }
    }

    ## PPP profile script
    :local onConnected do={
        ## Add script to ppp profile on up ('connected')
        :if ([:pick [/interface get value-name=type $wan] ([:find [/interface get value-name=type $wan] "-"]+1) [:len [/interface get value-name=type $wan]]]="out") do={
            :local script "/interface $[:pick [/interface get value-name=type $wan] 0 [:find [/interface get value-name=type $wan] "-"]]-client monitor $wan once do={\n    :local uptime ([:tonum [:pick [:tostr \$uptime] 0 2]]*60*60+[:tonum [:pick [:tostr \$uptime] 3 5]]*60+[:tonum [:pick [:tostr \$uptime] 6 8]])\n}\n:if (\$uptime<3) do={\n   /tool netwatch remove [/tool netwatch find comment=$wan]\n  :local script [:parse [/system script get wanmonitor source]]\n \$script wan=$wan hosts=$[:tostr $hosts]\n\n}"
            :if (([:pick [/interface get value-name=type $wan] 0 [:find [/interface get value-name=type $wan] "-"]]="pppoe") and ([:typeof [:find [/ppp profile get value-name=on-up [/interface pppoe-client get value-name=profile $wan]] "\$script wan=$wan"]]="nil")) do={
                /ppp profile set on-up=([/ppp profile get value-name=on-up [/interface pppoe-client get value-name=profile $wan]]."\n".$script) [/interface pppoe-client get value-name=profile $wan]
            }
            :if (([:pick [/interface get value-name=type $wan] 0 [:find [/interface get value-name=type $wan] "-"]]="l2tp") and ([:typeof [:find [/ppp profile get value-name=on-up [/interface l2tp-client get value-name=profile $wan]] "\$script wan=$wan"]]="nil")) do={
                /ppp profile set on-up=([/ppp profile get value-name=on-up [/interface l2tp-client get value-name=profile $wan]]."\n".$script) [/interface l2tp-client get value-name=profile $wan]
            }
            :if (([:pick [/interface get value-name=type $wan] 0 [:find [/interface get value-name=type $wan] "-"]]="ppp") and ([:typeof [:find [/ppp profile get value-name=on-up [/interface ppp-client get value-name=profile $wan]] "\$script wan=$wan"]]="nil")) do={
                /ppp profile set on-up=([/ppp profile get value-name=on-up [/interface ppp-client get value-name=profile $wan]]."\n".$script) [/interface ppp-client get value-name=profile $wan]
            }
            :if (([:pick [/interface get value-name=type $wan] 0 [:find [/interface get value-name=type $wan] "-"]]="sstp") and ([:typeof [:find [/ppp profile get value-name=on-up [/interface sstp-client get value-name=profile $wan]] "\$script wan=$wan"]]="nil")) do={
                /ppp profile set on-up=([/ppp profile get value-name=on-up [/interface sstp-client get value-name=profile $wan]]."\n".$script) [/interface sstp-client get value-name=profile $wan]
            }
        }
        ## Add script to dhcp-client on up ('bound')
        :if (([:len [/ip dhcp-client find interface=$wan]]>0) and ([:typeof [:find [/ip dhcp-client get value-name=script [/ip dhcp-client find interface=$wan]] "\$script wan=$wan"]]="nil")) do={
            /ip dhcp-client set script=("/tool netwatch remove [/tool netwatch find comment=$wan]\n:if ([/ip dhcp-client get value-name=status [/ip dhcp-client find interface=$wan]]=\"bound\") do={\n :delay 5m\n :local script [:parse [/system script get wanmonitor source]]\n \$script wan=$wan hosts=$[:tostr $hosts]\n\n}") [/ip dhcp-client find interface=$wan]
        }
    }

    ## Create netwatch
    :local addNetwatch do={
        :local ondown (":local script [:parse [/system script get wanmonitor source]]\n\$script wan=$wan hosts=".[:tostr $hosts]."\n\n");
        :if ($watch!="0.0.0.0") do={
            # Create netwatch per hosts, if not exists
            :if ([:len [/tool netwatch find where host=$watch]]=0) do={
                /tool netwatch add host=$watch down-script=$ondown comment=$wan
                /tool netwatch set down-script=("/tool netwatch remove ".[/tool netwatch find where host=$watch]."\n\n".[/tool netwatch get value-name=down-script [/tool netwatch find where host=$watch]]) [/tool netwatch find where host=$watch]
                :log info ("'$watch' netwatch has been created by script.")
            } else={
                # Set netwatch self remove, if not exists
                :if ([:typeof [:find [/tool netwatch get value-name="down-script" [/tool netwatch find host=$watch]] ("/tool netwatch remove ".[/tool netwatch find where host=$watch])]]="nil") do={
                    /tool netwatch set down-script=("/tool netwatch remove ".[/tool netwatch find where host=$watch]."\n".[/tool netwatch get value-name=down-script [/tool netwatch find where host=$watch]]) comment=("internet access via '$wan' enabled from ".[/system clock get time]." ".[/system clock get date]) [/tool netwatch find where host=$watch]
                }
                # Set append on-down event (run script), if 'wanmonitor' not exists
                :if ([:typeof [:find [/tool netwatch get value-name="down-script" [/tool netwatch find host=$watch]] "wanmonitor"]]="nil") do={
                    /tool netwatch set down-script=($ondown.[/tool netwatch get value-name="down-script" [/tool netwatch find host=$watch]]) [/tool netwatch find host=$watch];
                }
                :log info ("'$watch' netwatch has been updated by script.");
            }
            # Set log 'error' when host is down
            :if ([:typeof [:find [/tool netwatch get value-name="down-script" [/tool netwatch find host=$watch]] ("/log error \"'$wan' was down.\"\n")]]="nil") do={
                /tool netwatch set down-script=(("/log error \"'$wan' was down.\"\n").[/tool netwatch get value-name="down-script" [/tool netwatch find host=$watch]]) [/tool netwatch find host=$watch];
            }
        }
    }

    ## Add scheduler
    :local AddScheduler do={
        :local schname [:tostr $1]
        :local schcode [:tostr $2]
        :local schtime [:tonum $3]
        :if ([:len $3]=0) do={
            :set $schtime 3600
        }
        :if ([:len [/system scheduler find name=$schname]]=0) do={
            :log info ("scheduler '$schname' has been created and set to ".($schtime/60)."minutes");
            /system scheduler add interval=$schtime on-event=$schcode comment=("recheck '$schname' for internet access every ".($schtime/60)." minutes.") name=$schname
        } else={
            :if ([:typeof [:find [/system scheduler get value-name="on-event" [/system scheduler find where name=$schname]] $schcode]]="nil") do={
                /system scheduler set interval=$schtime on-event=([/system scheduler get value-name=on-event $schname].$schcode) [/system scheduler find where name=$schname]
                :log info ("scheduler '$schname' has been updated and set to ".($schtime/60)."minutes");
            }
        }
    }

    ## Add PPP script on up and DHCP Client script on up
    $onConnected wan=$Wan hosts=$Hosts

    ## Check if interface exists, bound and enabled
    :if ((([:len [/interface find where name=$Wan]]>0) and ([/interface get value-name=running [/interface find name=$Wan]]=true) and ([/interface get value-name="disabled" $Wan]=false) and ([:len [/ip address find interface=$Wan]]>0)) and (([:len [/ip dhcp-client find interface=$Wan]]=0) or ([/ip dhcp-client get value-name=status [/ip dhcp-client find interface=$Wan]]="bound"))) do={
        ## Add IP routes rules to interface
        :foreach Host in=[:toarray $Hosts] do={
            #Tempory write IP route to check specific connection
            /ip route add comment="tempory route for internet access checking..." distance=1 dst-address=$Host gateway=[$wmGateway wan=$Wan]
            /ip route add comment="tempory route for internet access checking..." distance=2 dst-address=$Host type=blackhole
        }
        :delay 750ms;
        ## Check interface's connection by ping to hosts
        :foreach Host in=[:toarray $Hosts] do={
            :for Runtime from=1 to=$Retries do={
                :if ([/ping $Host count=1]=0) do={
                    :set Failures ($Failures + 1);
                    :log error "'$Wan' ping to $Host failed ($Runtime/$Retries).";
                    /beep frequency=80 length=20ms
                } else={
                    :log info "'$Wan' ping to $Host succeeded ($Runtime/$Retries).";
                    :set $WatchIp $Host;
                    /beep frequency=20 length=80ms
                }
                :set Checks ($Checks + 1);
                :delay 500ms;
            }
            :delay 800ms;
        }
    } else={
        :set Failures $Checks
    }
    ## Remove IP routes rules
    /ip route remove [/ip route find where comment="tempory route for internet access checking..."]
    :if ($Failures=$Checks) do={
        :log error "internet access not available via '$Wan'!"
        $wmMode mode=disable wan=$Wan
        :if ([:len [/system scheduler find name=$Wan]]=0) do={
            $telegram action=send chat=$TGID text=("Internet access *not available* via *'$Wan'*")
        }
        :if ([:len [/system scheduler find name=$Wan]]=0) do={
            $wmReset wan=$Wan
        }
        $AddScheduler $Wan (":local script [:parse [/system script get wanmonitor source]]\n\$script wan=$Wan hosts=".[:tostr $Hosts]."\n") 300
        :return false;
    } else={
        $wmMode mode=enable wan=$Wan
        ## Check currect status and update (comment) if necessary
        if ([:len [/tool netwatch find comment=$Wan]]=0) do={
            :if ([:len [/system scheduler find name=$Wan]]>0) do={
                /system scheduler remove [/system scheduler find name=$Wan]
                :log warning "'$Wan' scheduler has been removed"
            }
            :local publicip [$wmAddress wan=$Wan]
            $addNetwatch wan=$Wan hosts=$Hosts watch=$publicip
            :foreach script in=[:toarray $RUNONUP] do={
                :if ([:len [/system script find name=$script]]>0) do={
                    :set script [:parse [/system script get $script source]]
                    :if ([:find $WANS $Wan]=0) do={
                        $script
                    } else={
                        $script interface=$Wan
                    }
                }
            }
            $telegram action=send chat=$TGID text=("Internet access *available* via *'$Wan'* ($publicip)")
        }
        :return true
    }
}

:if ([:len $wan]>0) do={
    :log info "Check for available internet access via '$wan' interface ...";
    if ([$wmCheck $wan $hosts]=false) do={
        ## Interface's connection failed
        :log error "'$wan' failed, No internet access available.";
    } else={
        ## Interface's connection check succeed
        :log info ("'$wan' succeed, Internet access available.");
    }
} else={
    :local fconfig [:parse [/system script get wanmonitor.cfg source]]
    :local cfg [$fconfig]
    :local WANS ($cfg->"Interfaces")
    ## If interfaces not set manually, searching for clients/dialup connections (pppoe, l2tp, ppp, sstp)
    if ([:len $WANS]=0) do={
        :foreach idn in=[/interface find where type="pppoe-out" and disabled=no or type="l2tp-out" and disabled=no or type="ppp-out" and disabled=no or type="sstp-out" and disabled=no] do={
            :log info ([/interface get value-name=name $idn]." detected has internet interface");
            if ([:len $WANS]=0) do={
                :set $WANS ([/interface get value-name=name $idn]);
            } else={
                :set $WANS ($WANS.",".[/interface get value-name=name $idn]);
            }
        }
        :foreach idn in=[/ip dhcp-client find where add-default-route="yes" and status="bound" and disabled=no] do={
            :log info ([/interface get value-name=name $idn]." detected has internet interface");
            :if ([/interface get value-name=type $idn]="ether") do={
                if ([:len $WANS]=0) do={
                    :set $WANS ([/ip dhcp-client get value-name=interface $idn]);
                } else={
                    :set $WANS ($WANS.",".[/ip dhcp-client get value-name=interface $idn]);
                }
            }
        }
    }
    ## Check clients (ppp/pppoe/l2tp/sstp)
    :foreach wan in=[:toarray $WANS] do={
        :set $wan [/interface get $wan name];
        :if (([:len [/interface find name=$wan]]>0) and ([/interface get value-name="disabled" $wan]=false)) do={
            :if ([:len [/tool netwatch find comment=$wan]]=0) do={
                ## Check interface connection
                :log info "Check for available internet access via '$wan' interface ...";
                if ([$wmCheck $wan]=false) do={
                    ## Interface's connection failed
                    :log error "'$wan' failed, No internet access available.";
                } else={
                    ## Interface's connection check succeed
                    :log info ("'$wan' succeed, Internet access available.");
                }
            }
        } else={
            :log info ("'$wan' disabled, No internet access available.");
        }
    }
}
