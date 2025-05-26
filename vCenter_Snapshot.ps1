# Connect to vCenter
$vcServer = Read-Host "Enter vCenter Server"
Connect-VIServer -Server $vcServer

# Start a loop to handle multiple servers
do {
    # Prompt for server (VM) name and task name
    $server = Read-Host "Enter the server (VM) name"    # Prompt for $server
    $task = Read-Host "Enter the task name"             # Prompt for $task

    # Get the current date in DDMMYYYY format
    $date = Get-Date -Format "ddMMyyyy"

    # Generate the snapshot name, using a literal string with double quotes
    $snapshotName = "${date}_${server}_${task}"

    # Get the specified VM
    $vm = Get-VM -Name $server

    # Ask the user whether they want to delete previous snapshots
    $deleteSnapshots = Read-Host "Do you want to delete all existing snapshots for $server? (yes/no)"

    if ($deleteSnapshots -eq "y") {
        # Remove all snapshots for the specified VM
        Write-Host "Removing all snapshots for $server..." -ForegroundColor Yellow
        Get-Snapshot -VM $vm | Remove-Snapshot -Confirm:$false
        Write-Host "All snapshots for $server have been removed." -ForegroundColor Green
    } else {
        Write-Host "Skipping snapshot deletion." -ForegroundColor Cyan
    }

    # Create a new snapshot without memory
    Write-Host "Creating a new snapshot '$snapshotName' for $server..." -ForegroundColor Yellow
    New-Snapshot -VM $vm -Name $snapshotName -Description "Snapshot for $task on $date" -Memory:$false

    Write-Host "Task completed. New snapshot '$snapshotName' created." -ForegroundColor Green

    # Ask if another server needs a snapshot
    $anotherServer = Read-Host "Do you need to create a snapshot for another server? (yes/no)"

} while ($anotherServer -eq "y")

# Disconnect from vCenter
Disconnect-VIServer -Confirm:$false

Write-Host "All tasks completed. Disconnected from vCenter." -ForegroundColor Green
