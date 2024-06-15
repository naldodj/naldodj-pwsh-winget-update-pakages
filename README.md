# naldodj-pwsh-winget-update-pakages
Atualização de Pacotes do Windows 10+ utilizando PowerShell e WinGet

```powershell
# Limpa a tela para melhor legibilidade
Clear-Host

$downloadsPath = [System.IO.Path]::Combine($env:USERPROFILE, 'Downloads')

$HasWinget=$False

try {
    if (winget -version -quiet){
        $HasWinget=$True
    }

} catch {
    $HasWinget=$False
}

if ($HasWinget) {
     Write-Host "Winget instalado"
 } else {
    Write-Host "Winget não instalado"
    $progressPreference = 'silentlyContinue'
    Write-Information "Downloading WinGet and its dependencies..."
    Invoke-WebRequest -Uri https://aka.ms/getwinget -OutFile $downloadsPath\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle
    Invoke-WebRequest -Uri https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx -OutFile $downloadsPath\Microsoft.VCLibs.x64.14.00.Desktop.appx
    Invoke-WebRequest -Uri https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.8.6/Microsoft.UI.Xaml.2.8.x64.appx -OutFile $downloadsPath\Microsoft.UI.Xaml.2.8.x64.appx
    Add-AppxPackage $downloadsPath\Microsoft.VCLibs.x64.14.00.Desktop.appx
    Add-AppxPackage $downloadsPath\Microsoft.UI.Xaml.2.8.x64.appx
    Add-AppxPackage $downloadsPath\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle
 }

# Verifica se o módulo Microsoft.WinGet.Client está instalado e atualizado
if (Get-Module -ListAvailable -Name Microsoft.WinGet.Client) {
    Write-Host "Microsoft.WinGet.Client Module is installed."
    $moduleVersion = (Get-Module -Name Microsoft.WinGet.Client).Version
    if ($moduleVersion -lt [Version]"1.6.3133.0") {
        Write-Host "Updating Microsoft.WinGet.Client Module..."
        Update-Module -Name Microsoft.WinGet.Client -RequiredVersion 1.6.3133.0 -Confirm:$false
    } else {
        Write-Host "Microsoft.WinGet.Client Module is up to date."
    }
} else {
    Write-Host "Microsoft.WinGet.Client Module is not installed. Installing..."
    Install-Module -Name Microsoft.WinGet.Client -RequiredVersion 1.6.3133.0 -Force -Confirm:$false
}

# Verifica se o provedor NuGet está instalado
$nugetInstalled = Get-PackageProvider -Name NuGet -ErrorAction SilentlyContinue

if ($nugetInstalled) {
    $nugetVersion = $nugetInstalled.Version
    if ($nugetVersion -lt [Version]"2.8.5.201") {
        Write-Host "Updating NuGet Provider..."
        Update-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Confirm:$false
    } else {
        Write-Host "NuGet Provider is up to date."
    }
} else {
    Write-Host "NuGet Provider is not installed. Cannot check for updates."
}

# Executa o comando winget upgrade para verificar atualizações disponíveis
Write-Host "`nChecking for available package updates..."
winget upgrade -h --all --accept-source-agreements --include-unknown

# Obtém a lista de pacotes instalados e identifica os que têm atualizações disponíveis
$installed = Get-WinGetPackage -Source winget --accept-source-agreements
$updatable = $installed | Where-Object IsUpdateAvailable | Select-Object -ExpandProperty Id

# Se houver pacotes atualizáveis, atualiza-os
if ($updatable) {
    Write-Host "`nUpdating available packages...`n"
    foreach ($packageId in $updatable) {
        Write-Host "Updating package: $packageId"
        winget update $packageId
        Write-Host ""
    }
} else {
    Write-Host "`nNo updates available for installed packages."
}

```
