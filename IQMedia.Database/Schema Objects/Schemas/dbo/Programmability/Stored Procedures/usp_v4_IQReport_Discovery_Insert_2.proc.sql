CREATE PROCEDURE [dbo].[usp_v4_IQReport_Discovery_Insert]
	@Title varchar(max),
	@Keywords varchar(max),
	@Description varchar(max),
	@CategoryGuid uniqueidentifier,
	@MediaID varchar(max),
	@CustomerGuid uniqueidentifier,
	@ClientGuid uniqueidentifier,
	@ReportImageID		bigint,
	@_FolderID bigint
AS
BEGIN
    
    
    BEGIN TRANSACTION
	BEGIN TRY
			
			if(Not Exists(Select Title From IQReport_Discovery Where Title = @Title AND ClientGuid = @ClientGuid and IsActive = 1))
			Begin
		    
				Declare @DiscoveryReportGuid Uniqueidentifier
				Set @DiscoveryReportGuid = NEWID()
				
				Insert Into IQReport_Discovery
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
					@DiscoveryReportGuid
				)  
				
				
				Declare @CurrentDate DateTime
				Set @CurrentDate = GetDate()
				
				Insert Into IQ_Report(ReportGuid,Title,_ReportTypeID,ReportRule,_ReportImageID,ReportDate,ClientGuid,DateCreated,IsActive,_FolderID)
				Select 
					@DiscoveryReportGuid,
					@Title,
					(Select  ID from iq_reporttype Where [Identity] = 'v4Library'),
					NULL,
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
				@CreatedBy='usp_v4_IQReport_Discovery_Insert',
				@ModifiedBy='usp_v4_IQReport_Discovery_InsertR',
				@CreatedDate=GETDATE(),
				@ModifiedDate=GETDATE(),
				@IsActive=1
				
		
		exec usp_IQMediaGroupExceptions_Insert @ExceptionStackTrace,@ExceptionMessage,@CreatedBy,@ModifiedBy,@CreatedDate,@ModifiedDate,@IsActive,@IQMediaGroupExceptionKey output
		
		Select -1
	END CATCH
	
	
END