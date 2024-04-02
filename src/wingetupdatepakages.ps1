# Limpa a tela para melhor legibilidade
Clear-Host

# Verifica se o módulo Microsoft.WinGet.Client está instalado e atualizado
if (Get-Module -ListAvailable -Name Microsoft.WinGet.Client) {
    Write-Host "Microsoft.WinGet.Client Module is installed."
    $moduleVersion = (Get-Module -Name Microsoft.WinGet.Client).Version
    if ($moduleVersion -lt [Version]"1.6.3133.0") {
        Write-Host "Updating Microsoft.WinGet.Client Module..."
        Update-Module -Name Microsoft.WinGet.Client -RequiredVersion 1.6.3133.0
    } else {
        Write-Host "Microsoft.WinGet.Client Module is up to date."
    }
} else {
    Write-Host "Microsoft.WinGet.Client Module is not installed. Installing..."
    Install-Module -Name Microsoft.WinGet.Client -RequiredVersion 1.6.3133.0 -Force
}

# Executa o comando winget upgrade para verificar atualizações disponíveis
Write-Host "`nChecking for available package updates..."
winget upgrade -h --all

# Obtém a lista de pacotes instalados e identifica os que têm atualizações disponíveis
$installed = Get-WinGetPackage -Source winget
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
