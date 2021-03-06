CREATE procedure [dbo].[usp_common_IQAgent_MediaResults_UpdateIsRead]
	@ClientGUID UNIQUEIDENTIFIER,
	@MediaIDXml XML,
	@IsRead BIT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @UpdateType INT
	
	BEGIN TRANSACTION
	BEGIN TRY		
		CREATE TABLE #TblMediaResults 
		(
			[ID] BIGINT NOT NULL		
		)
	
		INSERT INTO #TblMediaResults
		(
			ID		
		)
		SELECT	Media.ID.value('@id', 'bigint')
		FROM	@MediaIDXml.nodes('list/item') as Media(ID)
		INNER	JOIN IQMediaGroup.dbo.IQAgent_MediaResults WITH (NOLOCK)
				ON IQAgent_MediaResults.ID = Media.ID.value('@id', 'bigint')
				AND IQAgent_MediaResults.IsRead != @IsRead
	
		INSERT INTO #TblMediaResults
		(
			ID		
		)
		SELECT	Media.ID.value('@id', 'bigint')
		FROM	@MediaIDXml.nodes('list/item') as Media(ID)
		INNER	JOIN IQMediaGroup.dbo.IQAgent_MediaResults_Archive WITH (NOLOCK)
				ON IQAgent_MediaResults_Archive.ID = Media.ID.value('@id', 'bigint')
				AND IQAgent_MediaResults_Archive.IsRead != @IsRead
						
		IF (SELECT COUNT(1) FROM #TblMediaResults) > 0
		  BEGIN
			Create index idx2_TblMediaResults on #TblMediaResults (ID)

			UPDATE IQMediaGroup.dbo.IQAgent_MediaResults
			SET IsRead = @IsRead
			FROM #TblMediaResults AS TblMr
			INNER JOIN IQMediaGroup.dbo.IQAgent_MediaResults
				ON IQAgent_MediaResults.ID = TblMr.ID
	
			UPDATE IQMediaGroup.dbo.IQAgent_MediaResults_Archive_2013
			SET IsRead = @IsRead
			FROM #TblMediaResults AS TblMr
			INNER JOIN IQMediaGroup.dbo.IQAgent_MediaResults_Archive_2013
				ON IQAgent_MediaResults_Archive_2013.ID = TblMr.ID	
	
			UPDATE IQMediaGroup.dbo.IQAgent_MediaResults_Archive_2014
			SET IsRead = @IsRead
			FROM #TblMediaResults AS TblMr
			INNER JOIN IQMediaGroup.dbo.IQAgent_MediaResults_Archive_2014
				ON IQAgent_MediaResults_Archive_2014.ID = TblMr.ID	
	
			UPDATE IQMediaGroup.dbo.IQAgent_MediaResults_Archive_2015
			SET IsRead = @IsRead
			FROM #TblMediaResults AS TblMr
			INNER JOIN IQMediaGroup.dbo.IQAgent_MediaResults_Archive_2015
				ON IQAgent_MediaResults_Archive_2015.ID = TblMr.ID

			UPDATE IQMediaGroup.dbo.IQAgent_MediaResults_Archive_2016
			SET IsRead = @IsRead
			FROM #TblMediaResults AS TblMr
			INNER JOIN IQMediaGroup.dbo.IQAgent_MediaResults_Archive_2016
				ON IQAgent_MediaResults_Archive_2016.ID = TblMr.ID

			INSERT INTO IQMediaGroup.dbo.IQAgent_MediaResults_UpdatedRecords_IsRead (_MediaResultID, ClientGUID, SolrStatus, LastModified, IsRead, IsActive)
			SELECT	tblMediaResults.ID,
					@ClientGUID,
					0,
					GETDATE(),
					@IsRead,
					1
			FROM	#TblMediaResults as tblMediaResults
			LEFT	JOIN IQMediaGroup.dbo.IQAgent_MediaResults_UpdatedRecords_IsRead updated WITH (NOLOCK)
					ON updated._MediaResultID = tblMediaResults.ID
					AND updated.SolrStatus != 1
					AND updated.IsRead = @IsRead
					AND updated.IsActive = 1
			WHERE	updated.ID IS NULL
		END
		
		-- Deactivate any unprocessed IsRead updates for the specified records where the IsRead flag is different from the current value
		UPDATE	IQMediaGroup.dbo.IQAgent_MediaResults_UpdatedRecords_IsRead WITH (ROWLOCK)
		SET		IsActive = 0		
		WHERE	EXISTS (SELECT NULL FROM #TblMediaResults tblResults WHERE tblResults.ID = IQAgent_MediaResults_UpdatedRecords_IsRead._MediaResultID)
				AND	SolrStatus != 1
				AND IsRead != @IsRead

		drop table #TblMediaResults

		SELECT 1

		COMMIT TRANSACTION	
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION

		SELECT -1
		
		DECLARE @IQMediaGroupExceptionKey BIGINT,
				@ExceptionStackTrace VARCHAR(500),
				@ExceptionMessage VARCHAR(500),
				@CreatedBy	VARCHAR(50),
				@ModifiedBy	VARCHAR(50),
				@CreatedDate	DATETIME,
				@ModifiedDate	DATETIME,
				@IsActive	BIT				
		
		SELECT 
				@ExceptionStackTrace=(ERROR_PROCEDURE()+'_'+CONVERT(VARCHAR(50),ERROR_LINE())),
				@ExceptionMessage=CONVERT(VARCHAR(50),ERROR_NUMBER())+'_'+ERROR_MESSAGE(),
				@CreatedBy='usp_common_IQAgent_MediaResults_UpdateIsRead',
				@ModifiedBy='usp_common_IQAgent_MediaResults_UpdateIsRead',
				@CreatedDate=GETDATE(),
				@ModifiedDate=GETDATE(),
				@IsActive=1
						
		EXEC IQMediaGroup.dbo.usp_IQMediaGroupExceptions_Insert @ExceptionStackTrace,@ExceptionMessage,@CreatedBy,@CreatedDate,NULL,@IQMediaGroupExceptionKey OUTPUT		
	END CATCH

END
