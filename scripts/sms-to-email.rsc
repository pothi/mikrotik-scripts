# SMS to Email

# Source: https://forum.mikrotik.com/viewtopic.php?f=9&t=61068#p312202

# Note: The SMS is removed from the inbox after sent by Email and forwarded
# even if email and forward fail! So, test it often!

:global adminEmail

:local smsPhone
:local smsMessage
:local smsTimeStamp

/tool sms inbox

:foreach receivedSMS in=[find] do={
  :set smsPhone [get $receivedSMS phone]
  :set smsMessage [get $receivedSMS message]
  :set smsTimeStamp [get $receivedSMS timestamp]

  :log info "\nSMS Received From: $smsPhone on $smsTimeStamp Message: $smsMessage"

  # Send Email to $adminEmail
  :do {
    /tool e-mail send to="$adminEmail" body="$smsMessage" \
    subject="SMS from $smsPhone at $smsTimeStamp"
  }  on-error={ :log error "SMS to Email Failed." }
  :delay 3s

  # Let's remove the SMS!
  remove $receivedSMS
}
