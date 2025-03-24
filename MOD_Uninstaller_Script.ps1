
# Welcome message
$WelcomeMessage = @"

***************************************
        🏁  Welcome, racers! 🏁
***************************************

This PowerShell Script will help you remove MODs installed through BPR Modder, for the game Burnout Paradise Remastered (PC version).

"@

Write-Host $WelcomeMessage -ForegroundColor Green

# Locate Steam Install Path
$InstallPath = (Get-ItemProperty -Path "HKLM:\Software\WOW6432Node\Valve\Steam").InstallPath
Write-Host "Located Steam Install Path: $InstallPath"

# Path to Steam's libraryfolders.vdf
$LibraryFile = "$InstallPath\steamapps\libraryfolders.vdf"
Write-Host "Located 'libraryfolders.vdf' file: $LibraryFile"

# Read library folders
$LibraryPaths = Get-Content $LibraryFile | Select-String -Pattern '"path"' | ForEach-Object {
    ($_ -replace '.*"path"\s+"(.+)"', '$1') -replace '\\\\', '\'
}
Write-Host "Located steamapps folder: $LibraryPaths" 

# Steam Game's App ID and Name
# $GameAppID = "1238080" # https://store.steampowered.com/app/1238080/Burnout_Paradise_Remastered/
$GameAppName = "BurnoutPR" 

# Search for the game installation folder
foreach ($Path in $LibraryPaths) {
    $GameFolder = Join-Path $Path "steamapps\common"
    if (Test-Path (Join-Path $GameFolder $GameAppName)) {
        $GamePath = Join-Path $GameFolder $GameAppName
        Write-Host "Located the game: $GamePath"
        break
    }
}


# Search for installed game MODs
$ModsPath = Join-Path $GamePath "mods"
Write-Host "Located MODs folder: $ModsPath"

# List of file names to search for
$FileNames = @(
    "brick-remastered.bprmod",
    "core-bugfixes.bprmod",
    "language-unlocker.bprmod",
    "traffic-toggle.bprmod"
)

# # Display the list of file names
# Write-Host "`nFiles to search for:" -ForegroundColor Green
# $FileNames | ForEach-Object { Write-Host $_ }

Write-Host "`n"

$AnyFileFound = $false # Initialize a flag to track if any file is found
$InstalledMods = @() # Initialize an array to store installed MODs

foreach ($FileName in $FileNames) {
    $FilePath = Join-Path $ModsPath $FileName
    if (Test-Path $FilePath) {
        $AnyFileFound = $true
        switch ($FileName) {
            "brick-remastered.bprmod" {
                # Write-Host "Brick Remastered MOD is currently installed." -ForegroundColor Yellow
                $InstalledMods += "Brick Remastered MOD"
            }
            "core-bugfixes.bprmod" { 
                # Write-Host "Core Bugfixes MOD is currently installed." -ForegroundColor Yellow
                $InstalledMods += "Core Bugfixes MOD"
            }
            "language-unlocker.bprmod" { 
                # Write-Host "Language Unlocker MOD is currently installed." -ForegroundColor Yellow
                $InstalledMods += "Language Unlocker MOD"
            }
            "traffic-toggle.bprmod" { 
                # Write-Host "Traffic Toggle MOD is currently installed." -ForegroundColor Yellow
                $InstalledMods += "Traffic Toggle MOD"
            }
            default { 
                Write-Host "Also, found the following MOD file(s): $FilePath" -ForegroundColor Yellow
                # $InstalledMods += "Unknown MOD ($FileName)"
            }
        }
    } else {
        # Do nothing
    }
}

if (-not $AnyFileFound) {
    Write-Host "No MODs are currently installed/files are missing!" -ForegroundColor Red
    Read-Host -Prompt "`nPress Enter to close this window"
    Exit
}

# # Prompts the user with the list of installed MODs
# Write-Host "`nThe following MODs are currently installed:" -ForegroundColor Green
# $InstalledMods | ForEach-Object { Write-Host $_ }


# Prompts the user to uninstall a MOD
Write-Host "`nThe following MODs are currently installed:" -ForegroundColor Cyan
for ($i = 0; $i -lt $InstalledMods.Count; $i++) {
    Write-Host "$($i + 1). $($InstalledMods[$i])"
}
$Choice = Read-Host "`nPlease enter the number associated to the MOD that you'd like to uninstall"


# Validates the user's choice
if ($Choice -match '^\d+$' -and [int]$Choice -ge 1 -and [int]$Choice -le $InstalledMods.Count) {
    $SelectedMod = $InstalledMods[$Choice - 1]
    Write-Host "`nYou selected to uninstall: $SelectedMod" -ForegroundColor Cyan
    $RegistryPath = "HKCU:\Software\Bo98\BPR Modder\installed" # <=> "Computer\HKEY_CURRENT_USER\Software\Bo98\BPR Modder\installed" from Regedit (Registry Editor)
    # reg export "HKEY_CURRENT_USER\Software\Bo98\" "BACKUP_BPR_Modder.reg"

    # Defines specific uninstallation logic for each MOD
    switch ($SelectedMod) {
        "Brick Remastered MOD" {
            Write-Host "`nRunning uninstallation process for Brick Remastered MOD..." -ForegroundColor Yellow
            Remove-Item "$ModsPath\brick-remastered.bprmod" -Force -Recurse
            Remove-Item "$ModsPath\brick-remastered" -Force -Recurse

            $PropertyToDelete = "brick-remastered"
            Remove-ItemProperty -Path $RegistryPath -Name $PropertyToDelete

            Write-Host "`nBrick Remastered MOD was successfully uninstalled." -ForegroundColor Green
        }
        "Core Bugfixes MOD" {
            Write-Host "`nRunning uninstallation process for Core Bugfixes MOD..." -ForegroundColor Yellow
            Remove-Item "$ModsPath\core-bugfixes.bprmod" -Force -Recurse

            $PropertyToDelete = "core-bugfixes"
            Remove-ItemProperty -Path $RegistryPath -Name $PropertyToDelete

            Write-Host "`nCore Bugfixes MOD was successfully uninstalled." -ForegroundColor Green
        }
        "Language Unlocker MOD" {
            Write-Host "`nRunning uninstallation process for Language Unlocker MOD..." -ForegroundColor Yellow
            Remove-Item "$ModsPath\language-unlocker.bprmod" -Force -Recurse
            Remove-Item "$ModsPath\language-unlocker" -Force -Recurse

            $PropertyToDelete = "language-unlocker"
            Remove-ItemProperty -Path $RegistryPath -Name $PropertyToDelete

            Write-Host "`nLanguage Unlocker MOD was successfully uninstalled." -ForegroundColor Green
        }
        "Traffic Toggle MOD" {
            Write-Host "`nRunning uninstallation process for Traffic Toggle MOD..." -ForegroundColor Yellow
            Remove-Item "$ModsPath\traffic-toggle.bprmod" -Force -Recurse
            
            $PropertyToDelete = "traffic-toggle"
            Remove-ItemProperty -Path $RegistryPath -Name $PropertyToDelete

            Write-Host "`nTraffic Toggle MOD was successfully uninstalled." -ForegroundColor Green
        }
        default {
            Write-Host "`nNo specific uninstallation process is defined for $SelectedMod." -ForegroundColor Red
        }
    }
} else {
    Write-Host "`nInvalid choice! Exiting the script." -ForegroundColor Red
}


# For Debugging Purposes
Read-Host -Prompt "`nPress Enter to close this window"