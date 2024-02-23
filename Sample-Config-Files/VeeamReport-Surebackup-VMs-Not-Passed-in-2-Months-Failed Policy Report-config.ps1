#requires -Version 5.0
<#

    .SYNOPSIS
    Configuration file for My Veeam Report.

    .DESCRIPTION
    Put here all your report customization settings.

    .NOTES
    Authors: Bernhard Roth & Marco Horstmann
    Last Updated: 19 June 2023
    Version: 12.0.0.1
#>
<#
	.UPDATES
	Eamonn Deering
	Last Updated: 10 Sep 2023
	Config Version: 12.0.0.3
	The following two settings requires MyVeeamReport Version: 12.0.0.5 or above.
	
	SureBackup update
		Added: $ReportHasDataEmail
		Added: $ReportSBFailingOnly
	
	.VM Exclusion 
	Added: Text file import with VM exclusions
	
	.SUGGESTIONS
	I find setting $setCSVDelimiter to  "," works well for Excel
	
	#> 

<# 	
	.$ReportHasDataEmail
	ED Works with Veeam 11 and 12
	Last Updated:	11 Aug 2023 
	
	DESCRIPTION
	Only email a report if the report has data other than a blank html page.
	Experimental. 
	Tested with: 
	 "Get SureBackup Tasks with Warnings or Failures" using $showTaskWFSb and $ReportSBFailingOnly
	 "Get VMs Missing Backups" using $missingVMsEmail="SendEmailReport"

	For SureBackup or "VMs Missing" if the list has no failed VM's then don't send the email. 
	 
#>
#The default is "$ReportHasDataEmail = $false" to ignore this setting.
$ReportHasDataEmail = $true
#$ReportHasDataEmail = $false

<#
	.$ReportSBFailingOnly
	ED Works with Veeam 11 and 12
	Last Updated:	11 Aug 2023 
	
	DESCRIPTION
	Only report a SB failed VM if that same VM never passed in the time frame.
	If your only interested in SB VM's that fail consistently over the time frame. 
	Example. Your SB jobs test VM's every week. Your time span is one month. If a VM fails every week then send email. If you have a ticketing system then this could log a ticket for you. 
	If a VM passes even once during the time span then don't send email. 
	Use with all other setting set to $false except "$showTaskWFSb = $true" and "$ReportSBFailingOnly = $true".

#>
#The default is "$ReportSBFailingOnly = $false" to ignore this setting.
$ReportSBFailingOnly = $true
#$ReportSBFailingOnly = $false



# VBR Server (Server Name, FQDN, IP or localhost)
$vbrServer = $env:computername
#$vbrServer = "lab-vbr01"
# Report mode (RPO) - valid modes: any number of hours, Weekly or Monthly
# 24, 48, "Weekly", "Monthly"
$reportMode = 1490

# Report Title
$rptTitle = "Surebackup VM Veeam Not-Passed-in-2-Months - Failed policy Report - Please investigate"
# Show VBR Server name in report header
$showVBR = $true
# HTML Report Width (Percent)
$rptWidth = 97
# HTML Table Odd Row color
$oddColor = "#f0f0f0"

# Location of Veeam Core dll  
$VeeamCorePath = "C:\Program Files\Veeam\Backup and Replication\Backup\Veeam.Backup.Core.dll"
#If you are connect remotely to VBR server you need to use another console.
#$VeeamCorePath = "C:\Program Files\Veeam\Backup and Replication\Console\Veeam.Backup.Core.dll"

# ED Moving reports into reports folder
if(!(Test-Path ".\Reports")){
	MD ".\Reports"}
# Save HTML output to a file
$saveHTML = $true
# HTML File output path and filename
$pathHTML = ".\Reports\VeeamReport-Surebackup-not-Passed-in-2-Months_$(Get-Date -format yyyyMMdd_HHmmss).htm"

# Launch HTML file after creation
$launchHTML = $true

# Save CSV output to files
$saveCSV = $false
# CSV File output path and filename
$baseFilenameCSV = ".\Reports\VeeamReport-Surebackup-not-Passed-in-2-Months_$(Get-Date -format yyyyMMdd_HHmmss)"
# Export All Tasks to CSV file
$exportAllTasksBkToCSV = $false
#Delimiter for CSV files
$setCSVDelimiter = ","


