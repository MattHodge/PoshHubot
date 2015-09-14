# Hubot-PowerShell

Functions to work with Hubot

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
