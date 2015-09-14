function New-HubotEnvironmentVariable
{
    [CmdletBinding()]
    Param
    (
        # Name of the Environment Variable to set
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Name,

        # Value of the Environment Variable
        [Parameter(ParameterSetName='Standard',Mandatory=$true)]
        [string]
        $Value,

        # Enable if the environment variable is secretive, for example a password. This value will be stored as a secure string
        [Parameter(ParameterSetName='Secretive',Mandatory=$false)]
        [switch]
        $Secret,

        # Enable if the environment variable is secretive, for example a password. This value will be stored as a secure string
        [Parameter(ParameterSetName='Secretive',Mandatory=$true)]
        [string]
        $SecretValue
    )

    Begin
    {
        if(Test-Path -Path $ConfigPath) {
            $Config = Import-JsonConfig -ConfigPath $ConfigPath
        }
        else {
            Throw "Unable to find configuration file at $($ConfigPath)"   
        }

        if($Secret) {
            $Value = ConvertTo-SecureString -String $SecretValue -AsPlainText -Force | ConvertFrom-SecureString
        }
    }
    Process
    {
        if($Secret) {
            $Config.SecretEnvironmentVariables | Add-Member -MemberType NoteProperty -Name $Name -Value $Value
        }
        else {
            $Config.EnvironmentVariables | Add-Member -MemberType NoteProperty -Name $Name -Value $Value
        }
    }
    End
    {
        Set-Content -Path $ConfigPath -Value ($Config | ConvertTo-Json | Out-String)
    }
} 