# Email configuration
$sendEmail = $false
$emailHost = "smtp.yourserver.com"
$emailPort = 25
$emailEnableSSL = $false
$emailUser = ""
$emailPass = ""
$emailFrom = "MyVeeamReport@yourdomain.com"
$emailTo = "you@youremail.com"
# Send HTML report as attachment (else HTML report is body)
$emailAttach = $false
# Email Subject 
$emailSubject = $rptTitle
# Append Report Mode to Email Subject E.g. My Veeam Report (Last 24 Hours)
$modeSubject = $true
# Append VBR Server name to Email Subject
$vbrSubject = $true
# Append Date and Time to Email Subject
$dtSubject = $false


#--------------------- Disable reports you do not need by setting them to "$false" below:                                                                                        
# Show VM Backup Protection Summary (across entire infrastructure)
$showSummaryProtect = $false
# Show VMs with No Successful Backups within RPO ($reportMode)
$showUnprotectedVMs = $false
# Show unprotected VMs for informational purposes only
$showUnprotectedVMsInfo = $false
# Show VMs with Successful Backups within RPO ($reportMode)
# Also shows VMs with Only Backups with Warnings within RPO ($reportMode)
$showProtectedVMs = $false
# Exclude VMs from Missing and Successful Backups sections
# $excludevms = @("vm1","vm2","*_replica")
$excludeVMs = @("")

##ED added text file import with exclusions.  
$ExcludeVMsSiteA = "C:\Scripts\Veeam\SiteA\Veeam-Exclude-VMs.txt"
$ExcludeVMsSiteB = "C:\Scripts\Veeam\SiteB\Veeam-Exclude-VMs.txt"

if(Test-Path $ExcludeVMsSiteA){
$ExcludeVMs += Get-Content $ExcludeVMsSiteA}
if(Test-Path $ExcludeVMsSiteB){
$ExcludeVMs += Get-Content $ExcludeVMsSiteB}
$excludeVMs += @("*_replica*","*vLAB*","*vLAN","*Template*")
$excludeVMs = $excludeVMs| Sort-Object -Property @{Expression={$_.Trim()}} -Unique
$excludeVMs

# Exclude VMs from Missing and Successful Backups sections in the following (vCenter) folder(s)
# $excludeFolder = @("folder1","folder2","*_testonly")
#$excludeFolder = @("")
$excludeFolder = @("DR-Testing","*Testing*","*Template*","*Powered-Off*","vm","vCLS","*To-Be-Deleted*","*vLab*")
# Exclude VMs from Missing and Successful Backups sections in the following (vCenter) datacenter(s)
# $excludeDC = @("dc1","dc2","dc*")
#$excludeDC = @("")
$excludeDC = @("*Test*")
# Exclude Templates from Missing and Successful Backups sections
$excludeTemp = $true

# Show VMs Backed Up by Multiple Jobs within time frame ($reportMode)
$showMultiJobs = $false

<#	
# Show Backup Session Summary
$showSummaryBk = $false
# Show Backup Job Status
$showJobsBk = $false
# Show File Backup Job Status
$showFileJobsBk = $false
# Show Backup Job Size (total)
$showBackupSizeBk = $false
# Show File Backup Job Size (total)
$showFileBackupSizeBk = $false
# Show detailed information for Backup Jobs/Sessions (Avg Speed, Total(GB), Processed(GB), Read(GB), Transferred(GB), Dedupe, Compression)
$showDetailedBk = $false
# Show all Backup Sessions within time frame ($reportMode)
$showAllSessBk = $false
# Show all Backup Tasks from Sessions within time frame ($reportMode)
$showAllTasksBk = $false
# Show Running Backup Jobs
$showRunningBk = $false
# Show Running Backup Tasks
$showRunningTasksBk = $false
# Show Backup Sessions w/Warnings or Failures within time frame ($reportMode)
$showWarnFailBk = $false
# Show Backup Tasks w/Warnings or Failures from Sessions within time frame ($reportMode)
$showTaskWFBk = $false
# Show Successful Backup Sessions within time frame ($reportMode)
$showSuccessBk = $false
# Show Successful Backup Tasks from Sessions within time frame ($reportMode)
$showTaskSuccessBk = $false
# Only show last Session for each Backup Job
$onlyLastBk = $false
# Only report on the following Backup Job(s)
#$backupJob = @("Backup Job 1","Backup Job 3","Backup Job *")
$backupJob = @("")

# Show Running Restore VM Sessions
$showRestoRunVM = $false
# Show Completed Restore VM Sessions within time frame ($reportMode)
$showRestoreVM = $false

