<#
.Synopsis
   Imports a PoshHuBot configuration file.
.DESCRIPTION
   Imports a PoshHuBot configuration file.
.EXAMPLE
   Import-HuBotConfiguration -ConfigPath C:\PoshHuBot\config.json
#>
function Import-HuBotConfiguration
{
    [CmdletBinding()]
    Param
    (
        # Path to the PoshHuBot Configuration File
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