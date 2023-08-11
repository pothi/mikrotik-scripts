# Backup IP Leases in DHCP Server.

# filename: backup-leases
# policy: ftp, read, write, policy, test

:global adminEmail
:if ([:typeof $adminEmail] = "nothing" || $adminEmail = "") do={
  :log error "adminEmail is not defined or nil."; :error "Error: Check the log"; }

:local backupName "leases"

# :global scriptsBackupTaken
# :if ([:typeof $scriptsBackupTaken] = "nothing" || $adminEmail = "") do={ :set scriptsBackupTaken false }
# :if ($scriptsBackupTaken = true) do={ :error "Backup of $backupName is already taken since last reboot!" }

:local fileName "$backupName.rsc"

:local emailStatus

# remove existing file, if exists for unknown reason
/file remove [find name=$fileName]; :delay 3s

:log info "Creating a $backupName backup..."

# take a backup
/ip dhcp-server lease
  export file=$fileName
:delay 3s

/tool e-mail

:do { send to="$adminEmail" subject="Backup of $backupName" \
    body="See the subject and the attachment." file=$fileName
  } on-error={ :log error "Error sending email." }

:do { :delay 5s; :set emailStatus [get last-status] } while=( $emailStatus = "in-progress" )

:if ( $emailStatus = "failed" ) do={
  :log error "Backup failed!"
} else={
  :log info "Backup is taken and is sent to $adminEmail."
#   :set scriptsBackupTaken true
}

# Optional
:delay 5s; /file remove $fileName
