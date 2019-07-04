$path = Join-Path -Path $PSScriptRoot -ChildPath 'DscResources'
# & git clone --recurse https://github.com/PowerShell/DscResources $Path

$metaTestOptInMasterFile = Join-Path -Path $PSScriptRoot -ChildPath '.MetaTestOptIn.json'
$metaTests = Get-Content -Path $metaTestOptInMasterFile | ConvertFrom-Json

$markdown = @()
$longDate = (Get-Date).ToLongDateString()
$markdown += "# DSCResource MetaTest OptIn Report $longDate"

$markdownTableHeader = '| Module |'
$markdownTableLine = '|-|'
foreach ($metaTest in $metaTests)
{
    $markdownTableHeader += ' ' + (($metaTest -replace 'Common Tests - ', '') -replace ' ', '<br>')
    $markdownTableHeader += ' |'
    $markdownTableLine += '-|'
}

$dscResourceFolders = @(
    'DscResources'
    'xDscResources'
)

foreach ($dscResourceFolder in $dscResourceFolders)
{
    $dscResourcePath = Join-Path -Path $path -ChildPath $dscResourceFolder
    $dscResources = Get-ChildItem -Path $dscResourcePath
    $markdown += ''
    $markdown += "## $dscResourceFolder"
    $markdown += ''
    $markDown += $markDownTableHeader
    $markDown += $markDownTableLine

    foreach ($dscResource in $dscResources)
    {
        $dscResourceUrl = "[$($dscResource.Name)](https://github.com/PowerShell/$($dscResource.Name))"
        $markdownModuleLine = "| $dscResourceUrl |"
        $metaTestOptInFile = "$($dscResource.FullName)\.MetaTestOptIn.json"

        if (Test-Path -Path $metaTestOptInFile)
        {
            $moduleMetaTests = Get-Content -Path $metaTestOptInFile | ConvertFrom-Json
        }
        else
        {
            $moduleMetaTests = @()
        }

        foreach ($metaTest in $metaTests)
        {
            if ($moduleMetaTests -Contains $metaTest)
            {
                $markdownModuleLine += ' Yes |'
            }
            else
            {
                $markdownModuleLine += ' No |'
            }
        }

        $markDown += $markdownModuleLine
    }
}

$readmeFilePath = Join-Path -Path $PSScriptRoot -ChildPath 'README.md'
$markDown | Out-File -FilePath $readmeFilePath -Encoding ascii
