Set-StrictMode -Version Latest
$here = Split-Path -Parent $MyInvocation.MyCommand.Path

# Determine The Path Of The Json Config File
$configPath = [string](Split-Path -Parent $MyInvocation.MyCommand.Definition) + '\HuBotPowerShellConfig.json'

# Internal Functions
. $here\Functions\Internal.ps1

. $here\Functions\New-HubotEnvironmentVariable.ps1
. $here\Functions\Import-HubotEnvironmentVariables.ps1

$functionsToExport = @(
    'New-HuBotEnvironmentVariable',
    'Import-HubotEnvironmentVariables'
)

Export-ModuleMember -Function $functionsToExport
