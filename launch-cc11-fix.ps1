#! /mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe
# launch-cc11-fix.ps1
# Starts the midi filtering to remove bad cc11 messages from Komplete Kontrol keyboard.
# Connect the DAW to the 'midi-filtered-cc11' device instead of the normal keyboard device.

# Function to start the Python script
function Start-PythonScript {
    Write-Output "Starting filter_cc11..."
    $pythonPath = "C:\ProgramData\chocolatey\bin\python3.12.exe"  # Adjust the path if necessary
    $scriptPath = "C:\projects\cc11-fix\filter_cc11.py"  # Adjust the path if necessary
    $uniqueArg = "--unique-cc11-filter"

    if (Test-Path $pythonPath) {
        if (Test-Path $scriptPath) {
            try {
                Start-Process -FilePath $pythonPath -ArgumentList "$scriptPath $uniqueArg run" -WindowStyle Hidden
                Write-Output "Python script started successfully."
            } catch {
                Write-Error "Failed to start Python script: $_"
                exit 1
            }
        } else {
            Write-Error "Python script not found at $scriptPath."
            exit 1
        }
    } else {
        Write-Error "Python executable not found at $pythonPath."
        exit 1
    }
}

# Function to check for an existing instance using a unique argument
function Test-ExistingInstance {
    $uniqueArg = "--unique-cc11-filter"
    $scriptName = "filter_cc11.py"
    Write-Output "Checking for existing instances with script: $scriptName and argument: $uniqueArg"

    # Log all running processes with their command line arguments using WMI
    $existingProcesses = Get-WmiObject Win32_Process | Where-Object {
        $_.Name -like "*python*" -and $_.CommandLine -like "*$scriptName*" -and $_.CommandLine -like "*$uniqueArg*"
    }

    if ($existingProcesses) {
        Write-Output "Found existing processes:"
        $existingProcesses | ForEach-Object { Write-Output "Process ID: $($_.ProcessId), Command Line: $($_.CommandLine)" }
    } else {
        Write-Output "No existing processes found."
    }

    if ($existingProcesses.Count -gt 0) {
        Write-Warning "Another instance of the script is already running."
        $response = Read-Host "Do you want to terminate all other instances? (y/n)"
        if ($response -eq 'y') {
            $currentProcessId = $PID
            $existingProcesses | Where-Object { $_.ProcessId -ne $currentProcessId } | ForEach-Object {
                Write-Output "Terminating process ID: $($_.ProcessId)"
                Stop-Process -Id $_.ProcessId -Force
            }
            Write-Output "All other instances terminated."
        } else {
            Write-Error "Another instance of the script is already running. Exiting."
            exit 1
        }
    }
}

# Main script execution
Test-ExistingInstance
Start-PythonScript
