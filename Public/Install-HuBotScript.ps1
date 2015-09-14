<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
function Install-HuBotScript
{
    [CmdletBinding()]
    Param
    (
        # Name of script to remove
        [Parameter(Mandatory=$true)]
        $Name,

        # Path to Hubot json file to remove script from
        [Parameter(Mandatory=$false)]
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
        $ConfigPath,

        # Path to Hubot Directory
        [Parameter(Mandatory=$false)]
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
        $HubotPath,

        # Name of script to add to the configuration file
        [Parameter(Mandatory=$false)]
        $NameInConfig=$Name
    )

    Start-Process -FilePath npm -ArgumentList "install $($Name) --save" -Wait -NoNewWindow -WorkingDirectory $HubotPath

    [System.Collections.ArrayList]$extenalScripts = Get-Content -Path $ConfigPath | ConvertFrom-Json

    if ($extenalScripts -notcontains $NameInConfig)
    {
        $extenalScripts.Add($NameInConfig)

        $newConfigValue = $extenalScripts | ConvertTo-Json

        Write-Verbose "Adding $($NameInConfig) to $($ConfigPath)"

        Set-Content -Path $ConfigPath -Value $newConfigValue
    }
}