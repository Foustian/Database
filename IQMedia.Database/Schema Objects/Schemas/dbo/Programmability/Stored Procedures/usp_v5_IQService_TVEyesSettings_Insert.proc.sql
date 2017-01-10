CREATE PROCEDURE [dbo].[usp_v5_IQService_TVEyesSettings_Insert]
	@ClientGuid uniqueidentifier,
	@CustomerGuid uniqueidentifier,
	@SearchRequestID bigint,
	@CreateJobRecord bit
AS
BEGIN
	BEGIN TRANSACTION
	BEGIN TRY
	
			Declare @JobTypeID bigint
			Declare @AgentName varchar(max)
			
			Select	@JobTypeID = ID 
			From	IQJob_Type 
			Where	Name = 'TVEyesSettingsUpdate'		
			
			Select	@AgentName = Query_Name
			From	IQAgent_SearchRequest WITH (NOLOCK)
			Where	ID = @SearchRequestID	
				
			Insert Into IQService_TVEyesSettings
			(
				ClientGUID,
				CustomerGUID,
				_SearchRequestID,
				Status,
				CreatedDate,
				ModifiedDate,
				IsActive
			)
			VALUES
			(
				@ClientGuid,
				@CustomerGuid,
				@SearchRequestID,
				'QUEUED',
				GETDATE(),
				GETDATE(),
				1
			)
			
			IF (@CreateJobRecord = 1)
			  BEGIN
				DECLARE @RequestID INT
				SELECT @RequestID = SCOPE_IDENTITY()
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
					@RequestID,
					@JobTypeID,
					@CustomerGuid,
					'Agent ' + @AgentName,
					GETDATE(),
					NULL,
					NULL,
					'QUEUED',
					NULL
				)	
			  END						
			
			Select 1
    
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
				@CreatedBy='usp_v5_IQService_TVEyesSettings_Insert',
				@ModifiedBy='usp_v5_IQService_TVEyesSettings_Insert',
				@CreatedDate=GETDATE(),
				@ModifiedDate=GETDATE(),
				@IsActive=1				
		
		exec usp_IQMediaGroupExceptions_Insert @ExceptionStackTrace,@ExceptionMessage,@CreatedBy,@CreatedDate,NULL,@IQMediaGroupExceptionKey output
		
		Select -1
	END CATCH
END