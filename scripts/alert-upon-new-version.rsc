/system script
add dont-require-permissions=yes name="Alert on New Version" owner=admin source=":delay 60s\
    \n:global emailAddress \"kpothi@gmail.com\";\
    \n\
    \n/system package update;\
    \ncheck-for-updates once;\
    \n:delay 10s;\
    \n\
    \n:if ( [get status] = \"New version is available\") do=\
    \n    /tool e-mail send to=\"\$emailAddress\" subject=\"[Mikrotik] Software Up \\\
    \n    date Available\" body=\"A new update is available for your MikroTik device\"\
    \n}\
    \n"