# Show Replication Session Summary
$showSummaryRp = $false
# Show Replication Job Status
$showJobsRp = $false
# Show detailed information for Replication Jobs/Sessions (Avg Speed, Total(GB), Processed(GB), Read(GB), Transferred(GB), Dedupe, Compression)
$showDetailedRp = $false
# Show all Replication Sessions within time frame ($reportMode)
$showAllSessRp = $false
# Show all Replication Tasks from Sessions within time frame ($reportMode)
$showAllTasksRp = $false
# Show Running Replication Jobs
$showRunningRp = $false
# Show Running Replication Tasks
$showRunningTasksRp = $false
# Show Replication Sessions w/Warnings or Failures within time frame ($reportMode)
$showWarnFailRp = $false
# Show Replication Tasks w/Warnings or Failures from Sessions within time frame ($reportMode)
$showTaskWFRp = $false
# Show Successful Replication Sessions within time frame ($reportMode)
$showSuccessRp = $false
# Show Successful Replication Tasks from Sessions within time frame ($reportMode)
$showTaskSuccessRp = $false
# Only show last session for each Replication Job
$onlyLastRp = $false
# Only report on the following Replication Job(s)
#$replicaJob = @("Replica Job 1","Replica Job 3","Replica Job *")
$replicaJob = @("")

# Show Backup Copy Session Summary
$showSummaryBc = $false
# Show Backup Copy Job Status
$showJobsBc = $false
# Show Backup Copy Job Size (total)
$showBackupSizeBc = $false
# Show detailed information for Backup Copy Sessions (Avg Speed, Total(GB), Processed(GB), Read(GB), Transferred(GB), Dedupe, Compression)
$showDetailedBc = $false
# Show all Backup Copy Sessions within time frame ($reportMode)
$showAllSessBc = $false
# Show all Backup Copy Tasks from Sessions within time frame ($reportMode)
$showAllTasksBc = $false
# Show Idle Backup Copy Sessions
$showIdleBc = $false
# Show Pending Backup Copy Tasks
$showPendingTasksBc = $false
# Show Working Backup Copy Jobs
$showRunningBc = $false
# Show Working Backup Copy Tasks
$showRunningTasksBc = $false
# Show Backup Copy Sessions w/Warnings or Failures within time frame ($reportMode)
$showWarnFailBc = $false
# Show Backup Copy Tasks w/Warnings or Failures from Sessions within time frame ($reportMode)
$showTaskWFBc = $false
# Show Successful Backup Copy Sessions within time frame ($reportMode)
$showSuccessBc = $false
# Show Successful Backup Copy Tasks from Sessions within time frame ($reportMode)
$showTaskSuccessBc = $false
# Only show last Session for each Backup Copy Job
$onlyLastBc = $false
# Only report on the following Backup Copy Job(s)
#$bcopyJob = @("Backup Copy Job 1","Backup Copy Job 3","Backup Copy Job *")
$bcopyJob = @("")

# Show Tape Backup Session Summary
$showSummaryTp = $false
# Show Tape Backup Job Status
$showJobsTp = $false
# Show detailed information for Tape Backup Sessions (Avg Speed, Total(GB), Read(GB), Transferred(GB))
$showDetailedTp = $false
# Show all Tape Backup Sessions within time frame ($reportMode)
$showAllSessTp = $false
# Show all Tape Backup Tasks from Sessions within time frame ($reportMode)
$showAllTasksTp = $false
# Show Waiting Tape Backup Sessions
$showWaitingTp = $false
# Show Idle Tape Backup Sessions
$showIdleTp = $false
# Show Pending Tape Backup Tasks
$showPendingTasksTp = $false
# Show Working Tape Backup Jobs
$showRunningTp = $false
# Show Working Tape Backup Tasks
$showRunningTasksTp = $false
# Show Tape Backup Sessions w/Warnings or Failures within time frame ($reportMode)
$showWarnFailTp = $false
# Show Tape Backup Tasks w/Warnings or Failures from Sessions within time frame ($reportMode)
$showTaskWFTp = $false
# Show Successful Tape Backup Sessions within time frame ($reportMode)
$showSuccessTp = $false
# Show Successful Tape Backup Tasks from Sessions within time frame ($reportMode)
$showTaskSuccessTp = $false
# Only show last Session for each Tape Backup Job
$onlyLastTp = $false
# Only report on the following Tape Backup Job(s)
#$tapeJob = @("Tape Backup Job 1","Tape Backup Job 3","Tape Backup Job *")
$tapeJob = @("")

# Show all Tapes
$showTapes = $false
# Show all Tapes by (Custom) Media Pool
$showTpMp = $false
# Show all Tapes by Vault
$showTpVlt = $false
# Show all Expired Tapes
$showExpTp = $false
# Show Expired Tapes by (Custom) Media Pool
$showExpTpMp = $false
# Show Expired Tapes by Vault
$showExpTpVlt = $false
# Show Tapes written to within time frame ($reportMode)
$showTpWrt = $false

