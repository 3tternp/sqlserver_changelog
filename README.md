# sqlserver_changelog

Before running the script, do not forget to run the following command 

_Set-ExecutionPolicy Unrestricted -Scope Process_

Now run the script in PowerShell terminal as follows 

./spchangelog.ps1

**This need to be tested**

# For full change log with content modification, follow the following script 

🚀 Step 1: Create a Table to Store Procedure Changes

Run this SQL script in your database to store the entire content history:

## copy the content of the table.sql and execute it as a sql query 

🚀 Step 2: Create a Trigger to Track Content Changes

This trigger will store the procedure definition before and after modification.

## copy the content of changetrace.sql and execute it as a sql query 

after that now run the powershell script as 

./contentchange.sql
