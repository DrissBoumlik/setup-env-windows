# Set-ExecutionPolicy Bypass -Scope Process -Force

# Function to resolve input as a direct path or an environment variable
function Resolve-PathOrEnv {
    param (
        [string]$inputFile
    )
    if ($inputFile.StartsWith('%') -and $inputFile.EndsWith('%')) {
        $envVar = $inputFile -replace "%", ""
        $resolvedPath = [System.Environment]::GetEnvironmentVariable($envVar, [System.EnvironmentVariableTarget]::Machine)
        if ([string]::IsNullOrEmpty($resolvedPath)) {
            throw "Environment variable '$envVar' is not set."
        }
        $inputFileReolved = "$resolvedPath\php.ini"
    } else {
        $inputFileReolved = "$inputFile\php.ini"
    }
    
    $backupFile = "$inputFileReolved.bak"
    if (-not (Test-Path $backupFile)) {
        Copy-Item -Path $inputFileReolved -Destination $backupFile        
    }
    return $inputFileReolved
}


# Define the path to the php.ini file
$inputFile = Read-Host "Indicate the path to the php.ini file"
$phpIniPath = Resolve-PathOrEnv -input $inputFile

# Read the php.ini file content
$fileContent = Get-Content -Path $phpIniPath

# Initialize variables
$inXdebugSection = $false
$uncomment = $false

# Determine if we need to comment or uncomment
foreach ($line in $fileContent) {
    if ($line -match "\[xdebug\]") {
        if ($line -match "^;\s*\[xdebug\]") {
            $uncomment = $true
        } else {
            $uncomment = $false
        }
        break
    }
}

# Create a new list to store the modified content
$newContent = @()

# Process each line in the php.ini file
foreach ($line in $fileContent) {
    if ($line -match "\[xdebug\]") {
        $inXdebugSection = $true
        $modifiedLine = If ($uncomment) { $line -replace "^;\s*", ""} Else { "; $line" }
    } elseif ($inXdebugSection -and ($line -match "^\[.*\]")) {
        $inXdebugSection = $false
        $modifiedLine = $line
    } elseif ($inXdebugSection) {
        $modifiedLine = If ($uncomment) { $line -replace "^;\s*", "" } Else { "; $line" }
    } else {
        $modifiedLine = $line
    }
    $newContent += $modifiedLine
}

# Write the modified content back to the php.ini file
$newContent | Set-Content -Path $phpIniPath

$msg = If ($uncomment) { "activated" } Else { "deactivated" }
Write-Host "xdebug has been $msg"
