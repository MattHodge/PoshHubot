<#
.Synopsis
   Creates a new PoshHubot Configuration file.
.DESCRIPTION
   Creates a new PoshHubot Configuration file.
.EXAMPLE
    $newBot = @{
        Path = "C:\PoshHubot\config.json"
        BotName = 'bender'
        BotPath = "C:\myhubot"
        BotAdapter = 'slack'
        BotOwner = 'matt'
        BotDescription = 'my@email.com'
        LogPath = "C:\PoshHubot\Logs"
        LogLevel = 'DEBUG'
    }

    New-HubotConfiguration @newBot

    Generates a new PoshHubot configuration file
#>
function New-PoshHubotConfiguration
{
    [CmdletBinding()]
    Param
    (
        # Path to the PoshHubot Configuration File eg. C:\PoshHubot\config.json
        [Parameter(Mandatory=$true)]
        [string]
        $Path,

        # Name of the bot
        [Parameter(Mandatory=$true)]
        [string]
        $BotName,

        # Path to install the bot
        [Parameter(Mandatory=$true)]
        [string]
        $BotPath,

        # Name of the Hubot adapter to use
        [Parameter(Mandatory=$true)]
        [string]
        $BotAdapter,

        # Owner email address
        [Parameter(Mandatory=$true)]
        [string]
        $BotOwner,

        # Description of the bot
        [Parameter(Mandatory=$true)]
        [string]
        $BotDescription,

        # Path to write log files
        [Parameter(Mandatory=$true)]
        [string]
        $LogPath,

        # The level of logging to show. This is useful when you only want to log and show error logs for instance
        [Parameter(Mandatory=$false)]
        [ValidateSet("DEBUG", "INFO", "WARN", "ERROR")]
        $LogLevel= 'DEBUG',

        # Command line argument to use when running Hubot.
        [Parameter(Mandatory=$false)]
        $ArgumentList = "--adapter $($BotAdapter)",

        # The maximum file size in MB of the log before it rolls over
        [Parameter(Mandatory=$false)]
        [ValidateRange(1,1024)]
        [int]
        $LogMaxFileSizeMB = 10
    )

    # create folder to hold configuration file
    $folderToCreate = Split-Path -Path $Path

    if (-not(Test-Path -Path $folderToCreate))
    {
        New-Item -Path $folderToCreate -ItemType directory | Out-Null
    }

    $params = $PSBoundParameters

    # Adding manually as not a mandatory params
    $params.ArgumentList = $ArgumentList
    $params.BotExternalScriptsPath = "$($BotPath)\external-scripts.json"
    $params.LogMaxFileSizeMB = $LogMaxFileSizeMB

    # Create a path to the pid file
    $params.PidPath = "$($params.BotPath)\$($params.BotName).pid"

    # Add some environment variables
    $params.EnvironmentVariables += @{ 
        'HUBOT_ADAPTER' = $BotAdapter
    }

    # Enable Debugging for Hubot
    if ($LogLevel -eq 'DEBUG')
    {
        $params.EnvironmentVariables += @{ 
            'HUBOT_LOG_LEVEL' = 'debug' 
        }
    }

    $json = $params | ConvertTo-Json

    Write-Verbose $json

    try
    {
        Set-Content -Path $Path -Value $json
        Write-Output "PoshHubot Configuration saved to $($Path)."
    }
    catch
    {
        throw "Error writing configuration file."
    }
}