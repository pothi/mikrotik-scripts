# Cloud Backup

# requirement/s:
:global cloudBackupPass

# permissions required: ftp, read, write, policy, test

:local backupName "Cloud Backup"

:log info "\nRunning the script \"cloud-backup\"..."

/system backup cloud

# Remove the backup if exists.
:if ( ([:pick [print as-value] 0]->"status") = "ok" ) do={

  remove-file number=0
  :delay 3s
  :log info "Existing $backupName is removed to create-and-upload a new backup."

} else={ :log info "No existing $backupName found."; }

:log info "Creating a new $backupName..."

  upload-file action=create-and-upload password=$cloudBackupPass
  :delay 10s

:if ( ([:pick [print as-value] 0]->"status") = "ok" ) do={
  :log info "$backupName is successful."
} else={ :log error "$backupName failed!" }
