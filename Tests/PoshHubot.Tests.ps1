if(-not $PSScriptRoot)
{
    $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent
}

Import-Module $PSScriptRoot\..\PoshHubot.psd1

InModuleScope PoshHubot {

$config = @"
{
  "Path": "TestDrive:\\PoshHubot\\config.json",
  "BotAdapter": "slack",
  "BotDebugLog": {
    "IsPresent": true
  },
  "BotDescription": "my awesome bot",
  "BotPath": "TestDrive:\\myhubot",
  "BotOwner": "Matt <matt@email.com>",
  "LogPath": "TestDrive:\\PoshHubot\\Logs",
  "BotName": "bender",
  "ArgumentList": "--adapter slack",
  "BotExternalScriptsPath": "TestDrive:\\myhubot\\external-scripts.json",
  "PidPath": "TestDrive:\\myhubot\\bender.pid",
  "EnvironmentVariables": {
    "HUBOT_ADAPTER": "slack",
    "HUBOT_LOG_LEVEL": "debug",
    "HUBOT_SLACK_TOKEN": "xoxb-XXXXX-XXXXXX",
    "FILE_BRAIN_PATH": "TestDrive:\\PoshHubot\\"
  }
}
"@

    Describe 'Install-Hubot' {

    # Put the config file on disk
    Set-Content -Path "TestDrive:\config.json" -Value $config

    # Load the config file into varaible
    $configJson = $config | ConvertFrom-Json

        It 'throws if no valid path config path is given' {
            { Install-HuBot -ConfigPath 'TestDrive:\sLDhgflkuSDHfg.json' } | Should throw
        }

        Mock Start-Process { $true }
        Mock Invoke-Expression { $true }

        Install-HuBot -ConfigPath "TestDrive:\config.json"

        It 'installs chocolatey' {  
            Assert-MockCalled Invoke-Expression -Exactly 1 -ParameterFilter { $Command.Contains('chocolatey') }
        }

        $chocoInstalls = @(
            'install nodejs.install -y'
            'install git.install -y'
        )

        ForEach ($install in $chocoInstalls)
        {
            It "chocolatey runs $install" {
                Assert-MockCalled Start-Process -Exactly 1 -ParameterFilter { $FilePath.StartsWith('choco') -and $ArgumentList -eq $install }
            }
        }

        $npmInstalls = @(
            'install -g coffee-script'
            'install -g yo generator-hubot'
            'install -g forever'
        )

        ForEach ($install in $npmInstalls)
        {
            It "npm runs $install" {
                Assert-MockCalled Start-Process -Exactly 1 -ParameterFilter { $FilePath.StartsWith('npm') -and $ArgumentList -eq $install }
            }
        }

        It 'bot path folder gets created' {
            Test-Path $configJson.BotPath | Should be $true
        }

        It 'yo generates hubot' {
            Assert-MockCalled Start-Process -Exactly 1 -ParameterFilter { $FilePath.StartsWith('yo') -and $ArgumentList -eq "hubot --owner=""$($configJson.BotOwner)"" --name=""$($configJson.BotName)"" --description=""$($configJson.BotDescription)"" --adapter=""$($configJson.BotAdapter)"" --no-insight" }
        }
    }

    Describe "Configuration Generation and Import" {
        
        $newBot = @{
            Path = "TestDrive:\PoshHubot\config.json"
            BotName = 'bender'
            BotPath = "TestDrive:\myhubot"
            BotAdapter = 'slack'
            BotOwner = 'test@mail.com'
            BotDescription = 'my bot'
            LogPath = "TestDrive:\PoshHubot\Logs"
            BotDebugLog = $true
        }

        It "New-PoshHubotConfiguration generates config file" {
            New-PoshHubotConfiguration @newBot
            Test-Path -Path "TestDrive:\PoshHubot\config.json" | Should be $true
        }

        It "Import-HuBotConfiguration throws if no config exists" {
            { Import-HuBotConfiguration -ConfigPath "TestDrive:\sLDhgflkuSDHfg.json" } | Should throw
        }

        It "imports a valid configuration file without throw" {
            { Import-HuBotConfiguration -ConfigPath "TestDrive:\PoshHubot\config.json" } | Should not throw
        }

        It "throws when importing invalid configuration file" {
            Set-Content -Path "TestDrive:\PoshHubot\configbad.json" -Value "bad data"
            { Import-HuBotConfiguration -ConfigPath "TestDrive:\PoshHubot\configbad.json" } | Should throw
        }

        $goodConfig = Import-HuBotConfiguration -ConfigPath "TestDrive:\PoshHubot\config.json"

        It "config file has a bot adapater" {
            $goodConfig.BotAdapter | Should BeExactly 'slack'
        }

        It "config file has a bot name" {
            $goodConfig.BotName | Should BeExactly 'bender'
        }

        It "config file has a bot path" {
            $goodConfig.BotPath | Should BeExactly 'TestDrive:\myhubot'
        }

        It "config file has a bot owner" {
            $goodConfig.BotOwner | Should BeExactly 'test@mail.com'
        }

        It "config file has a bot description" {
            $goodConfig.BotDescription | Should BeExactly 'my bot'
        }

        It "config file has a hubot debug level environment variable" {
            $goodConfig.EnvironmentVariables.HUBOT_LOG_LEVEL | Should BeExactly 'debug'
        }
    }
}