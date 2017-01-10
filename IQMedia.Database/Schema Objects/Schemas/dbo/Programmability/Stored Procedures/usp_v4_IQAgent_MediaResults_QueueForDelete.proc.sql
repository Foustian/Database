CREATE PROCEDURE [dbo].[usp_v4_IQAgent_MediaResults_QueueForDelete]
	@ClientGUID uniqueidentifier,
	@CustomerGUID uniqueidentifier,
	@MediaIDXml xml,
	@Result int output
AS
BEGIN
	BEGIN TRANSACTION
	BEGIN TRY

		INSERT INTO IQAgent_DeleteControl (clientGUID, customerGUID, statusUpdateData, createdDate, modifiedDate)
		VALUES (@ClientGUID, @CustomerGUID, @MediaIDXml, GETDATE(), GETDATE())
					
		DECLARE @StatusControlID INT
		SELECT @StatusControlID = SCOPE_IDENTITY()
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
			@StatusControlID,
			(SELECT ID FROM IQJob_Type WHERE Name = 'FeedsDelete'),
			@CustomerGuid,
			NULL,
			GETDATE(),
			NULL,
			NULL,
			'QUEUED',
			NULL
		)
		
		SET @Result = 1
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
				@CreatedBy='usp_v4_IQAgent_MediaResults_QueueForDelete',
				@ModifiedBy='usp_v4_IQAgent_MediaResults_QueueForDelete',
				@CreatedDate=GETDATE(),
				@ModifiedDate=GETDATE(),
				@IsActive=1
				
		
		exec usp_IQMediaGroupExceptions_Insert @ExceptionStackTrace,@ExceptionMessage,@CreatedBy,@CreatedDate,NULL,@IQMediaGroupExceptionKey output
		
		SET @Result = -1
	END CATCH
END
