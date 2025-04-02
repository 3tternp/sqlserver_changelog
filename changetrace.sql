USE YOUR_DATABASE;
GO

IF OBJECT_ID('tr_ProcContentTracker', 'TR') IS NOT NULL
    DROP TRIGGER tr_ProcContentTracker;
GO

CREATE TRIGGER tr_ProcContentTracker
ON DATABASE
FOR CREATE_PROCEDURE, ALTER_PROCEDURE, DROP_PROCEDURE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @EventType NVARCHAR(50),
            @ProcedureName NVARCHAR(255),
            @ModifiedBy NVARCHAR(255),
            @PreviousContent NVARCHAR(MAX),
            @NewContent NVARCHAR(MAX);

    -- Capture event type and procedure name
    SET @EventType = EVENTDATA().value('(/EVENT_INSTANCE/EventType)[1]', 'NVARCHAR(50)');
    SET @ProcedureName = EVENTDATA().value('(/EVENT_INSTANCE/ObjectName)[1]', 'NVARCHAR(255)');
    SET @ModifiedBy = EVENTDATA().value('(/EVENT_INSTANCE/LoginName)[1]', 'NVARCHAR(255)');

    -- Get the previous content if the procedure exists
    SELECT @PreviousContent = OBJECT_DEFINITION(OBJECT_ID(@ProcedureName));

    -- Wait a little to make sure ALTER completes before fetching new content
    WAITFOR DELAY '00:00:01';

    -- Get the new content after modification
    SELECT @NewContent = OBJECT_DEFINITION(OBJECT_ID(@ProcedureName));

    -- Insert into tracking table
    INSERT INTO ProcContentHistory (EventType, ProcedureName, ModifiedBy, ModifiedDate, PreviousContent, NewContent)
    VALUES (@EventType, @ProcedureName, @ModifiedBy, GETDATE(), @PreviousContent, @NewContent);
END;
GO
