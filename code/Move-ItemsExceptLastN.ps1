# maintained in https://github.com/artemtomchuck/GenericAutomationCodeStorage/blob/main/code/Move-ItemsExceptLastN.ps1

# Moves items (directories, files) from $sourceDirectory to $destinationDirectory.
# Retains last N items defined in $numberOfLastItemsToKeep. Last N order is alphabetical.
# Logs result of its work into $logDirectory

param (
    [Parameter(Mandatory=$True)] [string]$sourceDirectory,
    [Parameter(Mandatory=$True)] [string]$destinationDirectory,
    [Parameter(Mandatory=$True)] [int]$numberOfLastItemsToKeep,
    [Parameter(Mandatory=$True)] [string]$logDirectory
)

$logFilePath = $logDirectory + '\' + (Get-Date -Format "yyyyMMdd_HHmmss") + '_backup_archiving.log'

# Doesn't include hidden files
$itemsToMove = Get-ChildItem -Path $sourceDirectory | Sort-Object -Property Name -Descending | Select-Object -Skip $numberOfLastItemsToKeep

foreach ($itemToMove in $itemsToMove) {

    $sourcePath = $itemToMove.FullName
    $destinationPath = Join-Path -Path $destinationDirectory -ChildPath $itemToMove.Name

    Move-Item -Path $sourcePath -Destination $destinationPath

    $logEntry = "Moved: '$sourcePath' to '$destinationPath'"
    $logEntry | Out-File -Append -FilePath $logFilePath
}
