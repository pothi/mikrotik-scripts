# SMS to SMS

# Limitation: It just forwards the SMS. It doesn't forward the senderPhoneNumber or timestamp of received SMS.

# Source: https://forum.mikrotik.com/viewtopic.php?f=9&t=61068#p312202

:global adminPh
:local smsForwardPh $adminPh

:local smsPhone
:local smsMessage
:local smsTimeStamp

/tool sms inbox

:foreach receivedSMS in=[find] do={
  :set smsPhone [get $receivedSMS phone]
  :set smsMessage [get $receivedSMS message]
  :set smsTimeStamp [get $receivedSMS timestamp]

  :log info "\nSMS Received From: $smsPhone on $smsTimeStamp Message: $smsMessage"

  # Forward the SMS to $smsForwardPh, without $smsPhone and smsTimeStamp
  :do {
    /tool sms send lte1 phone-number=$smsForwardPh message=$smsMessage
  } on-error={ :log error "SMS to SMS Failed." }
  :delay 2s

  # Let's NOT remove the SMS!
  # Let the other script (SMS to Email) remove it, after sending the message with full details.
  # remove $receivedSMS
}
