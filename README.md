# Hubot-PowerShell

PowerShell Module to Install and Configure Hubot.

# Installation
## 1. Create a PoshHubot Configuration File
A configuration file needs to be created which will store the settings for your Hubot.

The below example will create a configuration file located at `C:\PoshHubot\config.json`.

```powershell

# Import the module
Import-Module -Name Hubot-PowerShell -Force

# Create hash of configuration options
$newBot = @{
    Path = "C:\PoshHubot\config.json"
    BotName = 'bender'
    BotPath = 'C:\myhubot'
    BotAdapter = 'slack'
    BotOwner = 'Matt <matt@email.com>'
    BotDescription = 'my awesome bot'
    LogPath = 'C:\PoshHubot\Logs'
    BotDebugLog = $true
}

# Splat the hash to the CmdLet
New-PoshHubotConfiguration @newBot
```

Here are the possible configuration options for PoshHubot. They can be passed in as parameters or manually added to the configuration file.

Key | Example Value | Description
--- | --- | ---
Path | `C:\PoshHubot\config.json` | Path to create a PoshHubot configuration file
BotName | `bender` | Name to give the bot
BotPath | `C:\myhubot` | Path to install the bot to
BotAdapter | `slack` | The bot adapter to use. [List of adapters here](https://github.com/github/hubot/blob/master/docs/adapters.md)
BotOwner | `Matt <matt@email.com>` | Bot owner
BotDescription | `my awesome bot` | Bot description
LogPath | `C:\PoshHubot\Logs` | Directory to store bot log files
BotDebugLog | `$true` | Enable debug level logging for Hubot
ArgumentList | `--adapter $($BotAdapter)` | Command line parameters to pass to Hubot when it starts

You will also notice that when your configuration file is created, it creates some additional keys in the json file that are set depending on the parameters you provided. It will look similar to this:

```json
{
    "Path":  "C:\\PoshHubot\\config.json",
    "BotAdapter":  "slack",
    "BotDebugLog":  {
                        "IsPresent":  true
                    },
    "BotDescription":  "my awesome bot",
    "BotPath":  "C:\\myhubot",
    "BotOwner":  "Matt \u003cmatt@email.com\u003e",
    "LogPath":  "C:\\PoshHubot\\Logs",
    "BotName":  "bender",
    "ArgumentList":  "--adapter slack",
    "BotExternalScriptsPath":  "C:\\myhubot\\external-scripts.json",
    "PidPath":  "C:\\myhubot\\bender.pid",
    "EnvironmentVariables":  {
                                 "HUBOT_ADAPTER":  "slack",
                                 "HUBOT_LOG_LEVEL":  "debug"
                             }
}
```

These are optional settings or allow you to override settings if you have a non-default configuration.

Key | Description
--- | ---
BotExternalScriptsPath | Path to the Hubot external-scripts file where community scripts need to be added
PidPath | Path to store the pid file when running Hubot as a background daemon
EnvironmentVariables | Hubot scripts often require environment variables to be set. Set them here as key/value pairs and they will be loaded before the Hubot background process is started


## 2. Install Hubot
The next step is to install Hubot using your configuration file.
```powershell
# Install Hubot
Install-Hubot -ConfigPath 'C:\PoshHubot\config.json'
```

This will install the prerequisites for using Hubot and configure it:
* Installs Chocolatey
* Installs NodeJS
* Installs Git
* Installs CoffeeScript
* Installs the Hubot Generator
* Installs *Forever* which will run Hubot as a background process

## 3. Add or Remove Scripts (Optional)
Use the following commands to and and remove scripts from Hubot
```powershell
Remove-HubotScript -Name 'hubot-redis-brain' -ConfigPath 'C:\PoshHubot\config.json'
Remove-HubotScript -Name 'hubot-heroku-keepalive' -ConfigPath 'C:\PoshHubot\config.json'

Install-HubotScript -Name 'hubot-auth' -ConfigPath 'C:\PoshHubot\config.json'
Install-HubotScript -Name 'hubot-reload-scripts' -ConfigPath 'C:\PoshHubot\config.json'
Install-HubotScript -Name 'hubot-jenkins-userauth' -ConfigPath 'C:\PoshHubot\config.json'

# Some scripts have a different name that is used to add them to the configuration file, which can be manually specified
Install-HubotScript -Name 'hubot-azure-scripts' -NameInConfig 'hubot-azure-scripts/brain/storage-blob-brain' -ConfigPath 'C:\PoshHubot\config.json'

```

## 4. Environment Variables
Hubot scripts often require some environment variables to be set before the script starts. You can configure these in your json file as above, or you can set them manually on the command line for example:

```powershell
# Set the Slack API token
$env:HUBOT_SLACK_TOKEN = 'xxxxxxxxxxxx'

# Allow scripts to hit sites with self signed certificates
$env:NODE_TLS_REJECT_UNAUTHORIZED = "0"
```

## 5. Managing the Bot
Once you have your environment variables sorted out, you can start Hubot.

```powershell
Start-Hubot -ConfigPath "C:\PoshHubot\config.json"
```

Once the bot has been started, you can use the **forever** tool to view the status of the Hubot process.

```powershell
forever list
```

You now close the PowerShell session and the bot will still be running in the background. **forever** will also automatically restart the bot if it should crash for whatever reason.

If you need to stop the bot run the following

```powershell
Stop-Hubot -ConfigPath "C:\PoshHubot\config.json"
```

![Hubot Management](https://i.imgur.com/kDxu4sf.png)

## 5. Log files

The PoshHubot script itself does not have any log files, but the Hubot does. These will be captured and logged.

![Hubot Logs](http://i.imgur.com/JaVIkIC.png)
