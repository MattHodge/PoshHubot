<#
.Synopsis
   Restarts Hubot
.DESCRIPTION
   Restarts Hubot
.EXAMPLE
   Restart-Hubot -ConfigPath 'C:\PoshHubot\config.json'
#>
function Restart-Hubot
{
    [CmdletBinding(SupportsShouldProcess)]
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

    if ($pscmdlet.ShouldProcess($ConfigPath, "Stopping Hubot configuration."))
    {
        Stop-Hubot -ConfigPath $ConfigPath
    }
    if ($pscmdlet.ShouldProcess($ConfigPath, "Starting Hubot configuration."))
    {
        Start-Hubot -ConfigPath $ConfigPath
    }
}
