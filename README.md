# Hubot-PowerShell

PowerShell Module to Install and Configure Hubot.

# Installation
## 1. Create a PoshHubot Configuration File
A configuration file needs to be created which will store the settings for your Hubot.

The below example will create a configuration file located at `C:\PoshHubot\config.json`.

```powershell

# Import the module
Import-Module -Name Hubot-PowerShell

# Create hash of configuration options
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

# Splat the hash to the CmdLet
New-PoshHubotConfiguration @newBot
```

## 2. Install Hubot
The next step is to install Hubot, using your configuration file.
```powershell
# Install Hubot
Install-Hubot -ConfigPath 'C:\PoshHubot\config.json'
```

## 3. Add or Remove Scripts (Optional)
Use the following commands to and and remove scripts from Hubot
```powershell
Remove-HubotScript -Name 'hubot-redis-brain' -ConfigPath 'C:\PoshHubot\config.json'
Remove-HubotScript -Name 'hubot-heroku-keepalive' -ConfigPath 'C:\PoshHubot\config.json'

# Remove procfile
if (Test-Path -Path "$($installBot.Path)\Procfile")
{
    Remove-Item -Path "$($installBot.Path)\Procfile" -Force
}

Install-HubotScript -Name 'hubot-azure-scripts' -NameInConfig 'hubot-azure-scripts/brain/storage-blob-brain' -ConfigPath 'C:\PoshHubot\config.json'
Install-HubotScript -Name 'hubot-auth' -ConfigPath 'C:\PoshHubot\config.json'
Install-HubotScript -Name 'hubot-reload-scripts' -ConfigPath 'C:\PoshHubot\config.json'
Install-HubotScript -Name 'hubot-jenkins-userauth' -ConfigPath 'C:\PoshHubot\config.json'
```

# Set Environment Variables
```powershell
$env:HUBOT_ADAPTER = $installBot.Adapter
$env:HUBOT_SLACK_TOKEN = 'xxxxxxxxxxxx'
$env:HUBOT_LOG_LEVEL = 'debug'

# Allow scripts to hit sites with self signed certificates
$env:NODE_TLS_REJECT_UNAUTHORIZED = "0"
```
# Start the bot
```
Start-Process -FilePath "$($installBot.Path)\bin\hubot.cmd" -ArgumentList "--adapter $($installBot.Adapter)" -Wait -WorkingDirectory $installBot.Path -NoNewWindow -RedirectStandardOutput '.\console.out' -RedirectStandardError '.\console.err'
```
