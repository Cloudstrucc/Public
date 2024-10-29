# Define parameters & make sure to run this in an elevated priviledged PowerShell session (run as administrator)
$jenkinsUrl = "https://get.jenkins.io/windows-stable/2.414.3/jenkins.msi" # make sure to adjust this URL as needed
$installerPath = "C:\jenkins.msi"

# Download the Jenkins MSI installer
Invoke-WebRequest -Uri $jenkinsUrl -OutFile $installerPath

# Install Jenkins - this runs the installer silently without a GUI
Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$installerPath`" /qn" -Wait -NoNewWindow

# Cleanup the installer
Remove-Item -Path $installerPath

# Optionally, you can start the Jenkins service if it's not started automatically
Start-Service -Name "Jenkins"

Write-Host "Jenkins installation complete. Please configure Jenkins by opening your browser to http://localhost:8080"
