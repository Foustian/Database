CREATE PROCEDURE [dbo].[usp_v4_IQ_Report_RevertItemPositions]
	@ReportID BIGINT,
	@ReturnVal TINYINT OUTPUT	
AS
BEGIN
	BEGIN TRANSACTION
	BEGIN TRY
		DECLARE @ReportGUID UNIQUEIDENTIFIER
		SELECT @ReportGUID = ReportGUID FROM IQMediaGroup.dbo.IQ_Report WHERE ID = @ReportID

		UPDATE IQMediaGroup.dbo.IQ_Report_ItemPositions
		SET IsActive = 0,
			ModifiedDate = GETDATE()
		WHERE _ReportGUID = @ReportGUID

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
				@CreatedBy='usp_v4_IQ_Report_RevertItemPositions',
				@ModifiedBy='usp_v4_IQ_Report_RevertItemPositions',
				@CreatedDate=GETDATE(),
				@ModifiedDate=GETDATE(),
				@IsActive=1				
		
		exec IQMediaGroup.dbo.usp_IQMediaGroupExceptions_Insert @ExceptionStackTrace,@ExceptionMessage,@CreatedBy,@CreatedDate,NULL,@IQMediaGroupExceptionKey output
		
		SET @ReturnVal = 0
	END CATCH
END