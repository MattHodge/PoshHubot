if(-not $PSScriptRoot)
{
    $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent
}

Import-Module $PSScriptRoot\..\..\PoshHubot.psd1 -Force

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

        BeforeEach {
            # Put the config file on disk
            Set-Content -Path "TestDrive:\config.json" -Value $config

            # Load the config file into varaible
            $configJson = $config | ConvertFrom-Json

            Mock Start-Process { return $true }
            Mock Install-Chocolatey { return $true }
        }

        It 'throws if no valid path config path is given' {
            { Install-HuBot -ConfigPath 'TestDrive:\sLDhgflkuSDHfg.json' } | Should throw
        }


        It 'installs chocolatey' {
            Install-HuBot -ConfigPath "TestDrive:\config.json"  
            Assert-MockCalled Install-Chocolatey -Exactly 1
        }

        It "chocolatey runs install nodejs.install -y" {
            Install-HuBot -ConfigPath "TestDrive:\config.json"
            Assert-MockCalled Start-Process -Exactly 1 -ParameterFilter { $ArgumentList.StartsWith('install node') } -Scope It
        }

        It "chocolatey runs install git.install -y" {
            Install-HuBot -ConfigPath "TestDrive:\config.json"
            Assert-MockCalled Start-Process -Exactly 1 -ParameterFilter { $ArgumentList.StartsWith('install git') } -Scope It
        }

        $npmInstalls = @(
            'install -g coffee-script'
            'install -g yo generator-hubot'
            'install -g forever'
        )

        ForEach ($install in $npmInstalls)
        {
            It "npm runs $install" {
                Install-HuBot -ConfigPath "TestDrive:\config.json"
                Assert-MockCalled Start-Process -Exactly 1 -ParameterFilter { $ArgumentList.Trim().StartsWith($install) } -Scope It
            }
        }

        It 'bot path folder gets created' {
            Test-Path $configJson.BotPath | Should be $true
        }

        It 'yo generates hubot' {
            Install-HuBot -ConfigPath "TestDrive:\config.json"
            Assert-MockCalled Start-Process -Exactly 1 -ParameterFilter { $FilePath.StartsWith('yo') -and $ArgumentList.StartsWith('hubot --owner=') } -Scope It
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