<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
function Remove-HubotScript
{
    [CmdletBinding()]
    Param
    (
        # Name of script to remove
        [Parameter(Mandatory=$true)]
        $Name,

        # Path to the PoshHubot Configuration File
        [Parameter(Mandatory=$false)]
        [ValidateScript({
        if(Test-Path -Path $_ -ErrorAction SilentlyContinue)
        {
            return $true
        }
        else
        {
            throw "$($_) is not a valid path."
        }
        })]
        [string]
        $ConfigPath,

        # Name of script to remove from the configuration file if different
        [Parameter(Mandatory=$false)]
        $NameInConfig=$Name
    )

    $Config = Import-HubotConfiguration -ConfigPath $ConfigPath

    if (-not(Test-Path -Path $Config.BotExternalScriptsPath))
    {
        throw "Cannot find Hubot external config at $($Config.BotExternalScriptsPath)."
    }

    Start-Process -FilePath npm -ArgumentList "uninstall $($Name) --save" -Wait -NoNewWindow -WorkingDirectory $Config.BotPath

    [System.Collections.ArrayList]$extenalScripts = Get-Content -Path $Config.BotExternalScriptsPath -Raw | ConvertFrom-Json

    if ($extenalScripts -contains $NameInConfig)
    {
        $extenalScripts.Remove($NameInConfig)

        $newConfigValue = $extenalScripts | ConvertTo-Json

        Write-Verbose "Removing $($NameInConfig) from $($Config.BotExternalScriptsPath)"

        Set-Content -Path $Config.BotExternalScriptsPath -Value $newConfigValue
    }
}
