# Prompt user for SQL Server and Database Name
$ServerName = Read-Host "Enter your SQL Server name (e.g., localhost\SQLEXPRESS)"
$DatabaseName = Read-Host "Enter your Database name"

# Define the Log File Path
$LogFile = "C:\ProcedureChangeLog.txt"  # Change this path if needed

# SQL Query to Retrieve Stored Procedure Change Logs
$Query = @"
SELECT 
    name AS ProcedureName, 
    modify_date AS LastModifiedDate
FROM sys.procedures
ORDER BY modify_date DESC;
"@

# Execute SQL Query using Invoke-Sqlcmd
try {
    # Import SQL Server Module if not available
    if (-not (Get-Module -ListAvailable -Name SqlServer)) {
        Install-Module -Name SqlServer -Force -AllowClobber
    }
    
    Import-Module SqlServer
    
    # Execute the query and store results
    $ChangeLogs = Invoke-Sqlcmd -ServerInstance $ServerName -Database $DatabaseName -Query $Query

    # Output to Console
    Write-Output "Stored Procedure Change Logs:"
    Write-Output $ChangeLogs

    # Log to File
    $ChangeLogs | Out-File -FilePath $LogFile -Encoding utf8
    Write-Output "Change Log saved to: $LogFile"
}
catch {
    Write-Error "Error fetching stored procedure logs: $_"
}
