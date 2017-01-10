CREATE PROCEDURE [dbo].[usp_v4_IQReport_Discovery_InsertLibrary]
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
			
			
			Declare @DiscoveryReportGuid Uniqueidentifier
			Declare @JobTypeID bigint
			
			Set @DiscoveryReportGuid = NEWID()
			
			Select	@JobTypeID = ID 
			From	IQJob_Type 
			Where	Name = 'DiscoveryReportGenerateArchive'		
				 
			DECLARE @Title varchar(50)
			SET @Title = 'SystemReport' + CONVERT(VARCHAR(35),getdate(),126)
				
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
				@DiscoveryReportGuid,
				@JobTypeID
			)  
				
			DECLARE @ReportDiscoveryID INT
			SELECT @ReportDiscoveryID = SCOPE_IDENTITY()
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
				@ReportDiscoveryID,
				@JobTypeID,
				@CustomerGuid,
				null,
				GETDATE(),
				NULL,
				NULL,
				'QUEUED',
				NULL
			)	
				
				
			Declare @CurrentDate DateTime
			Set @CurrentDate = GetDate()
				
			Insert Into IQ_Report(ReportGuid,Title,_ReportTypeID,ReportRule,ReportDate,ClientGuid,DateCreated,IsActive)
			Select 
				@DiscoveryReportGuid,
				@Title,
				(Select  ID from iq_reporttype Where [Identity] = 'v4LibraryDiscovery'),
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
				@CreatedBy='usp_IQReport_Discovery_InsertLibrary',
				@ModifiedBy='usp_IQReport_Discovery_InsertLibrary',
				@CreatedDate=GETDATE(),
				@ModifiedDate=GETDATE(),
				@IsActive=1
				
		
		exec usp_IQMediaGroupExceptions_Insert @ExceptionStackTrace,@ExceptionMessage,@CreatedBy,@CreatedDate,NULL,@IQMediaGroupExceptionKey output
		
		Select -1
	END CATCH
END