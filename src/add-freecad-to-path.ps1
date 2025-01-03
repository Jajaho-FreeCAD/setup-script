# Requires elevation (Run as Administrator)
#Requires -RunAsAdministrator

$freecadPath = "C:\Program Files\FreeCAD 1.0\bin"

# Check if the path exists
if (-not (Test-Path $freecadPath)) {
    Write-Error "FreeCAD path not found at: $freecadPath"
    exit 1
}

try {
    # Get the current system PATH
    $currentPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
    
    # Check if FreeCAD path is already in PATH
    if ($currentPath -split ';' -contains $freecadPath) {
        Write-Host "FreeCAD is already in your system PATH." -ForegroundColor Yellow
        exit 0
    }
    
    # Add FreeCAD to PATH
    $newPath = $currentPath + ";" + $freecadPath
    [Environment]::SetEnvironmentVariable("Path", $newPath, "Machine")
    
    Write-Host "Successfully added FreeCAD to system PATH!" -ForegroundColor Green
    Write-Host "Please restart your PowerShell session for the changes to take effect." -ForegroundColor Yellow
    
    # Verify the addition
    $updatedPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
    if ($updatedPath -split ';' -contains $freecadPath) {
        Write-Host "Verification successful: FreeCAD path is now in system PATH." -ForegroundColor Green
    } else {
        Write-Warning "Verification failed: Please check the system PATH manually."
    }
} catch {
    Write-Error "Error updating PATH: $_"
    exit 1
}