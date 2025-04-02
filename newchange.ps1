# Prompt user for SQL Server and Database Name
$ServerName = Read-Host "Enter your SQL Server name (e.g., localhost\SQLEXPRESS)"
$DatabaseName = Read-Host "Enter your Database name"

# Prompt user for log file path
$LogFile = Read-Host "Enter the full path for saving the log file (e.g., C:\Logs\ProcedureChangeHistory.txt)"

# SQL Query to Retrieve Stored Procedure Change History
$Query = @"
SELECT 
    ID,
    ProcedureName,
    EventType,
    ModifiedBy,
    ModifiedDate,
    ProcedureDefinition 
FROM ProcContentHistory
ORDER BY ModifiedDate DESC;
"@

# Execute SQL Query using Invoke-Sqlcmd
try {
    # Ensure SQL Server module is installed
    if (-not (Get-Module -ListAvailable -Name SqlServer)) {
        Install-Module -Name SqlServer -Force -AllowClobber
    }

    Import-Module SqlServer
    
    # Execute the query and store results
    $ChangeLogs = Invoke-Sqlcmd -ServerInstance $ServerName -Database $DatabaseName -Query $Query

    # Output to Console
    Write-Output "Stored Procedure Change History:"
    Write-Output $ChangeLogs | Format-Table -AutoSize

    # Log to File
    $ChangeLogs | Out-File -FilePath $LogFile -Encoding utf8
    Write-Output "Change History saved to: $LogFile"
}
catch {
    Write-Error "Error fetching stored procedure change history: $_"
}
