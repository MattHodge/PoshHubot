<#
.Synopsis
   Short description
.DESCRIPTION
   Calls forever to stop Hubot.
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
function Stop-Hubot
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

    $Config = Import-HubotConfiguration -ConfigPath $ConfigPath

    $processParams = @{
        FilePath = 'cmd'
        ArgumentList = "/c forever stop ""$($Config.BotName)"""
        Wait = $true
        WorkingDirectory = $Config.BotPath
        NoNewWindow = $true
    }

    Write-Verbose "Stop Command:"
    Write-Verbose $processParams.ArgumentList
    if ($pscmdlet.ShouldProcess($processParams, "Stopping Hubot configuration."))
    {
        Start-Process @processParams
    }

}
