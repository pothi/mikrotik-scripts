# Cloud Backup

# requirement/s:
:global cloudPass
:if ([:typeof $cloudPass] = "nothing" || $cloudPass = "") do={
  :log error "cloudPass is not defined or nil."; :error "Error: Check the log"; }

# permissions required: ftp, read, write, policy, test

:log info "\nCreating a new cloud backup..."

/system backup cloud

# Remove the backup if exists.
:if ( ([:pick [print as-value] 0]->"status") = "ok" ) do={

  remove-file number=0
  :delay 3s
  :log info "  Existing cloud backup is removed to create space for a new backup."

} else={ :log info "  No existing cloud backup found."; }

:log info "  A new cloud backup is being created..."

  upload-file action=create-and-upload password=$cloudPass
  :delay 30s

:if ( ([:pick [print as-value] 0]->"status") = "ok" ) do={
  :log info "Cloud backup is successful."
} else={ :log error "Cloud backup failed!" }
