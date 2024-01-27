<#
.SYNOPSIS
  Shows notifications in Windows OS.
  Notifications can be submitted by external processes via so called trigger files.
  Trigger file is a file with *.notification extension which is located in C:\Users\<user>\AppData\Local\TriggerFileNotification\notifications\to_be_shown
  Once notification is shown the trigger file is moved to C:\Users\<user>\AppData\Local\TriggerFileNotification\notifications\already_shown
  In order to use this mechanism schedule this script to be executed e.g. each minute by Windows Task Scheduler.
  So that trigger script will frequently check for a new trigger files and show notification when needed with maximum 1 minute delay

.INPUTS
  trigger file
  
.OUTPUTS
  Windows pop-up notification according to each trigger file

.NOTES
   maintained in https://github.com/artemtomchuck/GenericAutomationCodeStorage/tree/main/code/Show-TriggerFileNotifications

   dependency on BurntToast module (tested with version 0.8.5)
   to check version use: Get-InstalledModule -Name BurntToast
   To install module use: powershell as admin: Install-Module -Name BurntToast
   
   there is no cleanup of old trigger notification files implemented.
   So you need to be careful if you have a lot of notifications.
#>

Import-Module BurntToast


function Initialize-ScriptVariables {
    $ApplicationName="TriggerFileNotification"
    $script:NotificationsFolder="$env:LocalAppData\$ApplicationName\notifications"
    $script:NotificationsToBeShownFolder = "$NotificationsFolder\to_be_shown"
    $script:NotificationsAlreadyShownFolder = "$NotificationsFolder\already_shown"
}

function Initialize-Environment {
    # create directory structure if it doesn't yet exist
    New-Item -Path $NotificationsFolder -ItemType Directory -Force
    New-Item -Path $NotificationsToBeShownFolder -ItemType Directory -Force
    New-Item -Path $NotificationsAlreadyShownFolder -ItemType Directory -Force
}

function Show-TriggerFileNotifications {
    # Get all notification files in the folder
    $NotificationTriggerFileList = Get-ChildItem -Path $NotificationsToBeShownFolder -Filter *.notification -File

    foreach ($NotificationTriggerFile in $NotificationTriggerFileList) {
        
        # do not read the whole file because we can't show very big messages in notifications anyway
        $NotificationTriggerFileContentInBytes = Get-Content -Path $NotificationTriggerFile.FullName -Encoding byte -TotalCount 1000
        $NotificationTriggerFileContent = [System.Text.Encoding]::UTF8.GetString($NotificationTriggerFileContentInBytes)

        # Display notification in a format: theme, body
        New-BurntToastNotification -Text $NotificationTriggerFile.Name, $NotificationTriggerFileContent
        
        Move-Item -Path $NotificationTriggerFile.FullName -Destination $NotificationsAlreadyShownFolder
    }
}

function Start-Process {
    Initialize-ScriptVariables
    Initialize-Environment
    Show-TriggerFileNotifications
}

# entry point
Start-Process
