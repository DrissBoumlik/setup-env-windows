
. ./functions.ps1

$ProgressPreference = 'SilentlyContinue'

#region ANSWER QUESTIONS FOR WHICH STEPS TO EXECUTE
$StepsQuestions = [ordered]@{
    GIT = [PSCustomObject]@{ Question = "- Did you already install git ? "; Answer = "no" }
    CMDER = [PSCustomObject]@{ Question = "- Did you already start cmder ? "; Answer = "no" }
    XAMPP_COMPOSER = [PSCustomObject]@{ Question = "- Did you already install Xampp & Composer ? "; Answer = "no" }
}
 
foreach ($key in $StepsQuestions.Keys) {
     $q = $StepsQuestions[$key]
     $q.Answer = Prompt-YesOrNoWithDefault -message $q.Question -defaultOption "no"
}
#endregion

$downloadPath = Setup-Container-Directory

$overrideExistingEnvVars = Prompt-YesOrNoWithDefault -message "`nWould you like to override the existing environment variables"

$WhatWasDoneMessages = @()
#region ADD DELTA TO GIT CONFIG
if ($StepsQuestions["GIT"].Answer -eq "yes") {
    $gitConfigFile = "~/.gitconfig"
    if (-not (Test-Path $gitConfigFile)) {
        New-Item -Path $gitConfigFile -ItemType "File"
    }

    $backupFile = "~/.gitconfig.bak"
    if (Test-Path $backupFile) {
        Copy-Item -Path $backupFile -Destination $gitConfigFile
    } else {
        Copy-Item -Path $gitConfigFile -Destination $backupFile
    }

    try {
        git config --global alias.alias "! git config --get-regexp ^alias\. | sed -e s/^alias\.// -e s/\ /\ =\ /"
        git config --global alias.log-pretty  "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
        git config --global alias.log-pretty2 "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %Cgreen(%cs) %C(bold blue)<%an>%Creset' --abbrev-commit"
        git config --global alias.log-pretty3 "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %Cgreen(%ch) %C(bold blue)<%an>%Creset' --abbrev-commit"
        git config --global alias.nah "!f(){ git reset --hard; git clean -df; if [ -d .git/rebase-apply ] || [ -d .git/rebase-merge ]; then git rebase --abort; fi; }; f"
        $WhatWasDoneMessages = Set-Success-Message -message "Git aliases are set" -WhatWasDoneMessages $WhatWasDoneMessages
    }
    catch {
        $WhatWasDoneMessages = Set-Warning-Message -message "Make sure you installed Git first !" -WhatWasDoneMessages $WhatWasDoneMessages
    }
    
    try {
        $deltaGitConfig = @"

# DELTA CONFIG FOR git diff
[include]
    path = ~/themes.gitconfig
[core]
    pager = delta
[interactive]
    diffFilter = delta --color-only
[delta]
    # navigate = true    
    # # use n and N to move between diff sections
    # features = collared-trogon
    # side-by-side = true
    # line-numbers = true
    # line-numbers-left-format = ""
    # line-numbers-right-format = "│ "
    # # delta detects terminal colors automatically; set one of these to disable auto-detection
    # # dark = true
    # # light = true
	features = mellow-barbet
[merge]
    conflictstyle = diff3
[diff]
    colorMoved = default
"@
        Copy-Item -Path "$PWD\config\themes.gitconfig" -Destination "~/themes.gitconfig"
        Add-Content -Path $gitConfigFile -Value $deltaGitConfig

        $WhatWasDoneMessages = Set-Success-Message -message "Delta was added to ~/.gitconfig successfully" -WhatWasDoneMessages $WhatWasDoneMessages
    }
    catch {
        $WhatWasDoneMessages = Set-Warning-Message -message "Issue with ~/.gitconfig !" -WhatWasDoneMessages $WhatWasDoneMessages
    }
}
#endregion

