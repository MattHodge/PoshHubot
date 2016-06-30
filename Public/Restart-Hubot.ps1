<#
.Synopsis
   Restarts Hubot
.DESCRIPTION
   Restarts Hubot
.EXAMPLE
   Restart-Hubot -ConfigPath 'C:\PoshHubot\config.json'
#>
function Restart-HuBot
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

    Stop-HuBot -ConfigPath $ConfigPath
    Start-HuBot -ConfigPath $ConfigPath
}