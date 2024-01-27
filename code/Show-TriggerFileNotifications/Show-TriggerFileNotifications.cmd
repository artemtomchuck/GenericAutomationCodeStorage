REM this is just a caller script in order to make Powershell call easier

SET FolderWithThisCmdScript=%~dp0
SET MainPowershellFileExecutableFullPath="%FolderWithThisCmdScript%\Show-TriggerFileNotifications.ps1"

REM the main call
powershell -executionpolicy bypass -File %MainPowershellFileExecutableFullPath%
