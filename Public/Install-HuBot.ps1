function Install-HuBot
{
    [CmdletBinding()]
    Param
    (
        # Path to the PoshHuBot Configuration File
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true
        )]
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

    Write-Verbose -Message "Installing Chocolatey"
    Invoke-Expression -Command ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))

    Write-Verbose -Message "Installing NodeJS"
    Start-Process -FilePath 'choco.exe' -ArgumentList 'install nodejs.install -version 5.10.1 -y' -Wait -NoNewWindow

    Write-Verbose -Message "Installing Git"
    Start-Process -FilePath 'choco.exe' -ArgumentList 'install git.install -y' -Wait -NoNewWindow

    Write-Verbose -Message "Reloading Path Enviroment Variables"
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

    Write-Verbose -Message "Installing CoffeeScript"
    Start-Process -FilePath npm -ArgumentList "install -g coffee-script" -Wait -NoNewWindow

    Write-Verbose -Message "Installing Hubot Generator"
    Start-Process -FilePath npm -ArgumentList "install -g yo generator-hubot" -Wait -NoNewWindow

    Write-Verbose -Message "Installing Forever"
    Start-Process -FilePath npm -ArgumentList "install -g forever" -Wait -NoNewWindow

    # Create bot directory
    if (-not(Test-Path -Path $Config.BotPath))
    {
        New-Item -Path $Config.BotPath -ItemType Directory
    }

    Write-Verbose -Message "Generating Bot"
    Start-Process -FilePath yo -ArgumentList "hubot --owner=""$($Config.BotOwner)"" --name=""$($Config.BotName)"" --description=""$($Config.BotDescription)"" --adapter=""$($Config.BotAdapter)"" --no-insight" -NoNewWindow -Wait -WorkingDirectory $Config.BotPath
}