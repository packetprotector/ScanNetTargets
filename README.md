# ScanNetTargets
Version: 1.0

PowerShell Script to scan mutliple targets in Netsparker. Built off a script from Netsparker.com with additions for CSV reports and limiting concurrent scans.
 
Orignal script: https://www.netsparker.com/blog/docs-and-faqs/scan-multiple-websites-command-line/

This script takes in a list of websites and exports Netscraper scans using the Default Scan Policy. Reports are exported to specified output directory using the default "Detailed Scan Report" and "Vulnerabilities List (CSV)" report template options.

    usage: ScanNetTargets.ps1 [-i] file [-o] path [options]

    -i <file>   Specify input file with one target URL per line. (e.g. https://domain.com OR http://IP:PORT)
            
    -o <path>   Specify output directory. (e.g. C:\OUTPUT_DIRECTORY)

    -s <int>    Specify number of concurrent Netsparker scans. Default is two concurrent scans.

    -h          Print this help message.

Examples
  ScanNetTargets.ps1 -i target_urls.txt -o C:\OUTPUT_DIRECTORY

  ScanNetTargets.ps1 -i target_urls.txt -o C:\OUTPUT_DIRECTORY -s 3
