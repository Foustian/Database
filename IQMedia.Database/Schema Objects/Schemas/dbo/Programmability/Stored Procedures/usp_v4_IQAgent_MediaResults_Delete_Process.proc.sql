CREATE PROCEDURE [dbo].[usp_v4_IQAgent_MediaResults_Delete_Process]
    @ClientGUID UNIQUEIDENTIFIER,
	@RowAffected INT OUTPUT
AS
-- Created on May 2015
-- Called by the usp_v4_IQAgent_MediaResults_Delete stored procedure

BEGIN
   
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
BEGIN TRY  	
  BEGIN TRANSACTION

  -- May 2015. Updating the IQAgent_MediaResults_Archive tables through the IQAgent_MediaResults_Archive view. 
  -- Updating the media child tables through the updated trigger (if (IsActive) column get updated) installed on the IQAgent_MediaResults_Archive_xxxx tables

  	 UPDATE IQAgent_MediaResults_Archive_2013
				SET IsActive = 0
			FROM #TblMediaResults AS TblMR
				INNER JOIN IQAgent_MediaResults_Archive_2013 						
					ON TblMR.ID=IQAgent_MediaResults_Archive_2013.ID

		   SELECT @RowAffected = @@ROWCOUNT
        
		
	
          UPDATE IQAgent_MediaResults_Archive_2014
				SET IsActive = 0
			FROM #TblMediaResults AS TblMR
				INNER JOIN IQAgent_MediaResults_Archive_2014					
					ON TblMR.ID=IQAgent_MediaResults_Archive_2014.ID	

		SELECT @RowAffected = @RowAffected + @@ROWCOUNT
		 
		   UPDATE IQAgent_MediaResults_Archive_2015
				SET IsActive = 0
			FROM #TblMediaResults AS TblMR
				INNER JOIN IQAgent_MediaResults_Archive_2015					
					ON TblMR.ID=IQAgent_MediaResults_Archive_2015.ID	

		SELECT @RowAffected = @RowAffected + @@ROWCOUNT

		 UPDATE IQAgent_MediaResults_Archive_2016
				SET IsActive = 0
			FROM #TblMediaResults AS TblMR
				INNER JOIN IQAgent_MediaResults_Archive_2016					
					ON TblMR.ID=IQAgent_MediaResults_Archive_2016.ID	

		SELECT @RowAffected = @RowAffected + @@ROWCOUNT
	
	  	UPDATE IQAgent_MediaResults
				SET IsActive = 0
			FROM #TblMediaResults AS TblMR
				INNER JOIN IQAgent_MediaResults 						
					ON TblMR.ID=IQAgent_MediaResults.ID	

		SELECT @RowAffected = @RowAffected + @@ROWCOUNT

	-- If any deleted records were created as missing articles, delete the corresponding IQAgent_MissingArticles record
	UPDATE IQAgent_MissingArticles 
			Set IsActive = 0
		FROM #TblMediaResults AS TblMR
			INNER JOIN IQAgent_MediaResults WITH (NOLOCK) 
				ON IQAgent_MediaResults.ID = TblMR.ID
			INNER JOIN IQAgent_NMResults WITH (NOLOCK)
				ON IQAgent_NMResults.ID = IQAgent_MediaResults._MediaID
					AND IQAgent_MediaResults.v5Category = IQAgent_NMResults.v5SubMediatype
			INNER JOIN IQAgent_MissingArticles WITH (NOLOCK)
				ON IQAgent_NMResults.ArticleID = CAST(IQAgent_MissingArticles.ID AS VARCHAR(50))
					AND IQAgent_MissingArticles.Category = 'NM'

	UPDATE IQAgent_MissingArticles 
			Set IsActive = 0
		FROM #TblMediaResults AS TblMR
			INNER JOIN IQAgent_MediaResults_Archive WITH (NOLOCK) 
				ON IQAgent_MediaResults_Archive.ID = TblMR.ID
			INNER JOIN IQAgent_NMResults_Archive WITH (NOLOCK)
				ON IQAgent_NMResults_Archive.ID = IQAgent_MediaResults_Archive._MediaID
					AND IQAgent_MediaResults_Archive.v5Category = IQAgent_NMResults_Archive.v5SubMediatype
			INNER JOIN IQAgent_MissingArticles WITH (NOLOCK)
				ON IQAgent_NMResults_Archive.ArticleID = CAST(IQAgent_MissingArticles.ID AS VARCHAR(50))
					AND IQAgent_MissingArticles.Category = 'NM'

	UPDATE IQAgent_MissingArticles 
			Set IsActive = 0
		FROM #TblMediaResults AS TblMR
			INNER JOIN IQAgent_MediaResults WITH (NOLOCK) 
				ON IQAgent_MediaResults.ID = TblMR.ID
			INNER JOIN IQAgent_SMResults WITH (NOLOCK)
				ON IQAgent_SMResults.ID = IQAgent_MediaResults._MediaID
					AND IQAgent_MediaResults.v5Category = IQAgent_SMResults.v5SubMediatype
			INNER JOIN IQAgent_MissingArticles WITH (NOLOCK)
				ON IQAgent_SMResults.SeqID = CAST(IQAgent_MissingArticles.ID AS VARCHAR(50)) -- Not all SeqIDs are numeric
					AND IQAgent_MissingArticles.Category != 'NM'

	UPDATE IQAgent_MissingArticles 
			Set IsActive = 0
		FROM #TblMediaResults AS TblMR
			INNER JOIN IQAgent_MediaResults_Archive WITH (NOLOCK) 
				ON IQAgent_MediaResults_Archive.ID = TblMR.ID
			INNER JOIN IQAgent_SMResults_Archive WITH (NOLOCK)
				ON IQAgent_SMResults_Archive.ID = IQAgent_MediaResults_Archive._MediaID
					AND IQAgent_MediaResults_Archive.v5Category = IQAgent_SMResults_Archive.v5SubMediatype
			INNER JOIN IQAgent_MissingArticles WITH (NOLOCK)
				ON IQAgent_SMResults_Archive.SeqID = CAST(IQAgent_MissingArticles.ID AS VARCHAR(50)) -- Not all SeqIDs are numeric
					AND IQAgent_MissingArticles.Category != 'NM'
				
	
  COMMIT TRANSACTION
  Return 0
END TRY
		BEGIN CATCH
		    IF(@@TRANCOUNT>0)
			BEGIN		          
				ROLLBACK TRANSACTION;  
			END

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
				@CreatedBy='usp_v4_IQAgent_MediaResults_Delete_Process',
				@ModifiedBy='usp_v4_IQAgent_MediaResults_Delete_Process',
				@CreatedDate=GETDATE(),
				@ModifiedDate=GETDATE(),
				@IsActive=1
	

				EXEC usp_IQMediaGroupExceptions_Insert @ExceptionStackTrace,@ExceptionMessage,@CreatedBy,@CreatedDate,NULL,@IQMediaGroupExceptionKey OUTPUT    
				Return -1
		END CATCH        

END


