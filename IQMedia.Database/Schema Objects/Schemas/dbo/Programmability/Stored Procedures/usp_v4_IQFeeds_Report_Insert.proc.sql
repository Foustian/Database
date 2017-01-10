-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_v4_IQFeeds_Report_Insert]
	@Title varchar(max),
	@Keywords varchar(max),
	@Description varchar(max),
	@CategoryGuid uniqueidentifier,
	@MediaID varchar(max),
	@CustomerGuid uniqueidentifier,
	@ClientGuid uniqueidentifier,
	@ReportImageID	bigint,
	@_FolderID bigint
	
AS
BEGIN
    
    BEGIN TRANSACTION
	BEGIN TRY
	
	
    if(Not Exists(Select Title From IQReport_Feeds Where Title = @Title AND ClientGuid = @ClientGuid AND IsActive = 1))
    Begin
    
		Declare @FeedsReportGuid Uniqueidentifier
		Declare @JobTypeID bigint
		
		Set @FeedsReportGuid = NEWID()
		
		Select	@JobTypeID = ID 
		From	IQJob_Type 
		Where	Name = 'FeedsReportGenerateCreate'	
		
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
			ReportGUID,
			JobTypeID
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
			@FeedsReportGuid,
			@JobTypeID
		)
				
		DECLARE @ReportFeedsID INT
		SELECT @ReportFeedsID = SCOPE_IDENTITY()
		INSERT INTO IQJob_Master
		(
		   _RequestID,
		   _TypeID,
		   _CustomerGuid,
		   _Title,
		   _RequestedDateTime,
		   _CompletedDateTime,
		   _DownloadPath,
		  [Status],
		  _RootPathID
		)
		VALUES
		(
			@ReportFeedsID,
			@JobTypeID,
			@CustomerGuid,
			@Title,
			GETDATE(),
			NULL,
			NULL,
			'QUEUED',
			NULL
		)
		
		Declare @CurrentDate DateTime
		Set @CurrentDate = GetDate()
		
		Insert Into IQ_Report(ReportGuid,Title,_ReportTypeID,ReportRule,_ReportImageID,ReportDate,ClientGuid,DateCreated,IsActive,_FolderID)
		Select 
			@FeedsReportGuid,
			@Title,
			(Select  ID from iq_reporttype Where [Identity] = 'v4Library'),
			NULL,--'<Report />',
			@ReportImageID,
			@CurrentDate,
			@ClientGuid,
			@CurrentDate,
			1,
			@_FolderID
					
	END    
	
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
				@CreatedBy='usp_v4_IQFeeds_Report_Insert',
				@ModifiedBy='usp_v4_IQFeeds_Report_Insert',
				@CreatedDate=GETDATE(),
				@ModifiedDate=GETDATE(),
				@IsActive=1
				
		
		exec usp_IQMediaGroupExceptions_Insert @ExceptionStackTrace,@ExceptionMessage,@CreatedBy,@CreatedDate,NULL,@IQMediaGroupExceptionKey output
		
		Select -1
	END CATCH
	
	
    
END