param(
    [Parameter(Mandatory=$true)]
    [string]$ProjectName,
    
    [Parameter(Mandatory=$false)]
    [string]$Description = "A FreeCAD project",

    [Parameter(Mandatory=$false)]
    [string]$Organization = "Jajaho-FreeCAD"
)

# Check if gh CLI is installed
if (!(Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Error "GitHub CLI (gh) is not installed. Please install it first."
    exit 1
}

# Check if authenticated
$ghStatus = gh auth status 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Error "Please authenticate with GitHub first using 'gh auth login'"
    exit 1
}

# Check if repository already exists
$repoExists = $false
try {
    if ($Organization) {
        $repoCheck = gh repo view "$Organization/$ProjectName" 2>&1
    } else {
        $repoCheck = gh repo view "$((gh api user).login)/$ProjectName" 2>&1
    }
    $repoExists = $LASTEXITCODE -eq 0
} catch {
    # Repository doesn't exist, continue with creation
}

if ($repoExists) {
    $choice = Read-Host "A repository with the name '$ProjectName' already exists. Do you want to [P]ull the existing repo, choose a [N]ew name, or [C]ancel? (P/N/C)"
    switch ($choice.ToUpper()) {
        "P" {
            # Clone existing repository
            if ($Organization) {
                git clone "https://github.com/$Organization/$ProjectName.git"
            } else {
                git clone "https://github.com/$((gh api user).login)/$ProjectName.git"
            }
            Write-Host "Existing repository cloned successfully" -ForegroundColor Green
            exit 0
        }
        "N" {
            $ProjectName = Read-Host "Enter a new project name"
            # Recursive call with new project name
            & $MyInvocation.MyCommand.Path -ProjectName $ProjectName -Description $Description -Organization $Organization
            exit 0
        }
        "C" {
            Write-Host "Operation cancelled" -ForegroundColor Yellow
            exit 0
        }
        default {
            Write-Error "Invalid choice. Operation cancelled."
            exit 1
        }
    }
}

# Create main project directory and subdirectories
$directories = @(
    $ProjectName,
    "$ProjectName\export",
    "$ProjectName\src"
)

foreach ($dir in $directories) {
    New-Item -ItemType Directory -Path $dir -Force
}

# Create .gitignore file with common FreeCAD-related ignores
$gitignoreContent = @"
# FreeCAD backup files
*.FCStd1
*.FCBak

# Exported temporary files
*.stl
*.gcode

# Operating System Files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# IDE and Editor Files
.vscode/
.idea/
*.swp
*.swo

# Keep export directory structure but ignore contents
export/*
!export/.gitkeep

# Python cache files (if using FreeCAD macros)
__pycache__/
*.py[cod]
"@

Set-Content -Path "$ProjectName\.gitignore" -Value $gitignoreContent

# Create README.md with basic project information
$readmeContent = @"
# $ProjectName

$Description

## Project Structure

- `src/`: Contains FreeCAD source files
- `export/`: Contains exported files (3MF, STL, etc.)

## Getting Started

1. Open the FreeCAD files from the `src` directory
2. Exported files should be saved to the `export` directory

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request
"@

Set-Content -Path "$ProjectName\README.md" -Value $readmeContent

# Create .gitkeep file in export directory to preserve it
New-Item -ItemType File -Path "$ProjectName\export\.gitkeep" -Force

# Create initial FreeCAD file
try {
    # Get the absolute path for the src directory
    $srcPath = (Resolve-Path "$ProjectName\src").Path
    
    # Create temporary Python script
    $tempDir = [System.IO.Path]::GetTempPath()
    $scriptPath = Join-Path $tempDir "create_freecad_doc.py"
    
    $pythonScript = @'
import sys
import os
import FreeCAD as App

def create_freecad_document(folder_path):
    try:
        # Ensure the folder exists
        if not os.path.exists(folder_path):
            os.makedirs(folder_path)
            
        # Create the full path for the FCStd file
        file_path = os.path.join(folder_path, "main.FCStd")
        
        # Create a new document
        doc = App.newDocument("Main")
        doc.Comment = "Created by FreeCAD project setup script"
        
        # Save the document
        doc.saveAs(file_path)
        print(f"Successfully created main.FCStd in {folder_path}")
        
        # Close the document
        App.closeDocument("Main")
        return True
        
    except Exception as e:
        print(f"Error: {str(e)}")
        return False

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python script.py <folder_path>")
        sys.exit(1)
        
    folder_path = sys.argv[1]
    create_freecad_document(folder_path)
'@

    Set-Content -Path $scriptPath -Value $pythonScript
    
    Write-Host "Creating FreeCAD file..."
    $process = Start-Process -FilePath "python" -ArgumentList "$scriptPath", "$srcPath" -NoNewWindow -Wait -PassThru
    
    if ($process.ExitCode -eq 0) {
        Write-Host "Successfully created initial FreeCAD file at src/main.FCStd" -ForegroundColor Green
    } else {
        Write-Error "Failed to create FreeCAD file"
    }
    
    # Clean up temporary script
    Remove-Item -Path $scriptPath -Force
} catch {
    Write-Error "Error creating FreeCAD file: $_"
}

# Initialize git repository
Set-Location $ProjectName
git init
git add .
git commit -m "Initial commit: Basic project structure"

# Create GitHub repository and push
try {
    # Check if gh CLI is installed
    if (!(Get-Command gh -ErrorAction SilentlyContinue)) {
        Write-Error "GitHub CLI (gh) is not installed. Please install it first."
        exit 1
    }

    # Check if authenticated
    $ghStatus = gh auth status 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Please authenticate with GitHub first using 'gh auth login'"
        exit 1
    }

    # Create GitHub repository
    if ($Organization) {
        gh repo create "$Organization/$ProjectName" --description $Description --private
    } else {
        gh repo create $ProjectName --description $Description --private
    }
    
    # Add remote and push
    if ($Organization) {
        git remote add origin "https://github.com/$Organization/$ProjectName.git"
    } else {
        git remote add origin "https://github.com/$((gh api user).login)/$ProjectName.git"
    }
    git branch -M main
    git push -u origin main

    Write-Host "Repository successfully created and pushed to GitHub!" -ForegroundColor Green
} catch {
    Write-Error "Error creating GitHub repository: $_"
    exit 1
}