
. ./functions.ps1

$ProgressPreference = 'SilentlyContinue'

Write-Host "`nThis will setup your env with (Git, Xampp, Composer, NVM, Chocolatey, Some enhanced tools, Cmder, PHP, XDebug)`n"

#region ANSWER QUESTIONS FOR WHICH STEPS TO EXECUTE
$StepsQuestions = [ordered]@{
   APPS = [PSCustomObject]@{ Question = "- Download Notepad++, Lightshot, Ditto, Wox ?"; Answer = "no" }
   XAMPP_COMPOSER = [PSCustomObject]@{ Question = "- Download Xampp, Composer ?"; Answer = "no" }
   GIT = [PSCustomObject]@{ Question = "- Download Git ?"; Answer = "no" }
   NVM = [PSCustomObject]@{ Question = "- Download Nvm ?"; Answer = "no" }
   CHOCO = [PSCustomObject]@{ Question = "- Download Chocolatey ?"; Answer = "no" }
   REDIS = [PSCustomObject]@{ Question = "- Download Redis ?"; Answer = "no" }
   TOOLS = [PSCustomObject]@{ Question = "- Download TOOLS (eza, delta, bat, fzf, zoxide, tldr) ?"; Answer = "no" }
   CMDER = [PSCustomObject]@{ Question = "- Download & Configure Cmder ?"; Answer = "no" }
   FONTS = [PSCustomObject]@{ Question = "- Download Nerd Fonts "; Answer = "no" }
   PHP = [PSCustomObject]@{ Question = "- Download PHP versions "; Answer = "no" }
   XDEBUG = [PSCustomObject]@{ Question = "- Download XDebug "; Answer = "no" }
}

foreach ($key in $StepsQuestions.Keys) {
    $q = $StepsQuestions[$key]
    $q.Answer = Prompt-YesOrNoWithDefault -message $q.Question -defaultOption "yes"
}
#endregion

$WhatWasDoneMessages = @()
$WhatToDoNext = @()

#region SETUP THE CONTAINER DIRECTORY
$downloadPath = Setup-Container-Directory
Write-Host "`n- Your working directory is $downloadPath :) " -BackgroundColor Green -ForegroundColor Black
$WhatToDoNext = Set-Todo-Message -message "Your container path is '$downloadPath'" -WhatToDoNext $WhatToDoNext

$overrideExistingEnvVars = Prompt-YesOrNoWithDefault -message "`nWould you like to override the existing environment variables"


#region DOWNLOAD NOTEPADD++, LIGHTSHOT, DITTO, WOX
if ($StepsQuestions["APPS"].Answer -eq "yes") {
    $url = "https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v8.6.8/npp.8.6.8.Installer.x64.exe"
    $WhatWasDoneMessages = Download-App -name "Notepad++" -url $url -output "npp.8.6.8.Installer.x64.exe"

    $url = "https://app.prntscr.com/build/setup-lightshot.exe"
    $WhatWasDoneMessages = Download-App -name "Lightshot" -url $url -output "setup-lightshot.exe"
    
    $url = "https://github.com/sabrogden/Ditto/releases/download/3.24.246.0/DittoSetup_64bit_3_24_246_0.exe"
    $WhatWasDoneMessages = Download-App -name "Ditto clipboard" -url $url -output "DittoSetup_64bit_3_24_246_0.exe"
    
    $url = "https://github.com/Wox-launcher/Wox/releases/download/v1.4.1196/Wox-Full-Installer.1.4.1196.exe"
    $WhatWasDoneMessages = Download-App -name "Wox launcher" -url $url -output "Wox-Full-Installer.1.4.1196.exe"
    
    $WhatToDoNext = Set-Todo-Message -message "After installing WOX, Copy theme files tools\wox to '%USERPROFILE%\AppData\Local\Wox\[APP_WERSION]\Themes'" -WhatToDoNext $WhatToDoNext
}
#endregion

