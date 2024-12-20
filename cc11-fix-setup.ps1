# cc11-fix-setup.ps1
# Ensure the execution policy is set to 'RemoteSigned' or 'Unrestricted' before running this script.
# Run the following command in an elevated PowerShell (run as Administrator):
# Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

# Check execution policy
$currentPolicy = Get-ExecutionPolicy -Scope CurrentUser
if ($currentPolicy -ne 'RemoteSigned' -and $currentPolicy -ne 'Unrestricted') {
    Write-Output "Current execution policy: $currentPolicy"
    Write-Output "The script requires the execution policy to be set to 'RemoteSigned' or 'Unrestricted'."
    Write-Output "Please run the following command in an elevated PowerShell (run as Administrator):"
    Write-Output "Set-ExecutionPolicy RemoteSigned -Scope CurrentUser"
    exit 1
}

# Install Chocolatey
try {
    Write-Output "Installing Chocolatey..."
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    Write-Output "Chocolatey installed successfully."
} catch {
    Write-Error "Failed to install Chocolatey: $_"
    exit 1
}

# Install Python
try {
    Write-Output "Installing Python..."
    choco install python -y
    Write-Output "Python installed successfully."
} catch {
    Write-Error "Failed to install Python: $_"
    exit 1
}

# Install pip packages
try {
    Write-Output "Installing pip packages..."
    pip install mido python-rtmidi
    Write-Output "Pip packages installed successfully."
} catch {
    Write-Error "Failed to install pip packages: $_"
    exit 1
}

# Download and install loopMIDI
try {
    Write-Output "Downloading loopMIDI..."
    $loopMIDIInstallerPath = "$env:TEMP\loopMIDISetup.exe"
    Invoke-WebRequest -Uri "https://www.tobias-erichsen.de/wp-content/uploads/2020/01/loopMIDISetup_1_0_16_27.zip" -OutFile "$env:TEMP\loopMIDI.zip"
    
    Write-Output "Extracting loopMIDI..."
    Expand-Archive -Path "$env:TEMP\loopMIDI.zip" -DestinationPath "$env:TEMP\loopMIDI" -Force
    
    Write-Output "Installing loopMIDI..."
    Start-Process -FilePath "$env:TEMP\loopMIDI\loopMIDISetup.exe" -ArgumentList "/S" -Wait
    
    Write-Output "Cleaning up..."
    Remove-Item -Path "$env:TEMP\loopMIDI.zip" -Force
    Remove-Item -Path "$env:TEMP\loopMIDI" -Recurse -Force
    
    Write-Output "loopMIDI installed successfully."
} catch {
    Write-Error "Failed to download or install loopMIDI: $_"
    exit 1
}

# Search for loopMIDI executable
function Find-LoopMIDIExecutable {
    $possiblePaths = @(
        "C:\Program Files (x86)\Tobias Erichsen\loopMIDI\loopMIDI.exe",
    )

    foreach ($path in $possiblePaths) {
        if (Test-Path $path) {
            return $path
        }
    }

    return $null
}

# Configure loopMIDI virtual port
try {
    Write-Output "Configuring loopMIDI virtual port..."
    $loopMIDIPath = Find-LoopMIDIExecutable
    if ($loopMIDIPath) {
        Start-Process -FilePath $loopMIDIPath -ArgumentList "/AddPort:midi-filtered-cc11" -Wait
        Write-Output "loopMIDI virtual port 'midi-filtered-cc11' configured successfully."
    } else {
        Write-Error "loopMIDI executable not found."
        exit 1
    }
} catch {
    Write-Error "Failed to configure loopMIDI virtual port: $_"
    exit 1
}

Write-Output "Setup completed successfully. You can now run your Python script using 'python filter_cc11.py run <input_port>'."
