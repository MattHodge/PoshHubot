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
function Start-HuBot
{
    [CmdletBinding()]
    Param
    (
        # Adapter you are using
        [Parameter(Mandatory=$true)]
        [string]
        $Adapter,

        # Path to the HuBot
        [string]
        $Path
    )

    while($true)
    {
        Write-EventLog –LogName Application –Source 'HuBot' –EntryType Information –EventID 1 –Message "Starting HuBot from '$($Path)' using adapter '$($Adapter)'"
        
        $startProcArgs = @{
            FilePath = "$($Path)\bin\hubot.cmd"
            ArgumentList = "--adapter $($Adapter)"
            Wait = $true
            WorkingDirectory = $Path
            NoNewWindow = $true
            RedirectStandardOutput = "$($Path)\console.log"
            RedirectStandardError = "$($Path)\console.err"
        }

        Start-Process @startProcArgs

        Write-EventLog –LogName Application –Source 'HuBot' –EntryType Error –EventID 2 –Message "HuBot has crashed for some reason. Details logged to event log."
        
        $last50 = Get-Content "$($Path)\console.log"  -Tail 50

        Write-EventLog –LogName Application –Source 'HuBot' –EntryType Error –EventID 2 –Message "Last Messages: $($last50)"

        Write-EventLog –LogName Application –Source 'HuBot' –EntryType Information –EventID 3 –Message "Sleeping 10 seconds before starting again."

        Start-Sleep -Seconds 10
    }
}


Start-HuBot -Adapter slack -Path C:\myhubot

