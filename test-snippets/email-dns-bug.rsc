# How to reproduce
#   1. Configure email sending.
#   2. Turn off DNS servers and/or DoH server
#   3. Clear DNS cache
#   4. Run this script
#   5. On ideal conditions, we'd get "A friendly message" in the log
#   6. Due to bug, we get nothing we email sending fails upon DNS failure.

# :do {
  # /tool e-mail send to=kpothi@gmail.com body="Body Message" subject="Sample subject"
# }  on-error={ :log error "A friendly message" }

:onerror errMsg in={
  /tool e-mail send to=name@example.com body="msg" subject="test"
} do={ :error "Email sending failure: $errMsg" }

:log warn "This message should not be shown, if email sending fails upon DNS failure."
