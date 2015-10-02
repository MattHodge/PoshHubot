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
function Install-HuBotScript
{
    [CmdletBinding()]
    Param
    (
        # Name of script to remove
        [Parameter(Mandatory=$true)]
        $Name,

        # Path to the PoshHuBot Configuration File
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

        # Name of script to add to the configuration file
        [Parameter(Mandatory=$false)]
        $NameInConfig=$Name
    )

    $Config = Import-HuBotConfiguration -ConfigPath $ConfigPath

    Start-Process -FilePath npm -ArgumentList "install $($Name) --save" -Wait -NoNewWindow -WorkingDirectory $Config.BotPath

    [System.Collections.ArrayList]$extenalScripts = Get-Content -Path $Config.BotExternalScriptsPath  | ConvertFrom-Json

    if ($extenalScripts -notcontains $NameInConfig)
    {
        $extenalScripts.Add($NameInConfig)

        $newConfigValue = $extenalScripts | ConvertTo-Json

        Write-Verbose "Adding $($NameInConfig) to $($Config.BotExternalScriptsPath)"

        Set-Content -Path $Config.BotExternalScriptsPath -Value $newConfigValue
    }
}