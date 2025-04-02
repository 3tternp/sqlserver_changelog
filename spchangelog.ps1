# Prompt user for SQL Server and Database Name
$ServerName = Read-Host "Enter your SQL Server name (e.g., localhost\SQLEXPRESS)"
$DatabaseName = Read-Host "Enter your Database name"

# Define Log File Path
$LogFile = "C:\ProcedureChangeHistory.txt"

# SQL Query to Retrieve Stored Procedure Modification History
$Query = @"
WITH ProcChanges AS (
    SELECT 
        p.name AS ProcedureName,
        p.create_date AS CreatedDate,
        p.modify_date AS LastModifiedDate,
        dp.name AS ModifiedBy
    FROM sys.procedures p
    LEFT JOIN sys.database_principals dp ON p.principal_id = dp.principal_id
),
DefaultTrace AS (
    SELECT 
        te.name AS EventName,
        t.DatabaseName,
        t.ObjectName AS ProcedureName,
        t.StartTime AS EventTime,
        t.LoginName AS ModifiedBy
    FROM sys.fn_trace_gettable((SELECT path FROM sys.traces WHERE is_default = 1), DEFAULT) t
    JOIN sys.trace_events te ON t.EventClass = te.trace_event_id
    WHERE te.name IN ('Object:Altered', 'Object:Created') 
    AND t.ObjectType = 8272 -- 8272 = Stored Procedure
)
SELECT * FROM ProcChanges
UNION ALL
SELECT '---' AS ProcedureName, DatabaseName, EventTime AS LastModifiedDate, ModifiedBy 
FROM DefaultTrace
ORDER BY LastModifiedDate DESC;
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
