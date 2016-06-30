    function Install-Chocolatey
    {
        Write-Verbose -Message "Installing Chocolatey"
        Invoke-WebRequest -Uri 'https://chocolatey.org/install.ps1' -UseBasicParsing -OutFile "$($env:TEMP)\chocoinstall.ps1"
        ."$($env:TEMP)\chocoinstall.ps1"
    }