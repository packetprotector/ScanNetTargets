<#
.SYNOPSIS
This script takes in a list of websites and exports Netscraper scans using the Default Scan Policy. Reports are exported to specified output directory using the default "Detailed Scan Report" and "Vulnerabilities List (CSV)" report template options.
.DESCRIPTION
Script to scan mutliple targets in Netsparker. Taken from Netsparker's "scan mutliple websites" script with additions for CSV reporting and limiting concurrent scans.
.PARAMETER i
Specify input file with one target URL per line. (e.g. https://domain.com OR http://IP:PORT)
.PARAMETER o
Specify output directory. (e.g. C:\OUTPUT_DIRECTORY)
.PARAMETER s
Specify number of concurrent Netsparker scans. Default is two concurrent scans.
.PARAMETER h
Print the help message.
.NOTES
Version: 1.0

Built off a script taken from Netsparker.com with additions for CSV reports and limiting concurrent scans.
.EXAMPLE
ScanNetTargets.ps1 -i target_urls.txt -o C:\OUTPUT_DIRECTORY
.EXAMPLE
ScanNetTargets.ps1 -i target_urls.txt -o C:\OUTPUT_DIRECTORY -s 3
.LINK
Orignal script: https://www.netsparker.com/blog/docs-and-faqs/scan-multiple-websites-command-line/
#>

[CmdletBinding()]
Param(
   [Parameter(Mandatory=$false)][alias("InputFile")][string]$i="",
   [Parameter(Mandatory=$false)][alias("OutputDirectory")][string]$o="",
   [Parameter(Mandatory=$false)][alias("ConcurrentScans")][int]$s=2,
   [Parameter(Mandatory=$false)][alias("Help")][switch]$h=$false
)

#Instance check
function numInstances
{
    return @(Get-Process -ea SilentlyContinue "Netsparker").Count
}

#Display help
function displayHelp
{
    Write-Output "
    usage: ScanNetTargets.ps1 [-i] file [-o] path [options]

    -i <file>   Specify input file with one target URL per line. (e.g. https://domain.com OR http://IP:PORT)
            
    -o <path>   Specify output directory. (e.g. C:\OUTPUT_DIRECTORY)

    -s <int>    Specify number of concurrent Netsparker scans. Default is two concurrent scans.

    -h          Print this help message.
    "
}

#Need help
if($h)
{
	displayHelp
	exit
}

#Constant variables, change if needed
$execPath = "C:\Program Files (x86)\Netsparker\Netsparker.exe"
$reportTemplate = "Detailed Scan Report"
$vulnerabilities = "Vulnerabilities List (CSV)"
$scanPolicy = "Default Scan Policy"

#Parameter validation
$flag = try {Test-Path $i -PathType Leaf} catch {}
if($flag -eq $true){
    $urls = Get-Content $i
}
elseif($i -eq ""){
    Write-Host "Input file not specified."
    displayHelp
    exit   
}
else{
    Write-Host "Input file not found."
    displayHelp
    exit
}

$flag = try {Test-Path $o -PathType Container} catch {}
if($o -eq ""){
    $o = (Get-Item -Path ".\" -Verbose).FullName
    Write-Host "Output directory not specified. Will export to $($o)\_Results"
    $o = $o + "\Netsparker_Results"
    New-Item -ItemType Directory -Force -Path $o
    $reportPath = $o
}
elseif($flag -eq $false){
    New-Item -ItemType Directory -Force -Path $o
    $reportPath = $o    
}
else{
    $reportPath = $o
}

#Run Netsparker scan
 foreach ($url in $urls) {

    $flag = $true
    while($flag -eq $true){
        
        $count = numInstances

        if($count -lt $s){
            $flag = $false    
        }
        else{
            Start-Sleep -s 30
        }
    }
    
    $domain = ([System.URI]"$url")
    $report = $reportPath + "\Report-" + $domain.Scheme + "-" + $domain.Host + "-" + $domain.Port + "-" + (Get-Date -format "yyyy-MM-dd")
    $csv = $reportPath + "\Vulnerabilities-" + $domain.Scheme + "-" + $domain.Host + "-" + $domain.Port + "-" + (Get-Date -format "yyyy-MM-dd")
    Start-Process -FilePath "$execPath" -ArgumentList "/u ""$($domain.OriginalString)"" /p ""$scanPolicy"" /a /s /r ""$report"" /rt ""$reportTemplate"" /r ""$csv"" /rt ""$vulnerabilities"""
    Write-Host "Starting Netsparker scan for $($domain.OriginalString)"
}
