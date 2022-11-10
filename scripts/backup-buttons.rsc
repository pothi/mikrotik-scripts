# Backup button configurations - reset button, mode button.

# filename: backup-button-config
# policy: ftp, read, write, policy, test

:global adminEmail
:if ([:typeof $adminEmail] = "nothing" || $adminEmail = "") do={
  :log error "adminEmail is not defined or nil."; :error "Error: Check the log"; }

:local backupName "buttons"

:local fileName "$backupName.rsc"
:local emailStatus

:log info "\nCreating a $backupName backup..."

# remove existing file, if exists for unknown reason
/file remove [find name=$fileName]; :delay 1s

# export relevant info
/system routerboard
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
}

/file remove $fileName