#region DOWNLOAD XAMPP, COMPOSER
if ($StepsQuestions["XAMPP_COMPOSER"].Answer -eq "yes") {
    $url = "https://deac-fra.dl.sourceforge.net/project/xampp/XAMPP%20Windows/8.2.12/xampp-windows-x64-8.2.12-0-VS16-installer.exe?viasf=1"
    $WhatWasDoneMessages = Download-App -name "Xampp" -url $url -output "1-xampp-windows-x64-8.2.12-0-VS16-installer.exe"

    $url = "https://getcomposer.org/Composer-Setup.exe"
    $WhatWasDoneMessages = Download-App -name "Composer" -url $url -output "2-Composer-Setup.exe"

    Make-Directory -path "$downloadPath\env\php_stuff"
    $url = "https://getcomposer.org/download/1.10.27/composer.phar"
    Download-File -url $url -output "$PWD\tools\composer-v1\composer.phar"
}
#endregion

#region DOWNLOAD AND INSTALL CHOCOLATEY
if ($StepsQuestions["CHOCO"].Answer -eq "yes") {
    try {
        Write-Host "`nDownloading and installing Chocolatey..."
        # Set-ExecutionPolicy Bypass -Scope Process -Force
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString("https://chocolatey.org/install.ps1"))
        $WhatWasDoneMessages = Set-Success-Message -message "Chocolatey was installed successfully" -WhatWasDoneMessages $WhatWasDoneMessages
    }
    catch {
        $WhatWasDoneMessages = Set-Error-Message -message "Chocolatey failed to install, try again" -exceptionMessage $_.InvocationInfo.PositionMessage -WhatWasDoneMessages $WhatWasDoneMessages
    }
}
#endregion

#region DOWNLOAD & INSTALL GIT
if ($StepsQuestions["GIT"].Answer -eq "yes") {
    try {
        Write-Host "`nDownloading and installing Git..."
        choco install git.install -y > $null 2>&1
        $WhatWasDoneMessages = Set-Success-Message -message "Git was installed successfully" -WhatWasDoneMessages $WhatWasDoneMessages
    }
    catch {
        $WhatWasDoneMessages = Set-Error-Message -message "Git failed to install, try again" -exceptionMessage $_.InvocationInfo.PositionMessage -WhatWasDoneMessages $WhatWasDoneMessages
    }
}
#endregion

#region DOWNLOAD & INSTALL NVM
if ($StepsQuestions["NVM"].Answer -eq "yes") {
    try {
        Write-Host "`nDownloading and installing NVM..."
        choco install nvm -y > $null 2>&1
        $WhatWasDoneMessages = Set-Success-Message -message "NVM was installed successfully" -WhatWasDoneMessages $WhatWasDoneMessages
    }
    catch {
        $WhatWasDoneMessages = Set-Error-Message -message "NVM failed to install, try again" -exceptionMessage $_.InvocationInfo.PositionMessage -WhatWasDoneMessages $WhatWasDoneMessages
    }
}
#endregion

#region DOWNLOAD & INSTALL REDIS
if ($StepsQuestions["REDIS"].Answer -eq "yes") {
    try {
        Write-Host "`nDownloading and installing REDIS..."
        choco install redis-64 --version=3.0.503 -y > $null 2>&1
        $WhatWasDoneMessages = Set-Success-Message -message "REDIS was installed successfully" -WhatWasDoneMessages $WhatWasDoneMessages
    }
    catch {
        $WhatWasDoneMessages = Set-Error-Message -message "REDIS failed to install, try again" -exceptionMessage $_.InvocationInfo.PositionMessage -WhatWasDoneMessages $WhatWasDoneMessages
    }
}
#endregion

