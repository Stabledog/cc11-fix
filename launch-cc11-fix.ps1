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
                Start-Process -FilePath $pythonPath -ArgumentList "$scriptPath $uniqueArg", "run" -WindowStyle Hidden
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
function Check-ExistingInstance {
    $uniqueArg = "--unique-cc11-filter"
    $existingProcess = Get-Process -ErrorAction SilentlyContinue | Where-Object {
        $_.ProcessName -like "*python*" -and $_.CommandLine -like "*$uniqueArg*"
    }

    if ($existingProcess) {
        Write-Error "Another instance of the script is already running."
        exit 1
    }
}

# Main script execution
Check-ExistingInstance
Start-PythonScript
