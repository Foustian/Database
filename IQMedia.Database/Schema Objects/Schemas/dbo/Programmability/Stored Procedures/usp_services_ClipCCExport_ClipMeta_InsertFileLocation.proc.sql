CREATE PROCEDURE [dbo].[usp_services_ClipCCExport_ClipMeta_InsertFileLocation]
(  
	 @ClipGUID UNIQUEIDENTIFIER,   
	 @FileLocation VARCHAR(2048),  	 
	 @ID   UNIQUEIDENTIFIER,  	 
	 @RootPathID BIGINT,
	 @Status	INT = -1	OUTPUT,
	 @Message	VARCHAR(1024)	OUTPUT
)  
AS  
BEGIN  
  
 SET NOCOUNT ON;  
 SET XACT_ABORT ON;
   
	BEGIN TRANSACTION   
	BEGIN TRY  

		DECLARE @FieldRootPathID	VARCHAR(50) = 'CCRootPathID',
				@FieldFileLocation	VARCHAR(50) = 'CCFileLocation'
   
		IF NOT EXISTS(SELECT VALUE FROM IQCore_ClipMeta WHERE _ClipGuid = @ClipGUID AND (Field = @FieldRootPathID))  
			BEGIN  
				INSERT INTO IQCore_ClipMeta  
				(  
					Field,  
					VALUE,  
					_ClipGuid  
				)  
				VALUES  
				(  
					@FieldRootPathID,  
					@RootPathID,  
					@ClipGUID  
				)  
      
				INSERT INTO IQCore_ClipMeta  
				(  
					Field,  
					VALUE,  
					_ClipGuid  
				)  
				VALUES  
				(  
					@FieldFileLocation,  
					@FileLocation,  
					@ClipGUID  
				)  		     
				
			END
		ELSE
			BEGIN

				UPDATE
						IQCore_ClipMeta
				SET
						Value = @RootPathID
				WHERE
						_ClipGuid = @ClipGUID
					AND	Field = @FieldRootPathID

				UPDATE
						IQCore_ClipMeta
				SET
						Value = @FileLocation
				WHERE
						_ClipGuid = @ClipGUID
					AND	Field = @FieldFileLocation

			END
    
		UPDATE 
				IQService_ClipCCExport  
		SET  
				[Status] = 'EXPORTED',  
				LastModified = GETDATE()  
		WHERE  
				ID=@ID   
    
		SET @Status = 0  
    
	COMMIT TRANSACTION  
    
 END TRY  
 BEGIN CATCH  

  ROLLBACK TRANSACTION  

  SET @Status = -1;  
  
  DECLARE @IQMediaGroupExceptionKey BIGINT,
				@ExceptionStackTrace VARCHAR(500),
				@ExceptionMessage VARCHAR(500),
				@CreatedBy	VARCHAR(50),
				@ModifiedBy	VARCHAR(50),
				@CreatedDate	DATETIME,
				@ModifiedDate	DATETIME,
				@IsActive	BIT
				
		
		SELECT 
				@ExceptionStackTrace=(ERROR_PROCEDURE()+'_'+CONVERT(VARCHAR(450),ERROR_LINE())),
				@ExceptionMessage=CONVERT(VARCHAR(500),ERROR_NUMBER())+'_'+ERROR_MESSAGE(),
				@CreatedBy='usp_services_ClipCCExport_ClipMeta_InsertFileLocation',
				@ModifiedBy='usp_services_ClipCCExport_ClipMeta_InsertFileLocation',
				@CreatedDate=GETDATE(),
				@ModifiedDate=GETDATE(),
				@IsActive=1

	SET @Message = @ExceptionMessage + @ExceptionStackTrace				
		
	EXEC usp_IQMediaGroupExceptions_Insert @ExceptionStackTrace,@ExceptionMessage,@CreatedBy,@CreatedDate,NULL,@IQMediaGroupExceptionKey OUTPUT
    
 END CATCH  
  
END
