# cc11-fix-setup.ps1
# Ensure the execution policy is set to 'RemoteSigned' or 'Unrestricted' before running this script.
# Run the following command in an elevated PowerShell (run as Administrator):
# Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

# Parse command line arguments
param (
    [string]$operation = "help"
)

function Test-AdminMode {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Your installation steps go here

function Test-ExecutionPolicy {
    $currentPolicy = Get-ExecutionPolicy -Scope CurrentUser
    if ($currentPolicy -notin ('RemoteSigned', 'Unrestricted')) {
    #if ($currentPolicy -ne 'RemoteSigned' -and $currentPolicy -ne 'Unrestricted') {
        Write-Output "Current execution policy: $currentPolicy"
        Write-Output "The script requires the execution policy to be set to 'RemoteSigned' or 'Unrestricted'."
        Write-Output "Please run the following command in an elevated PowerShell (run as Administrator):"
        Write-Output "Set-ExecutionPolicy RemoteSigned -Scope CurrentUser"
        exit 1
    }
}

function Install-Chocolatey {
    try {
        Write-Output "Installing Chocolatey..."
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
        Write-Output "Chocolatey installed successfully."
    } catch {
        Write-Error "Failed to install Chocolatey: $_"
        exit 1
    }
}

function Install-Python {
    try {
        Write-Output "Installing Python..."
        choco install python -y
        Write-Output "Python installed successfully."
    } catch {
        Write-Error "Failed to install Python: $_"
        exit 1
    }
}

function Install-PipPackages {
    try {
        Write-Output "Installing pip packages..."
        pip install mido python-rtmidi
        Write-Output "Pip packages installed successfully."
    } catch {
        Write-Error "Failed to install pip packages: $_"
        exit 1
    }
}

function Install-LoopMIDI {
    try {
        Write-Output "Downloading loopMIDI..."
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
}

function Find-LoopMIDIExecutable {
    $possiblePaths = @(
        "C:\Program Files (x86)\Tobias Erichsen\loopMIDI\loopMIDI.exe",
        "C:\Program Files (x86)\loopMIDI\loopMIDI.exe",
        "C:\Program Files\loopMIDI\loopMIDI.exe",
        "$env:ProgramFiles\loopMIDI\loopMIDI.exe",
        "$env:ProgramFiles(x86)\loopMIDI\loopMIDI.exe"
    )

    foreach ($path in $possiblePaths) {
        if (Test-Path $path) {
            return $path
        }
    }

    return $null
}

function Set-LoopMIDIPort {
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
}

function New-Launcher {
    $pythonPath = "C:\ProgramData\chocolatey\bin\python.exe"
    $WScriptShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WScriptShell.CreateShortcut("$env:USERPROFILE\Desktop\MIDI filter CC11.lnk")
    $Shortcut.TargetPath = $pythonPath
    $Shortcut.Arguments = "c:\projects\cc11-fix\filter_cc11.py"
    $Shortcut.WorkingDirectory = "c:\projects\cc11-fix"
    $Shortcut.WindowStyle = 1
    $Shortcut.Save()
}

function Show-Help {
    Write-Output "Usage: .\cc11-fix-setup.ps1 <operation>"
    Write-Output "Operations:"
    Write-Output "  all                Run all setup steps"
    Write-Output "  check-policy       Check execution policy"
    Write-Output "  install-choco      Install Chocolatey"
    Write-Output "  install-python     Install Python"
    Write-Output "  install-pip        Install pip packages"
    Write-Output "  install-loopmidi   Install loopMIDI"
    Write-Output "  configure-port     Configure loopMIDI port"
    Write-Output "  create-launcher    Create desktop shortcut for MIDI filter CC11"
}

function Main {
    param (
        [string]$operation
    )

    switch ($operation) {
        "all" {
            Test-ExecutionPolicy
            Install-Chocolatey
            Install-Python
            Install-PipPackages
            Install-LoopMIDI
            Configure-LoopMIDIPort
            Create-Launcher
        }
        "check-policy" {
            Check-ExecutionPolicy
        }
        "install-choco" {
            Install-Chocolatey
        }
        "install-python" {
            Install-Python
        }
        "install-pip" {
            Install-PipPackages
        }
        "install-loopmidi" {
            Install-LoopMIDI
        }
        "configure-port" {
            Set-LoopMIDIPort
        }
        "create-launcher" {
            New-Launcher
        }
        default {
            Show-Help
        }
    }
}

if (-not (Test-AdminMode)) {
    Write-Host "This script requires administrator privileges. Please run PowerShell as an administrator and try again." -ForegroundColor Red
    exit 1
}

Main -operation $operation