#region DOWNLOAD AND SETUP EZA, DELTA, BAT, FZF, ZOXIDE, TLDR
if ($StepsQuestions["TOOLS"].Answer -eq "yes") {
    try {
        Make-Directory -path "$downloadPath\env\tools"
        $tools = @()
        #region DOWNLOAD & SETUP EZA
        Write-Host "`nInstalling EZA (better ls)..."
        $ezaUrl = "https://github.com/eza-community/eza/releases/download/v0.18.21/eza.exe_x86_64-pc-windows-gnu.zip"
        Download-File -url $ezaUrl -output "$downloadPath\eza.zip"
        Extract-Zip -zipPath "$downloadPath\eza.zip" -extractPath "$downloadPath\env\tools\eza"
        $tools += "$downloadPath\env\tools\eza"
        Remove-Item "$downloadPath\eza.zip"
        #endregion

        #region DOWNLOAD & SETUP DELTA
        Write-Host "`nInstalling DELTA (better git diff)..."
        choco install delta -y > $null 2>&1
        #endregion

        #region DOWNLOAD & SETUP BAT
        Write-Host "`nInstalling BAT (better cat)..."
        choco install bat -y > $null 2>&1
        #endregion

        #region DOWNLOAD & SETUP FZF
        Write-Host "`nInstalling FZF (Fuzzy finder)..."
        choco install fzf -y > $null 2>&1
        #endregion
        
        #region DOWNLOAD & SETUP Z / ZOXIDE
        Write-Host "`nInstalling ZOXIDE/Z (better cd)..."
        choco install zoxide -y > $null 2>&1
        #endregion

        #region DOWNLOAD & SETUP TLDR
        Write-Host "`nInstalling TLDR (simplified man pages)..."
        choco install tldr -y > $null 2>&1
        #endregion

        $tools = $tools -join ";"
        Add-Env-Variable -newVariableName "tools" -newVariableValue $tools -updatePath 1 -overrideExistingEnvVars $overrideExistingEnvVars

        $WhatWasDoneMessages = Set-Success-Message -message "Tools (eza, delta, bat, fzf, zoxide, tldr) downloaded/installed & configured successfully" -WhatWasDoneMessages $WhatWasDoneMessages
    }
    catch {
        $WhatWasDoneMessages = Set-Error-Message -message "One of the tools (eza, delta, bat, fzf, zoxide) failed to download/install, try again" -exceptionMessage $_.InvocationInfo.PositionMessage -WhatWasDoneMessages $WhatWasDoneMessages
    }
}
#endregion

#region SETUP CMDER
if ($StepsQuestions["CMDER"].Answer -eq "yes") {
    try {
        $WhatWasDoneMessages = Setup-Cmder -downloadPath $downloadPath -WhatWasDoneMessages $WhatWasDoneMessages -overrideExistingEnvVars $overrideExistingEnvVars
        $WhatToDoNext = Set-Todo-Message -message "Start cmder and Run to check for any updates : > clink update" -WhatToDoNext $WhatToDoNext
        $WhatToDoNext = Set-Todo-Message -message "Start cmder and Run 'flexprompt configure' to customize the prompt style." -WhatToDoNext $WhatToDoNext
    }
    catch {
        $WhatWasDoneMessages = Set-Error-Message -message "Issue with downloading/installing cmder" -exceptionMessage $_.InvocationInfo.PositionMessage -WhatWasDoneMessages $WhatWasDoneMessages
    }
}
#endregion

