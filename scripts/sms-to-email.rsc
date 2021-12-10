# Source: https://forum.mikrotik.com/viewtopic.php?f=9&t=61068#p312202

# Script to forward SMS from GSM Modem Inbox to Email #
# Note: The SMS is removed from the inbox after being sent to Email, #
# even if the Email fails to be sent #
# Remember to set up /Tools/SMS with the USB port of your #
# Modem and the info channel. Put anything in secret and #
# make sure Receive Enabled is ticked #
# Tested on Rb751U RouterOS v5.12 with Huawei E367 #
# Peter James 2012-04-04 #


:local EmailAddress "your_email_address";
:local smsPhone;
:local smsTimeStamp;
:local smsMessage;
:local smsContent;

# Get System Identity #
:local SystemID [/system identity get name];

:log info "SMS to Email script started";

# Set Receive Enabled, in case it was cleared by a router reboot #
/tool sms set receive-enabled=yes;

delay 2;

# loop through all the messages in the inbox #
:foreach i in=[/tool sms inbox find] do={

:set smsPhone [/tool sms inbox get $i phone];
:set smsTimeStamp [/tool sms inbox get $i timestamp];
:set smsMessage [/tool sms inbox get $i message];

:set smsContent "Router ID: $SystemID\nSMS Received from: $smsPhone\nDate&Time: $smsTimeStamp\nMessage: $smsMessage";

:log info $smsContent;

/tool e-mail send tls=yes subject="$SystemID GSM Modem SMS Received" to=$EmailAddress body="$smsContent";

# Now remove the SMS from the inbox #
/tool sms inbox remove $i;

delay 10;

}

# clear Receive Enabled, so info channel can be used by other scripts #
/tool sms set receive-enabled=no;

:log info "SMS to Email script complete";
