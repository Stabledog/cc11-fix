# cc11-fix-setup.ps1
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

Write-Output "Setup completed successfully. You can now run your Python script using 'python filter.py'."
