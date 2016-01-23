# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = '2'

Vagrant.require_version '>= 1.5.0'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.hostname = 'hubotps'

  config.vm.synced_folder '.', 'C:/PROGRA~1/WindowsPowerShell/Modules/PoshHubot'

  config.vm.box = 'kensykora/windows_2012_r2_standard'

  config.vm.network :private_network, type: 'dhcp'

  config.vm.provider 'virtualbox' do |v|
    v.gui = true
    v.cpus = 2
    v.memory = 2048
  end

  # Set your Hubot integration API Token from Slack
  slack_api_token = 'xoxb-XXXXXXXXX-XXXXXXXXXXXXXXXXXXX'
  # Set your bot name
  bot_name = 'bender'

  hubotsetup = <<SCRIPT
    Import-Module PoshHubot

    $configPath = 'C:\\PoshHubot\\config.json'
    if (Test-Path $configPath)
    {
      Stop-Hubot -ConfigPath $configPath
    }

    if (-not(Test-Path 'C:\\myhubot\\bin\\hubot.cmd'))
    {
      $newBot = @{
          Path = $configPath
          BotName = '#{bot_name}'
          BotPath = 'C:\\myhubot'
          BotAdapter = 'slack'
          BotOwner = 'PoshHubot <posh@hubot.com>'
          BotDescription = 'PoshHubot is awesome.'
          LogPath = 'C:\\PoshHubot\\Logs'
          BotDebugLog = $true
      }

      New-PoshHubotConfiguration @newBot

      Install-Hubot -ConfigPath $configPath
    }

    $env:HUBOT_SLACK_TOKEN = '#{slack_api_token}'

    Start-Hubot -ConfigPath $configPath
SCRIPT

  config.vm.provision 'shell', inline: hubotsetup
end
