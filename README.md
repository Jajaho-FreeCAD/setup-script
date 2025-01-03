# FreeCAD Project Setup Script

A PowerShell script for automatically setting up structured FreeCAD projects with GitHub integration.

## Requirements

1. **PowerShell** (Windows PowerShell 5.1 or PowerShell Core 7.x)
2. **FreeCAD** installed and accessible from command line
3. **GitHub CLI** (`gh`) installed and configured (necessary to create the remote)
4. **Git** installed and configured
5. **Python** accessible from command line (usually installed with FreeCAD)

## Installation

1. Download `setup-freecad-project.ps1` (I like to keep it in my local FreeCAD document folder but you can store it wherever you find convenient).
2. Ensure GitHub CLI is installed:
   ```powershell
   winget install GitHub.cli
   # or
   choco install gh
   ```
3. Authenticate with GitHub:
   ```powershell
   gh auth login
   ```

## Usage

### Basic Usage

1. Open PowerShell or CMD
2. Navigate to the directory where you want to create your project
3. Run the script with minimum required parameters:
   ```powershell
   .\setup-freecad-project.ps1 -ProjectName "MyFreeCADProject"
   ```

or quicker: I prefer to execute it from the scripts context menu **Run with PowerShell** and just type in the project name when prompted.

### Advanced Usage

Include optional parameters for more control:
```powershell
.\setup-freecad-project.ps1 `
    -ProjectName "MyFreeCADProject" `
    -Description "A detailed description of my project" `
    -Organization "MyGitHubOrg"
```

### Parameters

- `ProjectName` (Required): Name of your FreeCAD project
- `Description` (Optional): Project description (Default: "A FreeCAD project")
- `Organization` (Optional): GitHub organization name (Default: "Jajaho-FreeCAD")

## What the Script Does

1. **Checks Prerequisites**
   - Verifies GitHub CLI installation
   - Confirms GitHub authentication
   - Checks for existing remote repositories

2. **Creates Local Project Structure**
   ```
   MyFreeCADProject/
   ├── src/
   │   └── main.FCStd
   ├── export/
   │   └── .gitkeep
   ├── .gitignore
   └── README.md
   ```

3. **Initializes Git Repository**
   - Creates initial commit
   - Sets up remote repository on GitHub
   - Sets up tracking for main branch
   - Pushes initial structure

4. **Handles Existing Repositories**
   If a repository with the same name exists, offers to:
   - Pull the existing repository
   - Choose a new name
   - Cancel the operation

## Troubleshooting

1. **"GitHub CLI is not installed"**
   - Install GitHub CLI using the installation instructions above

2. **"Please authenticate with GitHub first"**
   - Run `gh auth login` and follow the prompts

3. **"Error creating FreeCAD file"**
   - Verify FreeCAD is installed and accessible from command line
   - Check Python installation and PATH variables

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request
