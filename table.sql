USE YOUR_DATABASE;
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ProcContentHistory')
BEGIN
    CREATE TABLE ProcContentHistory (
        ChangeID INT IDENTITY(1,1) PRIMARY KEY,
        EventType NVARCHAR(50),  -- CREATE, ALTER, DROP
        ProcedureName NVARCHAR(255),
        ModifiedBy NVARCHAR(255),
        ModifiedDate DATETIME DEFAULT GETDATE(),
        PreviousContent NVARCHAR(MAX),  -- Stores previous version
        NewContent NVARCHAR(MAX)        -- Stores new version
    );
END
