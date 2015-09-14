function Import-HubotEnvironmentVariables
{
    [CmdletBinding()]
    Param
    (

    )

    Begin
    {
        if(Test-Path -Path $ConfigPath) {
            $Config = Import-JsonConfig -ConfigPath $ConfigPath
        }
        else {
            Throw "Unable to find configuration file at $($ConfigPath)"   
        }
    }
    Process
    {
        $Config.EnvironmentVariables.psobject.Properties | ForEach-Object {
            Set-Item -Path "env:$($_.Name)" -Value $_.Value
            Write-Verbose "Imported Environment Variable env:$($_.Name)"
        }

        $Config.SecretEnvironmentVariables.psobject.Properties | ForEach-Object {
            $secString = ConvertTo-SecureString -String $_.Value
            $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secString)
            $decodedString = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
            Set-Item -Path "env:$($_.Name)" -Value $decodedString
            Write-Verbose "Imported Secret Environment Variable env:$($_.Name)"
        }
    }
    End
    {
    }
}