# launch-cc11-fix.ps1
# Starts the midi filtering to remove bad cc11 messages from Komplete Kontrol keyboard.
# Connect the DAW to the 'midi-filtered-cc11' device instead of the normal keyboard device.

# Function to start the Python script
function Start-PythonScript {
    Write-Output "Starting filter_cc11..."
    $pythonPath = "C:\ProgramData\chocolatey\bin\python3.12.exe"  # Adjust the path if necessary
    $scriptPath = "C:\projects\cc11-fix\filter_cc11.py"  # Adjust the path if necessary
    if (Test-Path $pythonPath) {
        if (Test-Path $scriptPath) {
            try {
                Start-Process -FilePath $pythonPath -ArgumentList $scriptPath, "run"
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

# Main script execution
Start-PythonScript
