<#PSScriptInfo

.VERSION 1.0

.AUTHOR Sven Aelterman

.COMPANYNAME 

.COPYRIGHT 

.TAGS SSMS2016 SSMS SQLServer

.LICENSEURI 

.PROJECTURI https://github.com/SvenAelterman/powershell-scripts

.ICONURI 

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS 

.EXTERNALSCRIPTDEPENDENCIES 

.RELEASENOTES

.GUID 3e5a33cc-e743-4d67-9f03-80cd952bc3ce
#>

<# 

.DESCRIPTION 
Comments out the lines relating to NOT loading TFS SCC packags for SSMS 2016
By commenting out those lines the VS 2015 shell WILL load those packages and
TFS integration will be enabled.

This script may need to be run with Admin privileges - usually normal users
do not have write permission to files in the Program Files folders.

This assumes a x64 machine.
#>
$SsmsUndefPath = 'C:\Program Files (x86)\Microsoft SQL Server\130\Tools\Binn\ManagementStudio\ssms.pkgundef';
$TfsConfig = '// TFS SCC Configuration'

if (Test-Path $SsmsUndefPath)
{
    Write-Host "Found package definition file. Creating backup file $SsmsUndefPath.bak"
    Copy-Item $SsmsUndefPath ($SsmsUndefPath + ".bak")

    $content = Get-Content $SsmsUndefPath
    $LineCount = $content.Length

    for ($i = 0; $i -lt $LineCount; $i++)
    {
        $CurrentLine = $content[$i]

        # If this line starts with the TFS SCC Configuration marker
        if ($CurrentLine -match "^$TfsConfig")
        {
            # Found the first line relating to TFS
            # Comment out every next line until
            $TfsEndFound = $false

            while (!$TfsEndFound)
            {
                $i++
                $CurrentLine = $content[$i]

                # If the current line is not commented out
                if ($CurrentLine -NotMatch '^//')
                {
                    # Comment by adding //
                    $content[$i] = '//' + $CurrentLine
                }
                # If this line starts with the TFS SCC Configuration marker
                elseif ($CurrentLine -match "^$TfsConfig")
                {
                    $TfsEndFound = $true
                }
            } 

            # Update the pkgundef file
            Set-Content -Value $content -Path $SsmsUndefPath

            # Exit the outer for loop
            break 
        }
    }
}
else
{
    Write-Host "Could not find package definition file at $SsmsUndefPath - Is SSMS 2016 Installed? Is this an x64 Operating System?"
}
