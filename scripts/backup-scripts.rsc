# Backup scripts.

# filename: backup-scripts
# policy: ftp, read, write, policy, test

:local adminEmailAddress "admin@example.com"
:local deviceIdentity [/system identity get name]

:log info "Executing the script \"backup-scripts\"..."

/system script export file=scripts; :delay 3s

/tool e-mail send to="$adminEmailAddress" \
  subject="[Mikrotik $deviceIdentity] Backup of Scripts" \
  body="See the subject and the attachment." \
  file=scripts.rsc; :delay 10s

:log info "An email is probably sent to $adminEmailAddress."

/file remove scripts.rsc
