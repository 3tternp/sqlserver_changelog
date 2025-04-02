# Prompt user for SQL Server and Database Name
$ServerName = Read-Host "Enter your SQL Server name (e.g., localhost\SQLEXPRESS)"
$DatabaseName = Read-Host "Enter your Database name"

# Define Log File Path
$LogFile = "C:\ProcedureContentHistory.txt"

# SQL Query to Retrieve Full Stored Procedure Change History
$Query = @"
SELECT ChangeID, EventType, ProcedureName, ModifiedBy, ModifiedDate, 
       PreviousContent, NewContent 
FROM ProcContentHistory
ORDER BY ModifiedDate DESC;
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
    Write-Output "Full Stored Procedure Content Change History:"
    Write-Output $ChangeLogs

    # Log to File
    $ChangeLogs | Out-File -FilePath $LogFile -Encoding utf8
    Write-Output "Stored Procedure Content Changes saved to: $LogFile"
}
catch {
    Write-Error "Error fetching stored procedure content changes: $_"
}
