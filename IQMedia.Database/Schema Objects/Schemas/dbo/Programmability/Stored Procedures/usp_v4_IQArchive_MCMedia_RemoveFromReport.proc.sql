CREATE PROCEDURE [dbo].[usp_v4_IQArchive_MCMedia_RemoveFromReport]
	@ReportGUID UNIQUEIDENTIFIER,
	@MediaIDXml XML
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRANSACTION
	BEGIN TRY

		DECLARE @CurrentReportRule XML
		DECLARE @UpdatedReportRule XML

		SELECT	@CurrentReportRule = ReportRule
		FROM	IQ_Report WITH (NOLOCK)
		WHERE	ReportGUID = @ReportGUID

		-- Remove deleted IDs from existing IDs
		SELECT	@UpdatedReportRule = 
					(SELECT Curr.ID.query('.')
					 FROM	@CurrentReportRule.nodes('/MediaResults/ID') as Curr(ID)
					 LEFT	JOIN @MediaIDXml.nodes('/MediaResults/ID') as Deleted(ID)
						ON Curr.ID.value('.', 'bigint') = Deleted.ID.value('.', 'bigint')
					 WHERE	Deleted.ID.query('.') IS NULL
					 FOR XML PATH(''), ROOT('MediaResults'))

		UPDATE IQ_Report
		SET	ReportRule = @UpdatedReportRule,
			ReportDate = GETDATE()
		WHERE ReportGuid = @ReportGUID

		COMMIT TRANSACTION	
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		
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
				@CreatedBy='usp_v4_IQArchive_MCMedia_RemoveFromReport',
				@ModifiedBy='usp_v4_IQArchive_MCMedia_RemoveFromReport',
				@CreatedDate=GETDATE(),
				@ModifiedDate=GETDATE(),
				@IsActive=1
						
		EXEC usp_IQMediaGroupExceptions_Insert @ExceptionStackTrace,@ExceptionMessage,@CreatedBy,@CreatedDate,NULL,@IQMediaGroupExceptionKey OUTPUT		
	END CATCH

END