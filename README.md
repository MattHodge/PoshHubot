# Hubot-PowerShell

Functions to work with Hubot

# Create a PoshHubot Configuration File
```powershell
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
```

# Install Hubot
```powershell
# Import the module
Import-Module -Name Hubot-PowerShell

# Build a hash table with configuration options for the bot
$installBot = @{
    'Path' = 'C:\myhubot'
    'Name' = 'clamps'
    'Adapter' = 'slack'
    'Owner' = 'matt'
    'Description' = 'my hubot!'
}

Install-HuBot @installBot -Verbose
```

# Add and Remove Scripts
Use the following commands to and and remove scripts from HuBot
```powershell
Remove-HuBotScript -Name 'hubot-redis-brain' -ConfigPath "$($installBot.Path)\external-scripts.json" -HubotPath $installBot.Path
Remove-HuBotScript -Name 'hubot-heroku-keepalive' -ConfigPath "$($installBot.Path)\external-scripts.json" -HubotPath $installBot.Path

# Remove procfile
if (Test-Path -Path "$($installBot.Path)\Procfile")
{
    Remove-Item -Path "$($installBot.Path)\Procfile" -Force
}

Install-HuBotScript -Name 'hubot-azure-scripts' -ConfigPath "$($installBot.Path)\external-scripts.json" -HubotPath $installBot.Path -NameInConfig 'hubot-azure-scripts/brain/storage-blob-brain'
Install-HuBotScript -Name 'hubot-auth' -ConfigPath "$($installBot.Path)\external-scripts.json" -HubotPath $installBot.Path
Install-HuBotScript -Name 'hubot-reload-scripts' -ConfigPath "$($installBot.Path)\external-scripts.json" -HubotPath $installBot.Path
Install-HuBotScript -Name 'hubot-jenkins-userauth' -ConfigPath "$($installBot.Path)\external-scripts.json" -HubotPath $installBot.Path
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
