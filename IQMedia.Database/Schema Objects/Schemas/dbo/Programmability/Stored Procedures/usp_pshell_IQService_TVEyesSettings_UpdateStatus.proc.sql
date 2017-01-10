CREATE PROCEDURE [dbo].[usp_pshell_IQService_TVEyesSettings_UpdateStatus]
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
		IQMediaGroup.dbo.IQService_TVEyesSettings
	SET 
		[Status] = @Status,
		ModifiedDate = @ModifiedDate			
	FROM
		IQService_TVEyesSettings
			INNER JOIN @IDXml.nodes('list/item') as T(ID)
				ON T.ID.value('@id','bigint') = IQService_TVEyesSettings.ID
				
			
	
	IF (@Status = 'IN_PROCESS' OR @Status = 'COMPLETED' OR @Status = 'FAILED')
	  BEGIN	
		DECLARE @TypeID	BIGINT,
				@ID BIGINT,
				@SearchRequestID BIGINT,
				@TVESearchGUID UNIQUEIDENTIFIER	
		
		SELECT
			@TypeID = ID
		FROM
			IQMediaGroup.dbo.IQJob_Type
		WHERE
			Name = 'TVEyesSettingsUpdate'

		DECLARE t_cursor CURSOR FOR
			SELECT
				T.ID.value('@id','bigint'),
				IQService_TVEyesSettings._SearchRequestID,
				T.ID.value('@guid','uniqueidentifier')
			FROM
				@IDXml.nodes('list/item') as T(ID)
			INNER JOIN IQMediaGroup.dbo.IQService_TVEyesSettings WITH (NOLOCK)
				ON IQService_TVEyesSettings.ID = T.ID.value('@id','bigint') 

		OPEN t_cursor

		FETCH NEXT FROM t_cursor INTO @ID, @SearchRequestID, @TVESearchGUID
			WHILE @@FETCH_STATUS = 0
			  BEGIN
				EXEC IQMediaGroup.dbo.usp_Service_JobMaster_UpdateStatus @ID, @Status, @ModifiedDate, @TypeID

				-- If the job completed successfully, update any new rules with the GUID created by TVEyes
				IF @Status = 'COMPLETED'
				  BEGIN
					IF NOT EXISTS(SELECT 1 FROM IQMediaGroup.dbo.IQ_TVEyes_Settings WHERE SRID = @SearchRequestID AND IsActive = 1 AND TVESearchGUID IS NOT NULL)
					  BEGIN
						UPDATE IQMediaGroup.dbo.IQ_TVEyes_Settings
						SET TVESearchGUID = @TVESearchGUID
						WHERE SRID = @SearchRequestID
							  AND IsActive = 1
						
						-- Can't replace text of empty node, so insert whitespace
						UPDATE IQMediaGroup.dbo.IQAgent_SearchRequest
						SET SearchTerm.modify('insert text{" "} into (/SearchRequest/TM/TVEyesSearchGUID[not(text())])[1]')
						WHERE ID = @SearchRequestID

						-- Update node value
						UPDATE IQMediaGroup.dbo.IQAgent_SearchRequest
						SET SearchTerm.modify('replace value of (/SearchRequest/TM/TVEyesSearchGUID/text())[1] with sql:variable("@TVESearchGUID")')
						WHERE ID = @SearchRequestID
					  END
				  END

				FETCH NEXT FROM t_cursor INTO @ID, @SearchRequestID, @TVESearchGUID
			  END

		CLOSE t_cursor
		DEALLOCATE t_cursor		
	  END
		
	COMMIT TRANSACTION
END