#region DOWNLOAD FONTS
if ($StepsQuestions["FONTS"].Answer -eq "yes") {
    try {
        Write-Host "`nDownloading Font..."
        $nfUrls = @(
            "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS NF Regular.ttf",
            "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS NF Bold.ttf",
            "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS NF Italic.ttf",
            "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS NF Bold Italic.ttf",
            
            "https://github.com/powerline/fonts/raw/master/AnonymousPro/Anonymice Powerline Bold Italic.ttf",
            "https://github.com/powerline/fonts/raw/master/AnonymousPro/Anonymice Powerline Bold.ttf",
            "https://github.com/powerline/fonts/raw/master/AnonymousPro/Anonymice Powerline Italic.ttf",
            "https://github.com/powerline/fonts/raw/master/AnonymousPro/Anonymice Powerline.ttf"
        )
        Make-Directory -path "$downloadPath\fonts"
        foreach ($url in $nfUrls) {
            $fileName = Split-Path $url -Leaf
            try { Download-File -url $url -output "$downloadPath\fonts\$fileName" }
            catch { $WhatWasDoneMessages = Set-Error-Message -message "Fonts : Issue with $fileName" -WhatWasDoneMessages $WhatWasDoneMessages }
        }
        $WhatWasDoneMessages = Set-Success-Message -message "Fonts downloaded successfully" -WhatWasDoneMessages $WhatWasDoneMessages
        $WhatToDoNext = Set-Todo-Message -message "Install downloaded font and Add it to cmder settings." -WhatToDoNext $WhatToDoNext
    }
    catch {
        $WhatWasDoneMessages = Set-Error-Message -message "Fonts failed to download" -exceptionMessage $_.InvocationInfo.PositionMessage -WhatWasDoneMessages $WhatWasDoneMessages
    }
}
#endregion

#region DOWNLOAD MULTIPLE PHP VERSIONS
if ($StepsQuestions["PHP"].Answer -eq "yes") {
    try {
        Write-Host "`nDownloading PHP versions..."
        $phpUrls = @(
            "https://windows.php.net/downloads/releases/archives/php-5.6.9-Win32-VC11-x64.zip",
            "https://windows.php.net/downloads/releases/archives/php-7.0.9-Win32-VC14-x64.zip",
            "https://windows.php.net/downloads/releases/archives/php-7.1.9-Win32-VC14-x64.zip",
            "https://windows.php.net/downloads/releases/archives/php-7.2.9-Win32-VC15-x64.zip",
            "https://windows.php.net/downloads/releases/archives/php-7.3.9-Win32-VC15-x64.zip",
            "https://windows.php.net/downloads/releases/archives/php-7.4.9-Win32-vc15-x64.zip",
            "https://windows.php.net/downloads/releases/archives/php-8.0.9-Win32-vs16-x64.zip",
            "https://windows.php.net/downloads/releases/archives/php-8.1.9-Win32-vs16-x64.zip",
            "https://windows.php.net/downloads/releases/archives/php-8.2.9-Win32-vs16-x64.zip",
            "https://windows.php.net/downloads/releases/archives/php-8.3.9-Win32-vs16-x64.zip"
        )
        Make-Directory -path "$downloadPath\env\zip"
        Make-Directory -path "$downloadPath\env\php_stuff\php"
        foreach ($url in $phpUrls) {
            $fileNameZip = Split-Path $url -Leaf
            $fileName = $fileNameZip -replace ".zip", ""
            try {
                Download-File -url $url -output "$downloadPath\env\zip\$fileNameZip"
                Extract-Zip -zipPath "$downloadPath\env\zip\$fileNameZip" -extractPath "$downloadPath\env\php_stuff\php\$fileName"
                Copy-Item -Path "$downloadPath\env\php_stuff\php\$fileName\php.ini-development" -Destination "$downloadPath\env\php_stuff\php\$fileName\php.ini"
                if ($fileName -match "php-(\d+)\.(\d+)\.") {
                    $majorVersion = $matches[1]
                    $minorVersion = $matches[2]
                    if ($minorVersion -eq '0') { $phpEnvVarName = $majorVersion } 
                    else { $phpEnvVarName = "$majorVersion$minorVersion" }
                    $phpEnvVarName = "php$phpEnvVarName"
                    Add-Env-Variable -newVariableName $phpEnvVarName -newVariableValue "$downloadPath\env\php_stuff\php\$fileName" -updatePath 0 -overrideExistingEnvVars $overrideExistingEnvVars
                }
            } catch {
                $WhatWasDoneMessages = Set-Error-Message -message "PHP : Issue with $fileName" -WhatWasDoneMessages $WhatWasDoneMessages
            }
        }

        $VcUrls = @(
            "https://download.microsoft.com/download/1/6/B/16B06F60-3B20-4FF2-B699-5E9B7962F9AE/VSU_4/vcredist_x86.exe",
            "https://download.microsoft.com/download/1/6/B/16B06F60-3B20-4FF2-B699-5E9B7962F9AE/VSU_4/vcredist_x64.exe"
        )
        Make-Directory -path "$downloadPath\apps"
        foreach ($url in $VcUrls) {
            $fileName = Split-Path $url -Leaf
            try { Download-File -url $url -output "$downloadPath\apps\$fileName" }
            catch { $WhatWasDoneMessages = Set-Error-Message -message "PHP (VC++) : Issue with $fileName" -WhatWasDoneMessages $WhatWasDoneMessages }
        }
        Remove-Item -Path "$downloadPath\env\zip" -Recurse -Force

        # phpcs, phpcbf, phpmd, phpstan, phpfixer
        $phpTools = @(
            @{ name = "phpcs"; url = "https://squizlabs.github.io/PHP_CodeSniffer/phpcs.phar" }
            @{ name = "phpcbf"; url = "https://squizlabs.github.io/PHP_CodeSniffer/phpcbf.phar" }
            @{ name = "phpmd"; url = "https://github.com/phpmd/phpmd/releases/download/2.15.0/phpmd.phar" }
            @{ name = "phpstan"; url = "https://github.com/phpstan/phpstan/releases/download/1.11.5/phpstan.phar" }
            @{ name = "phpcsfixer"; url = "https://github.com/PHP-CS-Fixer/PHP-CS-Fixer/releases/download/v3.59.3/php-cs-fixer.phar" }
        )
        Make-Directory -path "$downloadPath\env\php_stuff\tools"
        foreach ($phpTool in $phpTools) {
            $url = $phpTool.url 
            $path = "$downloadPath\env\php_stuff\tools" 
            $fileName = $phpTool.name
            try {
                Download-File -url $url -output "$path\$fileName.phar"
                $batString = @"
                @echo OFF
                :: in case DelayedExpansion is on and a path contains ! 
                setlocal DISABLEDELAYEDEXPANSION
                php "%~dp0$fileName.phar" %*
"@
                $batString = $batString -replace "`t{2}"
                Add-Content -Path "$path\$fileName.bat" -Value $batString
            } catch {
                $WhatWasDoneMessages = Set-Error-Message -message "PHP (TOOLS) : Issue with $fileName" -WhatWasDoneMessages $WhatWasDoneMessages
            }
        }

        $WhatWasDoneMessages = Set-Success-Message -message "PHP versions (& Tools) were downloaded & setup successfully" -WhatWasDoneMessages $WhatWasDoneMessages
        $WhatToDoNext = Set-Todo-Message -message "Your PHP path is '$downloadPath\env\php_stuff\php'" -WhatToDoNext $WhatToDoNext
    }
    catch {
        $WhatWasDoneMessages = Set-Error-Message -message "PHP versions failed to download/setup" -exceptionMessage $_.InvocationInfo.PositionMessage -WhatWasDoneMessages $WhatWasDoneMessages
    }
}
#endregion

