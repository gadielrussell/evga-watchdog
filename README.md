# EVGA Precision X Watchdog

Automatically monitors and restarts EVGA Precision X to ensure GPU fans continue running.

## Problem

EVGA Precision X doesn't minimize to system tray - clicking X closes it completely, which stops GPU fan control and can lead to overheating.

## Solution

This PowerShell script monitors the Precision X process and automatically restarts it if closed.

## Features

- ✅ Monitors every 60 seconds
- ✅ Auto-restarts on closure
- ✅ Runs at Windows startup
- ✅ Logs all activity
- ✅ Auto-cleans logs older than 2 weeks

## Setup Instructions

### Step 1: Configure the Script

1. Open `EVGA_Watchdog.ps1` in a text editor
2. **Update the log file path** (line 7) with your Windows username:
   ```powershell
   $logFile = "C:\Users\YOUR_USERNAME\source\scripts\EVGA Watchdog\EVGAWatchdog.log"
   ```
   Replace `YOUR_USERNAME` with your actual Windows username
3. **Verify the Precision X path** (line 5) matches your installation:
   ```powershell
   $precisionPath = "C:\Program Files\EVGA\Precision X1\PrecisionX_x64.exe"
   ```
   - If installed in `Program Files (x86)`, update accordingly
4. Save the file

### Step 2: Create the Scheduled Task (Windows 11)

#### Method 1: Using Task Scheduler GUI

1. **Open Task Scheduler:**
   - Press `Win + R`
   - Type `taskschd.msc`
   - Press Enter

2. **Create New Task:**
   - In the right panel, click **"Create Task"** (NOT "Create Basic Task")

3. **General Tab Settings:**
   - **Name:** `EVGA Precision X Watchdog`
   - **Description:** `Monitors and restarts EVGA Precision X to maintain GPU fan control`
   - **Security options:**
     - ✅ Check **"Run only when user is logged on"** (CRITICAL - must be this option)
     - ✅ Check **"Run with highest privileges"**
   - **Configure for:** `Windows 10` (or `Windows 11` if available)

4. **Triggers Tab:**
   - Click **"New..."**
   - **Begin the task:** Select `At log on`
   - **Settings:**
     - Select **"Specific user"** (should show your username)
     - ✅ Check **"Enabled"**
   - Click **OK**

5. **Actions Tab:**
   - Click **"New..."**
   - **Action:** `Start a program`
   - **Program/script:** `powershell.exe`
   - **Add arguments:**
     ```
     -WindowStyle Hidden -ExecutionPolicy Bypass -File "C:\Users\YOUR_USERNAME\source\scripts\EVGA Watchdog\EVGA_Watchdog.ps1"
     ```
     Replace `YOUR_USERNAME` with your actual Windows username
   - Click **OK**

6. **Conditions Tab:**
   - ❌ **UNCHECK** "Start the task only if the computer is on AC power"
   - ❌ **UNCHECK** "Stop if the computer switches to battery power"
   - Leave other settings as default

7. **Settings Tab:**
   - ✅ Check **"Allow task to be run on demand"**
   - ✅ Check **"Run task as soon as possible after a scheduled start is missed"**
   - **If the task is already running:** `Do not start a new instance`
   - Leave other settings as default

8. **Finish:**
   - Click **OK**
   - You may be prompted for your password - enter it

#### Method 2: Using PowerShell (Advanced)

Run PowerShell as Administrator and execute:

```powershell
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument '-WindowStyle Hidden -ExecutionPolicy Bypass -File "C:\Users\YOUR_USERNAME\source\scripts\EVGA Watchdog\EVGA_Watchdog.ps1"'
$trigger = New-ScheduledTaskTrigger -AtLogOn -User $env:USERNAME
$principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Highest
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable

Register-ScheduledTask -TaskName "EVGA Precision X Watchdog" -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Description "Monitors and restarts EVGA Precision X to maintain GPU fan control"
```

Replace `YOUR_USERNAME` in the file path with your actual Windows username.

### Step 3: Test the Task

1. **Start the task manually:**
   - In Task Scheduler, find your task
   - Right-click → **"Run"**

2. **Verify it's running:**
   - Open Task Manager (Ctrl + Shift + Esc)
   - Look for `powershell.exe` in the process list
   - Check that EVGA Precision X is running

3. **Test the watchdog:**
   - Close EVGA Precision X
   - Wait 60 seconds
   - Precision X should automatically restart

4. **Check the logs:**
   - Navigate to: `C:\Users\YOUR_USERNAME\source\scripts\EVGA Watchdog\`
   - Open `EVGAWatchdog.log`
   - Verify entries are being logged

### Step 4: Verify Auto-Start

1. Restart your computer
2. After logging in, check that:
   - EVGA Precision X is running
   - The watchdog script is running (check Task Manager for `powershell.exe`)
   - Log file shows the watchdog started

## Troubleshooting

### Script doesn't start Precision X

**Problem:** Log shows "Precision X started successfully" but the program doesn't appear.

**Solution:** Ensure the scheduled task is set to **"Run only when user is logged on"** (NOT "Run whether user is logged on or not")

### Can't find your Windows username

Run this in PowerShell:
```powershell
echo $env:USERNAME
```

### Process name doesn't match

1. Open Task Manager
2. Go to **Details** tab
3. Look for EVGA Precision X process
4. Note the exact name (e.g., `PrecisionX_x64.exe`)
5. Update `$processName` in the script (without `.exe`)

### Script won't run - Execution Policy error

Run PowerShell as Administrator:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

## Customization

### Change monitoring interval

Edit line at bottom of script:
```powershell
Start-Sleep -Seconds 60  # Change 60 to desired seconds
```

### Change log retention period

Edit the Clean-OldLogs function:
```powershell
$cutoffDate = (Get-Date).AddDays(-14)  # Change -14 to desired days
```

## Uninstallation

1. Open Task Scheduler
2. Find "EVGA Precision X Watchdog"
3. Right-click → **Delete**
4. Delete the script folder

## License

MIT License - See LICENSE file for details

## Credits

Created to solve GPU overheating issues caused by EVGA Precision X closing unexpectedly.