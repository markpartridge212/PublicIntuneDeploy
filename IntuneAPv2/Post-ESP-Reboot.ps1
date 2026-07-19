# Link Up ICT - APv2 Post-ESP Reboot Script
# Purpose:
# Runs once from a scheduled task and reboots the device after provisioning.
#
# Safety:
# - Creates a marker file before rebooting.
# - Removes the scheduled task before rebooting.
# - Prevents reboot loops.

$ErrorActionPreference = "Stop"

$TaskName = "Post-ESP-Reboot"
$BasePath = "C:\ProgramData\LinkUpICT\APv2"
$LogPath = "C:\ProgramData\LinkUpICT\Logs"
$MarkerFile = Join-Path $BasePath "PostESPRebootCompleted.txt"
$LogFile = Join-Path $LogPath "PostESPReboot.log"

New-Item -ItemType Directory -Path $BasePath -Force | Out-Null
New-Item -ItemType Directory -Path $LogPath -Force | Out-Null

function Write-Log {
    param (
        [string]$Message
    )

    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$Timestamp - $Message" | Out-File -FilePath $LogFile -Append -Encoding UTF8
}

try {
    Write-Log "Post-ESP reboot script started."

    if (Test-Path $MarkerFile) {
        Write-Log "Marker file already exists. Reboot already completed. Exiting."

        try {
            Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -ErrorAction SilentlyContinue
            Write-Log "Scheduled task removed."
        }
        catch {
            Write-Log "Scheduled task removal skipped or failed: $($_.Exception.Message)"
        }

        exit 0
    }

    Write-Log "Creating reboot completion marker."
    New-Item -ItemType File -Path $MarkerFile -Force | Out-Null

    Write-Log "Removing scheduled task before reboot."
    Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -ErrorAction SilentlyContinue

    Write-Log "Waiting 10 seconds before reboot."
    Start-Sleep -Seconds 10

    Write-Log "Restarting device now."
    Restart-Computer -Force

    exit 0
}
catch {
    Write-Log "Post-ESP reboot script failed: $($_.Exception.Message)"
    exit 1
}
