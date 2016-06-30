<#
.Synopsis
   Imports a PoshHubot configuration file.
.DESCRIPTION
   Imports a PoshHubot configuration file.
.EXAMPLE
   Import-HubotConfiguration -ConfigPath C:\PoshHubot\config.json
#>
function Import-HubotConfiguration
{
    [CmdletBinding()]
    Param
    (
        # Path to the PoshHubot Configuration File
        [Parameter(Mandatory=$true)]
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
        $ConfigPath
    )

    try
    {
        $Config = Get-Content -Path $ConfigPath -Raw | ConvertFrom-Json
    }
    catch
    {
        throw "There was a problem importing the configuration file. Confirm your JSON formatting."
    }


    return $Config
}