#region DOWNLOAD XDEBUG
if ($StepsQuestions["XDEBUG"].Answer -eq "yes") {
    try {
        Write-Host "`nDownloading XDEBUG..."
        $xdebugUrls = @(
            "https://xdebug.org/files/php_xdebug-3.3.2-8.3-vs16-x86_64.dll",
            "https://xdebug.org/files/php_xdebug-3.3.2-8.2-vs16-x86_64.dll",
            "https://xdebug.org/files/php_xdebug-3.3.2-8.1-vs16-x86_64.dll",
            "https://xdebug.org/files/php_xdebug-3.3.2-8.0-vs16-x86_64.dll",
            
            "https://xdebug.org/files/php_xdebug-3.3.1-8.3-vs16-x86_64.dll",
            "https://xdebug.org/files/php_xdebug-3.3.1-8.2-vs16-x86_64.dll",
            "https://xdebug.org/files/php_xdebug-3.3.1-8.1-vs16-x86_64.dll",
            "https://xdebug.org/files/php_xdebug-3.3.1-8.0-vs16-x86_64.dll",
            
            "https://xdebug.org/files/php_xdebug-3.3.0-8.3-vs16-x86_64.dll",
            "https://xdebug.org/files/php_xdebug-3.3.0-8.2-vs16-x86_64.dll",
            "https://xdebug.org/files/php_xdebug-3.3.0-8.1-vs16-x86_64.dll",
            "https://xdebug.org/files/php_xdebug-3.3.0-8.0-vs16-x86_64.dll",
            
            "https://xdebug.org/files/php_xdebug-3.2.2-8.2-vs16-x86_64.dll",
            "https://xdebug.org/files/php_xdebug-3.2.2-8.1-vs16-x86_64.dll",
            "https://xdebug.org/files/php_xdebug-3.2.2-8.0-vs16-x86_64.dll",
            
            "https://xdebug.org/files/php_xdebug-3.1.6-8.1-vs16-x86_64.dll",
            "https://xdebug.org/files/php_xdebug-3.1.6-8.0-vs16-x86_64.dll",
            "https://xdebug.org/files/php_xdebug-3.1.6-7.4-vc15-x86_64.dll",
            "https://xdebug.org/files/php_xdebug-3.1.6-7.3-vc15-x86_64.dll",
            "https://xdebug.org/files/php_xdebug-3.1.6-7.2-vc15-x86_64.dll",
            
            "https://xdebug.org/files/php_xdebug-3.0.4-8.0-vs16-x86_64.dll",
            "https://xdebug.org/files/php_xdebug-3.0.4-7.4-vc15-x86_64.dll",
            "https://xdebug.org/files/php_xdebug-3.0.4-7.3-vc15-x86_64.dll",
            "https://xdebug.org/files/php_xdebug-3.0.4-7.2-vc15-x86_64.dll",
        
            "https://xdebug.org/files/php_xdebug-2.9.8-7.4-vc15-x86_64.dll",
            "https://xdebug.org/files/php_xdebug-2.9.8-7.3-vc15-x86_64.dll",
            "https://xdebug.org/files/php_xdebug-2.9.8-7.2-vc15-x86_64.dll",
            "https://xdebug.org/files/php_xdebug-2.9.8-7.1-vc14-x86_64.dll",
        
            "https://xdebug.org/files/php_xdebug-2.8.0-7.4-vc15-x86_64.dll",
            "https://xdebug.org/files/php_xdebug-2.8.0-7.3-vc15-x86_64.dll",
            "https://xdebug.org/files/php_xdebug-2.8.0-7.2-vc15-x86_64.dll",
            "https://xdebug.org/files/php_xdebug-2.8.0-7.1-vc14-x86_64.dll",
            
            "https://xdebug.org/files/php_xdebug-2.7.0-7.3-vc15-x86_64.dll",
            "https://xdebug.org/files/php_xdebug-2.7.0-7.2-vc15-x86_64.dll",
            "https://xdebug.org/files/php_xdebug-2.7.0-7.1-vc14-x86_64.dll",
        
            "https://xdebug.org/files/php_xdebug-2.6.0-7.2-vc15-x86_64.dll",
            "https://xdebug.org/files/php_xdebug-2.6.0-7.1-vc14-x86_64.dll",
            "https://xdebug.org/files/php_xdebug-2.6.0-7.0-vc14-x86_64.dll",
            
            "https://xdebug.org/files/php_xdebug-2.5.5-7.1-vc14-x86_64.dll",
            "https://xdebug.org/files/php_xdebug-2.5.5-7.0-vc14-x86_64.dll",
            "https://xdebug.org/files/php_xdebug-2.5.5-5.6-vc11-x86_64.dll",
            
            "https://xdebug.org/files/php_xdebug-2.5.0-7.1-vc14-x86_64.dll",
            "https://xdebug.org/files/php_xdebug-2.5.0-7.0-vc14-x86_64.dll",
            "https://xdebug.org/files/php_xdebug-2.5.0-5.6-vc11-x86_64.dll",
            
            "https://xdebug.org/files/php_xdebug-2.4.0-7.0-vc14-x86_64.dll",
            "https://xdebug.org/files/php_xdebug-2.4.0-5.6-vc11-x86_64.dll",
            
            "https://xdebug.org/files/php_xdebug-2.3.3-5.6-vc11-x86_64.dll",
            "https://xdebug.org/files/php_xdebug-2.3.2-5.6-vc11-x86_64.dll",
            "https://xdebug.org/files/php_xdebug-2.3.1-5.6-vc11-x86_64.dll",
            "https://xdebug.org/files/php_xdebug-2.3.0-5.6-vc11-x86_64.dll"
        )
        Make-Directory -path "$downloadPath\env\php_stuff\xdebug"
        $phpVersionsWithXdebug = @()
        foreach ($url in $xdebugUrls) {
            $fileName = Split-Path $url -Leaf
            try {
                if ($fileName -match "-(\d+\.\d+)-(vs|vc)") {
                    $phpVersion = $matches[1]
                    Make-Directory -path "$downloadPath\env\php_stuff\xdebug\$phpVersion"
                    $outputPathXdebug = "$downloadPath\env\php_stuff\xdebug\$phpVersion\$fileName"
                    Download-File -url $url -output $outputPathXdebug

                    $phpPaths = Get-ChildItem -Path "$downloadPath\env\php_stuff\php" -Directory | Select-Object -ExpandProperty Name
                    if ($phpPaths.Count -gt 0) {
                        $xDebugConfig = @"

                        [xdebug]
                        zend_extension="$outputPathXdebug"
                        xdebug.remote_enable=1
                        xdebug.remote_host=127.0.0.1
                        xdebug.remote_port=9000
"@
                        if ($fileName -match "php_xdebug-([\d\.]+)") {
                            $xDebugVersion = $matches[1]
                            if ($xDebugVersion -like "3.*") {
                                $xDebugConfig = @"

                                    [xdebug]
                                    zend_extension="$outputPathXdebug"
                                    xdebug.mode=debug
                                    xdebug.client_host=127.0.0.1
                                    xdebug.client_port=9003
"@
                            }
                        }

                        foreach ($phpPath in $phpPaths) {
                            if ($phpPath -like "*$phpVersion*") {
                                if (-not($phpVersionsWithXdebug -contains $phpVersion)) {
                                    $phpVersionsWithXdebug += $phpVersion
                                    $xDebugConfig = $xDebugConfig -replace "\ +"
                                    Add-Content -Path "$downloadPath\env\php_stuff\php\$phpPath\php.ini" -Value $xDebugConfig
                                    break
                                }
                            }
                        }
                    }
                }
            } catch {
                $WhatWasDoneMessages = Set-Error-Message -message "XDEBUG : Issue with $fileName" -WhatWasDoneMessages $WhatWasDoneMessages
            }
        }
        $WhatWasDoneMessages = Set-Success-Message -message "XDEBUG versions downloaded & setup successfully" -WhatWasDoneMessages $WhatWasDoneMessages
        $WhatToDoNext = Set-Todo-Message -message "Your XDebug path is '$downloadPath\env\php_stuff\xdebug'" -WhatToDoNext $WhatToDoNext
    }
    catch {
        $WhatWasDoneMessages = Set-Error-Message -message "XDEBUG versions failed to download/setup" -exceptionMessage $_.InvocationInfo.PositionMessage -WhatWasDoneMessages $WhatWasDoneMessages
    }
}
#endregion

RefreshEnv.cmd

$WhatToDoNext = Set-Todo-Message -message "Run ./followup.ps1 when you're done for additional cmder configuration" -WhatToDoNext $WhatToDoNext

#region WHAT TO DO NEXT
What-ToDo-Next -WhatWasDoneMessages $WhatWasDoneMessages -WhatToDoNext $WhatToDoNext
#endregion
