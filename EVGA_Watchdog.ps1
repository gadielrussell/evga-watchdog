# EVGA Precision X Watchdog Script v3
# This script monitors and restarts EVGA Precision X if it closes

# Path to EVGA Precision X - MODIFY THIS to match your installation path
$precisionPath = "C:\Program Files\EVGA\Precision X1\PrecisionX_x64.exe"
# Log file location
$logFile = "C:\Users\...\source\scripts\EVGA Watchdog\EVGAWatchdog.log"
# Process name to monitor
$processName = "PrecisionX_x64"

# Function to write log entries
function Write-Log {
    param($Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $Message" | Out-File -FilePath $logFile -Append
}

# Function to clean old log entries (older than 2 weeks)
function Clean-OldLogs {
    if (Test-Path $logFile) {
        try {
            $cutoffDate = (Get-Date).AddDays(-14)
            $allLines = Get-Content $logFile
            $newLines = @()
            
            foreach ($line in $allLines) {
                # Extract timestamp from log line (format: yyyy-MM-dd HH:mm:ss)
                if ($line -match '^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}') {
                    $logDateStr = $line.Substring(0, 19)
                    try {
                        $logDate = [DateTime]::ParseExact($logDateStr, "yyyy-MM-dd HH:mm:ss", $null)
                        if ($logDate -ge $cutoffDate) {
                            $newLines += $line
                        }
                    }
                    catch {
                        # If we can't parse the date, keep the line
                        $newLines += $line
                    }
                }
                else {
                    # Keep lines without timestamps
                    $newLines += $line
                }
            }
            
            # Write cleaned logs back to file
            $newLines | Out-File -FilePath $logFile -Force
            Write-Log "Log cleanup completed - removed entries older than 2 weeks"
        }
        catch {
            Write-Log "ERROR during log cleanup: $_"
        }
    }
}

Write-Log "EVGA Precision X Watchdog started"

# Track when we last cleaned the logs
$lastCleanup = Get-Date

# Run indefinitely
while ($true) {
    # Check if it's time to clean logs (once per day)
    $now = Get-Date
    if (($now - $lastCleanup).TotalHours -ge 24) {
        Clean-OldLogs
        $lastCleanup = $now
    }
    
    # Check if Precision X is running
    $process = Get-Process -Name $processName -ErrorAction SilentlyContinue
    
    if ($null -eq $process) {
        Write-Log "Precision X not running - attempting to start"
        
        # Check if the executable exists
        if (Test-Path $precisionPath) {
            try {
                # Simple direct start with shell execute
                $psi = New-Object System.Diagnostics.ProcessStartInfo
                $psi.FileName = $precisionPath
                $psi.UseShellExecute = $true
                $psi.Verb = "runas"  # Run as administrator
                $psi.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Normal
                
                [System.Diagnostics.Process]::Start($psi) | Out-Null
                
                Write-Log "Precision X start command executed"
                
                # Verify it started
                Start-Sleep -Seconds 3
                $verifyProcess = Get-Process -Name $processName -ErrorAction SilentlyContinue
                if ($verifyProcess) {
                    Write-Log "VERIFIED: Precision X is now running (PID: $($verifyProcess.Id))"
                }
                else {
                    Write-Log "WARNING: Start command executed but process not detected"
                }
            }
            catch {
                Write-Log "ERROR: Failed to start Precision X - $_"
            }
        }
        else {
            Write-Log "ERROR: Precision X executable not found at: $precisionPath"
        }
    }
    
    # Wait 60 seconds before checking again
    Start-Sleep -Seconds 60
}