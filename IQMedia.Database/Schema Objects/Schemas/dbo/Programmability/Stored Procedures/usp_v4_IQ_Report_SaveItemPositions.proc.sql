CREATE PROCEDURE [dbo].[usp_v4_IQ_Report_SaveItemPositions]
	@ReportID BIGINT,
	@ReportItemXml XML,
	@ReturnVal TINYINT OUTPUT	
AS
BEGIN
	BEGIN TRANSACTION
	BEGIN TRY
		DECLARE @ReportGUID UNIQUEIDENTIFIER
		SELECT @ReportGUID = ReportGUID FROM IQMediaGroup.dbo.IQ_Report WHERE ID = @ReportID

		DELETE FROM IQMediaGroup.dbo.IQ_Report_ItemPositions
		WHERE _ReportGUID = @ReportGUID

		INSERT INTO IQMediaGroup.dbo.IQ_Report_ItemPositions (_ReportGUID, GroupTier1Value, GroupTier2Value, _ArchiveMediaID, Position, CreatedDate, ModifiedDate, IsActive)
		SELECT	@ReportGUID,
				Report.Item.value('@grouptier1value', 'varchar(max)'),
				Report.Item.value('@grouptier2value', 'varchar(max)'),
				Report.Item.value('@mediaid', 'bigint'),				
				Report.Item.value('@position', 'int'),
				GETDATE(),
				GETDATE(),
				1
		FROM	@ReportItemXml.nodes('ReportItems/ReportItem') AS Report(Item)

		SET @ReturnVal = 1
	COMMIT TRANSACTION
	END TRY
	BEGIN CATCH	
		ROLLBACK TRANSACTION
		
		declare @IQMediaGroupExceptionKey bigint,
				@ExceptionStackTrace varchar(500),
				@ExceptionMessage varchar(500),
				@CreatedBy	varchar(50),
				@ModifiedBy	varchar(50),
				@CreatedDate	datetime,
				@ModifiedDate	datetime,
				@IsActive	bit				
		
		Select 
				@ExceptionStackTrace=(ERROR_PROCEDURE()+'_'+CONVERT(varchar(50),ERROR_LINE())),
				@ExceptionMessage=convert(varchar(50),ERROR_NUMBER())+'_'+ERROR_MESSAGE(),
				@CreatedBy='usp_v4_IQ_Report_SaveItemPositions',
				@ModifiedBy='usp_v4_IQ_Report_SaveItemPositions',
				@CreatedDate=GETDATE(),
				@ModifiedDate=GETDATE(),
				@IsActive=1				
		
		exec IQMediaGroup.dbo.usp_IQMediaGroupExceptions_Insert @ExceptionStackTrace,@ExceptionMessage,@CreatedBy,@CreatedDate,NULL,@IQMediaGroupExceptionKey output
		
		SET @ReturnVal = 0
	END CATCH
END