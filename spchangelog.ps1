# Prompt user for SQL Server and Database Name
$ServerName = Read-Host "Enter your SQL Server name (e.g., localhost\SQLEXPRESS)"
$DatabaseName = Read-Host "Enter your Database name"

# Define Log File Path
$LogFile = "C:\ProcedureChangeHistory.txt"  # Change this path if needed

# SQL Query to Retrieve Full Stored Procedure Modification History
$Query = @"
SELECT 
    p.name AS ProcedureName, 
    p.create_date AS CreatedDate,
    p.modify_date AS LastModifiedDate,
    dp.name AS ModifiedBy
FROM sys.procedures p
LEFT JOIN sys.database_principals dp ON p.principal_id = dp.principal_id
ORDER BY p.modify_date DESC;
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
    Write-Output "Stored Procedure Change History:"
    Write-Output $ChangeLogs

    # Log to File
    $ChangeLogs | Out-File -FilePath $LogFile -Encoding utf8
    Write-Output "Change History saved to: $LogFile"
}
catch {
    Write-Error "Error fetching stored procedure change history: $_"
}