# Show Agent Backup Session Summary
$showSummaryEp = $false
# Show Agent Backup Job Status
$showJobsEp = $false
# Show Agent Backup Job Size (total)
$showBackupSizeEp = $false
# Show all Agent Backup Sessions within time frame ($reportMode)
$showAllSessEp = $false
# Show Running Agent Backup jobs
$showRunningEp = $false
# Show Agent Backup Sessions w/Warnings or Failures within time frame ($reportMode)
$showWarnFailEp = $false
# Show Successful Agent Backup Sessions within time frame ($reportMode)
$showSuccessEp = $false
# Only show last session for each Agent Backup Job
$onlyLastEp = $false
# Only report on the following Agent Backup Job(s)
#$epbJob = @("Agent Backup Job 1","Agent Backup Job 3","Agent Backup Job *")
$epbJob = @("")

# Show Configuration Backup Summary
$showSummaryConfig = $false
# Show Proxy Info
$showProxy = $false
# Show Repository Info
$showRepo = $false
# Show Repository Permissions for Agent Jobs
$showRepoPerms = $false
# Show Replica Target Info
$showReplicaTarget = $false
# Show Veeam Services Info (Windows Services)
$showServices = $false
# Show only Services that are NOT running
$hideRunningSvc = $false
# Show License expiry info
$showLicExp = $false
#>

# Show SureBackup Session Summary
$showSummarySb = $false
# Show SureBackup Job Status
$showJobsSb = $false
# Show all SureBackup Sessions within time frame ($reportMode)
$showAllSessSb = $false
# Show all SureBackup Tasks from Sessions within time frame ($reportMode)
$showAllTasksSb = $fales
# Show Running SureBackup Jobs
$showRunningSb = $false
# Show Running SureBackup Tasks
$showRunningTasksSb = $false
# Show SureBackup Sessions w/Warnings or Failures within time frame ($reportMode)
$showWarnFailSb = $false
# Show SureBackup Tasks w/Warnings or Failures from Sessions within time frame ($reportMode)
$showTaskWFSb 	= $true
# Show Successful SureBackup Sessions within time frame ($reportMode)
$showSuccessSb 	= $false
# Show Successful SureBackup Tasks from Sessions within time frame ($reportMode)
$showTaskSuccessSb = $false
# Only show last Session for each SureBackup Job
$onlyLastSb = $false
# Only report on the following SureBackup Job(s)
#$surebJob = @("SureBackup Job 1","SureBackup Job 3","SureBackup Job *")
$surebJob = @("")

#Start of unchanged reports since version 9.5.3
# ED Note. Most of the following look to work in V11 and VBR v12.0.0.1420 as is.																		
<#
# Show Replication Session Summary
$showSummaryRp = $false
# Show Replication Job Status
$showJobsRp = $false
# Show detailed information for Replication Jobs/Sessions (Avg Speed, Total(GB), Processed(GB), Read(GB), Transferred(GB), Dedupe, Compression)
$showDetailedRp = $false
# Show all Replication Sessions within time frame ($reportMode)
$showAllSessRp = $false
# Show all Replication Tasks from Sessions within time frame ($reportMode)
$showAllTasksRp = $false
# Show Running Replication Jobs
$showRunningRp = $false
# Show Running Replication Tasks
$showRunningTasksRp = $false
# Show Replication Sessions w/Warnings or Failures within time frame ($reportMode)
$showWarnFailRp = $false
# Show Replication Tasks w/Warnings or Failures from Sessions within time frame ($reportMode)
$showTaskWFRp = $false
# Show Successful Replication Sessions within time frame ($reportMode)
$showSuccessRp = $false
# Show Successful Replication Tasks from Sessions within time frame ($reportMode)
$showTaskSuccessRp = $false
# Only show last session for each Replication Job
$onlyLastRp = $false
# Only report on the following Replication Job(s)
#$replicaJob = @("Replica Job 1","Replica Job 3","Replica Job *")
$replicaJob = @("")

# Show Running Restore VM Sessions
$showRestoRunVM = $false
# Show Completed Restore VM Sessions within time frame ($reportMode)
$showRestoreVM = $false

end of excluded unchanged reports since version 9.5.3 #>


# Highlighting Thresholds
# Repository Free Space Remaining %
$repoCritical = 10
$repoWarn = 20
# Replica Target Free Space Remaining %
$replicaCritical = 10
$replicaWarn = 20
# License Days Remaining
$licenseCritical = 30
$licenseWarn = 90
