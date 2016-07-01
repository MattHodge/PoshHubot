properties {
    # Name of the module
    $moduleName = 'PoshHubot'

    # Path for unit tests
    $unitTestsPath = "$($PSScriptRoot)\Tests\unit"

    # Artifact Root Path
    $artifactRootPath = "$($PSScriptRoot)\Artifact"

    # Artifact Module Path
    $artifactModulePath = "$($artifactRootPath)\$($moduleName)"

    # Path for manifests file
    $manifestPath = Join-Path -Path $artifactModulePath -ChildPath "$($moduleName).psd1"

    # List of the PowerShell scripts to test
    $filesToTest = Get-ChildItem *.psm1,*.psd1,*.ps1 -Recurse -Exclude *build.ps1,*.pester.ps1,*Tests.ps1
}

task default -depends Analyze, Test, BuildArtifact, UploadArtifact

task TestProperties { 
  Assert ($build_version -ne $null) "build_version should not be null"
}

task Analyze {
    ForEach ($testPath in $filesToTest)
    {
        try
        {
            Write-Output "Running ScriptAnalyzer on $($testPath)"

            if ($env:APPVEYOR)
            {
                Add-AppveyorTest -Name "PsScriptAnalyzer" -Outcome Running
                $timer = [System.Diagnostics.Stopwatch]::StartNew()
            }

            $saResults = Invoke-ScriptAnalyzer -Path $testPath -Verbose:$false
            if ($saResults) {
                $saResults | Format-Table
                $saResultsString = $saResults | Out-String
                if ($saResults.Severity -contains 'Error' -or $saResults.Severity -contains 'Warning')
                {
                    if ($env:APPVEYOR)
                    {
                        Add-AppveyorMessage -Message "PSScriptAnalyzer output contained one or more result(s) with 'Error or Warning' severity.`
                        Check the 'Tests' tab of this build for more details." -Category Error
                        Update-AppveyorTest -Name "PsScriptAnalyzer" -Outcome Failed -ErrorMessage $saResultsString                  
                    }               

                    Write-Error -Message "One or more Script Analyzer errors/warnings where found in $($testPath). Build cannot continue!"  
                }
                else
                {
                    Write-Output "All ScriptAnalyzer tests passed"

                    if ($env:APPVEYOR)
                    {
                        Update-AppveyorTest -Name "PsScriptAnalyzer" -Outcome Passed -StdOut $saResultsString -Duration $timer.ElapsedMilliseconds
                    }
                }
            }
        }
        catch
        {
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName
            Write-Output $ErrorMessage
            Write-Output $FailedItem
            Write-Error "The build failed when working with $($testPath)."
        }  
    }     
        
}

task Test {
    $testResults = .\Tests\appveyor.pester.ps1 -Test -TestPath $unitTestsPath
    # $testResults = Invoke-Pester -Path $unitTestsPath -PassThru
    if ($testResults.FailedCount -gt 0) {
        $testResults | Format-List
        Write-Error -Message 'One or more Pester unit tests failed. Build cannot continue!'
    }
}

task BuildArtifact -depends Analyze, Test {
    New-Item -Path $artifactRootPath -ItemType Directory -Force
    Start-Process -FilePath 'robocopy.exe' -ArgumentList "`"$($PSScriptRoot)`" `"$($artifactModulePath)`" /S /R:1 /W:1 /XD Artifact .kitchen .vagrant .git /XF .gitignore build.ps1 psakeBuild.ps1 *.yml PesterResults*.xml TestResults*.xml" -Wait -NoNewWindow
    
    # Only want proper releases when tagged
    if ($env:APPVEYOR_REPO_TAG_NAME -and ($env:APPVEYOR_REPO_BRANCH -eq 'master'))
    {
        Write-Output "Changing module version to Github tag version $($env:APPVEYOR_REPO_TAG_NAME)"
        (Get-Content $manifestPath -Raw).Replace("1.0.2", $env:APPVEYOR_REPO_TAG_NAME) | Out-File $manifestPath
        Compress-Archive -Path $artifactModulePath -DestinationPath "$($artifactModulePath)\$($env:APPVEYOR_REPO_TAG_NAME).zip" -Force
    }
    # Artifiacts are built every time but not published unless tagged. This is for local testing
    else
    {
        Write-Output "Not a tagged release, only building a CI Artifact"
        (Get-Content $manifestPath -Raw).Replace("1.0.2", $build_version) | Out-File $manifestPath
        Compress-Archive -Path $artifactModulePath -DestinationPath "$($artifactModulePath)-CI-$($build_version).zip" -Force
    }
}

task UploadArtifact -depends Analyze, Test, BuildArtifact  {

    # Get Zips
    $zips = Get-ChildItem -Path "$($artifactRootPath)\*.zip"

    # Upload Zipped Artifacts
    ForEach ($zip in $zips)
    {
        Write-Output "Found zip: $($zip.FullName)"

        # only upload artifacts on master branch
        if ($env:APPVEYOR -and ($env:APPVEYOR_REPO_BRANCH -eq 'master'))
        {
            Write-Output "Pushing $($zip.Fullname) to AppveyorArtifacts"
            Push-AppveyorArtifact $zip.FullName -FileName $zip.Name
        }
        else
        {
            Write-Output "If this was Appveyor AND master branch, I would have pushed $($zip.Fullname) to AppveyorArtifacts"
        }
    }

    # Publish Module
    # Upload artifiact only on tagging
    if ($env:APPVEYOR_REPO_TAG_NAME -and ($env:APPVEYOR_REPO_BRANCH -eq 'master'))
    {
        Write-Output "Publishing Module Located In $($artifactModulePath) to the PSGallery"
        Publish-Module -Path $artifactModulePath -NuGetApiKey $env:PSGalleryKey
    }
    else
    {
        Write-Output "If this was Appveyor AND master branch, $($artifactModulePath) would be published to PSGallery."
        Get-ChildItem $artifactModulePath | Remove-Item -Force -Recurse
    }
}