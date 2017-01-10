CREATE PROCEDURE [dbo].[usp_v4_IQReport_Feeds_InsertLibrary]
	@Keywords varchar(max),
	@Description varchar(max),
	@CategoryGuid uniqueidentifier,
	@MediaID varchar(max),
	@CustomerGuid uniqueidentifier,
	@ClientGuid uniqueidentifier
AS
BEGIN
	BEGIN TRANSACTION
	BEGIN TRY
			
			
			Declare @FeedsReportGuid Uniqueidentifier
			Set @FeedsReportGuid = NEWID()
				 
			DECLARE @Title varchar(50)
			SET @Title = 'SystemReport' + CONVERT(VARCHAR(35),getdate(),126)
				
			Insert Into IQReport_Feeds
			(
				Title,
				Keywords,
				[Description],
				CategoryGuid,
				MediaID,
				CustomerGuid,
				ClientGuid,
				[Status],
				ReportGUID
			)
			VALUES
			(
				@Title,
				@Keywords,
				@Description,
				@CategoryGuid,
				cast(@MediaID as xml),
				@CustomerGuid,
				@ClientGuid,
				'QUEUED',
				@FeedsReportGuid
			)
				
				
			Declare @CurrentDate DateTime
			Set @CurrentDate = GetDate()
				
			Insert Into IQ_Report(ReportGuid,Title,_ReportTypeID,ReportRule,ReportDate,ClientGuid,DateCreated,IsActive)
			Select 
				@FeedsReportGuid,
				@Title,
				(Select  ID from iq_reporttype Where [Identity] = 'v4LibraryFeeds'),
				NULL,
				@CurrentDate,
				@ClientGuid,
				@CurrentDate,
				1
					
					 
			
			
			Select @@RowCount
    
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
				@CreatedBy='usp_IQReport_Feeds_InsertLibrary',
				@ModifiedBy='usp_IQReport_Feeds_InsertLibrary',
				@CreatedDate=GETDATE(),
				@ModifiedDate=GETDATE(),
				@IsActive=1
				
		
		exec usp_IQMediaGroupExceptions_Insert @ExceptionStackTrace,@ExceptionMessage,@CreatedBy,@CreatedDate,NULL,@IQMediaGroupExceptionKey output
		
		Select -1
	END CATCH
END