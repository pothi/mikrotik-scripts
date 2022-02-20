# Backup cron (schedules).

# filename: backup-cron
# policy: ftp, read, write, policy, test

:local adminEmailAddress pothi@duck.com
:local deviceIdentity [/system identity get name]

:log info "Executing the script \"backup-cron\"..."

/system scheduler export file=cron; :delay 3s

/tool e-mail send to="$adminEmailAddress" \
  subject="[Mikrotik $deviceIdentity] Backup of Cron Entries" \
  body="See the subject and the attachment." \
  file=cron.rsc; :delay 10s

:log info "An email is probably sent to $adminEmailAddress."

/file remove cron.rsc
