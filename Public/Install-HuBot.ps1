function Install-HuBot
{
    [CmdletBinding()]
    Param
    (
        # Path to install your bot
        [Parameter(Mandatory=$true)]
        [string]
        $Path,

        # Name of the bot
        [Parameter(Mandatory=$true)]
        [string]
        $Name,

        # Name of the HuBot adapter to use
        [Parameter(Mandatory=$true)]
        [string]
        $Adapter,

        # Owner email address
        [Parameter(Mandatory=$true)]
        [string]
        $Owner,

        # Description of the bot
        [Parameter(Mandatory=$true)]
        [string]
        $Description 
    )

    Write-Verbose -Message "Installing Chocolatey"
    iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))

    Write-Verbose -Message "Installing NodeJS"
    choco install nodejs.install -y

    Write-Verbose -Message "Installing Git"
    choco install git.install -y

    Write-Verbose -Message "Reloading Path Enviroment Variables"
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

    Write-Verbose -Message "Installing CoffeeScript"
    Start-Process -FilePath npm -ArgumentList "install -g coffee-script" -Wait -NoNewWindow

    Write-Verbose -Message "Installing HuBot Generator"
    Start-Process -FilePath npm -ArgumentList "install -g yo generator-hubot" -Wait -NoNewWindow

    # Create bot directory
    if (-not(Test-Path -Path $Path))
    {
        New-Item -Path $Path -ItemType Directory
    }

    Write-Verbose -Message "Generating Bot"
    Start-Process -FilePath yo -ArgumentList "hubot --owner=""$($Owner)"" --name=""$($Name)"" --description=""$($Description)"" --adapter=""$($Adapter)""" -NoNewWindow -Wait -WorkingDirectory $Path
}