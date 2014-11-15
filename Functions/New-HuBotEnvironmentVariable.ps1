Set-StrictMode -Version Latest

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
function New-HuBotEnvironmentVariable
{
    [CmdletBinding()]
    Param
    (
        # Name of the Environment Variable to set
        [Parameter(Mandatory=$true)]
        $Name,

        # Value of the Environment Variable
        [string]
        $Value,

        # Path To HuBotPowerShellConfig.json File
        [string]
        $configPath=[string](Split-Path -Parent $MyInvocation.MyCommand.Definition) + '\HuBotPowerShellConfig.json'
    )

    Begin
    {
        Write-Output $configPath

        if(Test-Path -Path $configPath)
        {
            $Config = Get-Content -Path $configPath | Out-String | ConvertFrom-Json
            Write-Output -InputObject $Config
        }
        else
        {
            throw "Unable to find HuBotPowerShellConfig.json at $($configPath)"
        }
    }
    Process
    {
    }
    End
    {
    }
}