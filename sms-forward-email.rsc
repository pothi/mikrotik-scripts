# SMS Forward and Email

# ToDo: Shorten the timestamp.

# Source: https://forum.mikrotik.com/viewtopic.php?f=9&t=61068#p312202

# Note: The SMS is removed from the inbox after sent by Email and forwarded
# even if email and forward fail! So, test it often!

:local adminEmailAddress "pothi@duck.com"
:local smsForwardPh 9952697255

:local smsPhone
:local smsMessage
:local smsTimeStamp

/tool sms inbox

:foreach i in=[find] do={
  :set smsPhone [get $i phone]
  :set smsMessage [get $i message]
  :set smsTimeStamp [get $i timestamp]

  :log info "SMS Received From: $smsPhone at $smsTimeStamp Message: $smsMessage"

  # Forward the SMS to $smsForwardPh
  /tool sms send lte1 phone-number=$smsForwardPh message="From: $smsPhone on $smsTimeStamp Msg: $smsMessage";
  :delay 2s

  # Send Email to $adminEmailAddress
  /tool e-mail send to="$adminEmailAddress" body="$smsMessage" \
    subject="SMS from $smsPhone at $smsTimeStamp"
  :delay 3s

  remove $i
}
