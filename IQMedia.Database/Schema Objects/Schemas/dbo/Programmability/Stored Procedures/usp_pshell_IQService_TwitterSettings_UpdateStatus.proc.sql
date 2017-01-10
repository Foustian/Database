CREATE PROCEDURE [dbo].[usp_pshell_IQService_TwitterSettings_UpdateStatus]
(
	@IDXml	XML,
	@Status	VARCHAR(50)	
)
AS
BEGIN
	
	SET NOCOUNT ON;
	SET XACT_ABORT ON;
	
	BEGIN TRANSACTION
	
	DECLARE @ModifiedDate DATETIME = GETDATE()
	
	UPDATE	
		IQMediaGroup.dbo.IQService_TwitterSettings
	SET 
		[Status] = @Status,
		ModifiedDate = @ModifiedDate			
	FROM
		IQService_TwitterSettings
			INNER JOIN @IDXml.nodes('list/item') as T(ID)
				ON T.ID.value('@id','bigint') = IQService_TwitterSettings.ID
				
			
	
	IF (@Status = 'IN_PROCESS' OR @Status = 'COMPLETED' OR @Status = 'FAILED')
	  BEGIN	
		DECLARE @TypeID	BIGINT
		DECLARE @ID BIGINT
		
		SELECT
			@TypeID = ID
		FROM
			IQMediaGroup.dbo.IQJob_Type
		WHERE
			Name = 'TwitterSettingsUpdate'

		DECLARE t_cursor CURSOR FOR
			SELECT
				T.ID.value('@id','bigint')
			FROM
				@IDXml.nodes('list/item') as T(ID)

		OPEN t_cursor

		FETCH NEXT FROM t_cursor INTO @ID
			WHILE @@FETCH_STATUS = 0
			  BEGIN
				EXEC IQMediaGroup.dbo.usp_Service_JobMaster_UpdateStatus @ID, @Status, @ModifiedDate, @TypeID

				FETCH NEXT FROM t_cursor INTO @ID
			  END

		CLOSE t_cursor
		DEALLOCATE t_cursor		
	  END
		
	COMMIT TRANSACTION
END