#region COPY CMDER CONFIG & ALIASES
if ($StepsQuestions["CMDER"].Answer -eq "yes") {

    $backupFile = "$downloadPath\Cmder\vendor\conemu-maximus5\ConEmu.xml.bak"
    if (-not (Test-Path $backupFile)) {
        Copy-Item -Path "$downloadPath\Cmder\vendor\conemu-maximus5\ConEmu.xml" -Destination $backupFile
    }
    Copy-Item -Path "$PWD\config\ConEmu.xml" -Destination "$downloadPath\Cmder\vendor\conemu-maximus5\ConEmu.xml"
    
    Copy-Item -Path "$PWD\config\zoxide.lua" -Destination "$downloadPath\Cmder\config\zoxide.lua"
    
    $backupFile = "$downloadPath\Cmder\config\user_aliases.cmd.bak"
    if (Test-Path $backupFile) {
        Copy-Item -Path $backupFile -Destination "$downloadPath\Cmder\config\user_aliases.cmd"
    } else {
        Copy-Item -Path "$downloadPath\Cmder\config\user_aliases.cmd" -Destination $backupFile
    }
    Get-Content -Path "$PWD\config\user_aliases.cmd" | Add-Content -Path "$downloadPath\Cmder\config\user_aliases.cmd"

    $backupFile = "$downloadPath\Cmder\config\user_profile.cmd.bak"
    if (Test-Path $backupFile) {
        Copy-Item -Path $backupFile -Destination "$downloadPath\Cmder\config\user_profile.cmd"
    } else {
        Copy-Item -Path "$downloadPath\Cmder\config\user_profile.cmd" -Destination $backupFile
    }
    Get-Content -Path "$PWD\config\user_profile.cmd" | Add-Content -Path "$downloadPath\Cmder\config\user_profile.cmd"

    Make-Directory "$downloadPath\env\tools"
    Make-Directory "$downloadPath\env\tools\scripts"
    Copy-Item -Path "$PWD\tools\scripts\set-env.bat" -Destination "$downloadPath\env\tools\scripts\set-env.bat"
    Add-Alias-To-Cmder -alias "setvar=""$downloadPath\env\tools\set-env.bat"" `$1 `$2 && RefreshEnv.cmd" -downloadPath $downloadPath
    Copy-Item -Path "$PWD\tools\scripts\toggle-xdebug.ps1" -Destination "$downloadPath\env\tools\scripts\toggle-xdebug.ps1"
    Add-Alias-To-Cmder -alias "togglexdbg=powershell -ExecutionPolicy Bypass -File ""$downloadPath\env\tools\scripts\toggle-xdebug.ps1"" $*" -downloadPath $downloadPath

    $WhatWasDoneMessages = Set-Success-Message -message "ConEmu.xml & user_aliases.cmd were added to Cmder successfully" -WhatWasDoneMessages $WhatWasDoneMessages

    $directories = Get-ChildItem -Path "C:\" -Directory -ErrorAction SilentlyContinue -Force | Where-Object { $_.Name -match 'xampp' }
    if ($directories.Count -gt 0) {
        $xamppPath = ($directories | Select-Object -First 1).FullName
        Add-Alias-To-Cmder -alias "phpxmp=""$xamppPath\php\php.exe"" $*" -downloadPath $downloadPath
    }
    
    Add-Alias-To-Cmder -alias "tools=cd ""$downloadPath\env\tools"" $*" -downloadPath $downloadPath
    Add-Alias-To-Cmder -alias "phpdir=cd ""$downloadPath\env\php_stuff\php"" $*" -downloadPath $downloadPath
    Add-Alias-To-Cmder -alias "envdir=cd ""$downloadPath\env"" $*" -downloadPath $downloadPath
    $WhatWasDoneMessages = Set-Success-Message -message "PHP & ENV paths aliases were added successfully" -WhatWasDoneMessages $WhatWasDoneMessages
    
    $phpPaths = Get-ChildItem -Path "$downloadPath\env\php_stuff\php" -Directory | Select-Object -ExpandProperty Name
    if ($phpPaths.Count -gt 0) {
        foreach ($phpPath in $phpPaths) {
            if ($phpPath -match "php-(\d+)\.(\d+)\.") {
                $majorVersion = $matches[1]
                $minorVersion = $matches[2]
                if ($minorVersion -eq '0') {
                    $phpVersion = $majorVersion
                } else {
                    $phpVersion = "$majorVersion$minorVersion"
                }
                Add-Alias-To-Cmder -alias "php$phpVersion=""$downloadPath\env\php_stuff\php\$phpPath\php.exe"" $*" -downloadPath $downloadPath
            }
        }
        $WhatWasDoneMessages = Set-Success-Message -message "PHP versions aliases were added successfully" -WhatWasDoneMessages $WhatWasDoneMessages
    }
    
    $phpToolsPaths = Get-ChildItem -Path "$downloadPath\env\php_stuff\tools" -File -Filter "*.phar"
    if ($phpToolsPaths.Count -gt 0) {
        foreach ($phpToolPath in $phpToolsPaths) {
            $fileName = $phpToolPath.BaseName
            Add-Alias-To-Cmder -alias "$fileName=php ""$downloadPath\env\php_stuff\tools\$fileName.phar"" $*" -downloadPath $downloadPath
        }
        $WhatWasDoneMessages = Set-Success-Message -message "PHP TOOLS aliases were added successfully" -WhatWasDoneMessages $WhatWasDoneMessages
    }
}
#endregion

#region ADD PHP ENVIRONMENT VARIABLE TO THE PATH
if ($StepsQuestions["XAMPP_COMPOSER"].Answer -eq "yes") {
    $directories = Get-ChildItem -Path "C:\" -Directory -ErrorAction SilentlyContinue -Force | Where-Object { $_.Name -match 'xampp' }
    if ($directories.Count -gt 0) {
        $xamppPath = ($directories | Select-Object -First 1).FullName
        Update-Path-Env-Variable -variableName  "$xamppPath\php" -isVarName 0 -remove 1
        Add-Env-Variable -newVariableName "phpxmp" -newVariableValue "$xamppPath\php" -updatePath 0 -overrideExistingEnvVars $overrideExistingEnvVars
        Add-Env-Variable -newVariableName "php_now" -newVariableValue "$xamppPath\php" -updatePath 1 -overrideExistingEnvVars $overrideExistingEnvVars
        Add-Env-Variable -newVariableName "mysql_stuff" -newVariableValue "$xamppPath\mysql\bin" -updatePath 1 -overrideExistingEnvVars $overrideExistingEnvVars

        $msg = "The 'php_now', 'mysql_stuff' & 'phpxmp' "
    } else {
        $WhatWasDoneMessages = Set-Warning-Message -message "No XAMPP directories found." -WhatWasDoneMessages $WhatWasDoneMessages
    }

    # Copy composer version 1 to the composer path
    Copy-Item -Path "$PWD\tools\composer-v1" -Destination "C:\composer\v1" -Recurse
    Update-Path-Env-Variable -variableName "C:\composer\v1" -isVarName 0
    
    $msg += "'composer1'"
    $WhatWasDoneMessages = Set-Success-Message -message "$msg variables were successfully added to the PATH" -WhatWasDoneMessages $WhatWasDoneMessages
}
#endregion

What-ToDo-Next -WhatWasDoneMessages $WhatWasDoneMessages
