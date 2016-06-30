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
function Stop-HuBot
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

    $Config = Import-HuBotConfiguration -ConfigPath $ConfigPath

    $processParams = @{
        FilePath = 'cmd'
        ArgumentList = "/c forever stop ""$($Config.BotName)"""
        Wait = $true
        WorkingDirectory = $Config.BotPath
        NoNewWindow = $true
    }

    Write-Verbose "Stop Command:"
    Write-Verbose $processParams.ArgumentList 

    Start-Process @processParams
}