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

## Setup
1. Update the path in the script to match your Precision X installation
2. Create a scheduled task to run at logon
3. Set to 'Run only when user is logged on'
4. Enable 'Run with highest privileges'
