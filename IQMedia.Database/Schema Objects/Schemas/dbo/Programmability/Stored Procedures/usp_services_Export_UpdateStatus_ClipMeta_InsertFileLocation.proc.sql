CREATE PROCEDURE [dbo].[usp_services_Export_UpdateStatus_ClipMeta_InsertFileLocation]  
(  
 @ClipGuid UNIQUEIDENTIFIER,   
 @Location VARCHAR(2048),  
 @FileName VARCHAR(255),  
 @ID   UNIQUEIDENTIFIER,  
 @IOSLocation VARCHAR(2048),  
 @IOSRootPathID BIGINT  
)  
AS  
BEGIN  
  
 SET NOCOUNT ON;  
  
 DECLARE @ISCommited BIT=0   
   
 BEGIN TRANSACTION   
 BEGIN TRY  
   
  IF NOT EXISTS(SELECT VALUE FROM IQCore_ClipMeta WHERE _ClipGuid = @ClipGuid AND (Field = 'filename' OR Field = 'filelocation'))  
  BEGIN  
   INSERT INTO IQCore_ClipMeta  
   (  
    Field,  
    VALUE,  
    _ClipGuid  
   )  
   VALUES  
   (  
    'FileName',  
    @Filename,  
    @ClipGuid  
   )  
      
   INSERT INTO IQCore_ClipMeta  
   (  
    Field,  
    VALUE,  
    _ClipGuid  
   )  
   VALUES  
   (  
    'FileLocation',  
    @Location,  
    @ClipGuid  
   )  

	IF(@IOSLocation IS NOT NULL)
	BEGIN
     
	   INSERT INTO IQCore_ClipMeta  
	   (  
		Field,  
		VALUE,  
		_ClipGuid  
	   )  
	   VALUES  
	   (  
		'IOSLocation',  
		@IOSLocation,  
		@ClipGuid  
	   )  
	     
	   INSERT INTO IQCore_ClipMeta  
	   (  
		Field,  
		VALUE,  
		_ClipGuid  
	   )  
	   VALUES  
	   (  
		'IOSRootPathID',  
		@IOSRootPathID,  
		@ClipGuid  
	   )  
	END
     
   IF NOT EXISTS(SELECT VALUE FROM IQCore_ClipMeta WHERE _ClipGuid = @ClipGuid AND Field = 'nooftimesdownloaded')  
   BEGIN  
    INSERT INTO IQCore_ClipMeta  
    (  
     Field,  
     VALUE,  
     _ClipGuid  
    )  
    VALUES  
    (  
     'NoOfTimesDownloaded',  
     '0',  
     @ClipGuid  
    )  
   END  
  END   
    
  UPDATE IQService_Export  
  SET  
    [Status]='EXPORTED',  
    LastModified=GETDATE()  
  WHERE  
    ID=@ID   
    
  SET @ISCommited=1  
    
  COMMIT TRANSACTION  
    
 END TRY  
 BEGIN CATCH  
   
  SET @ISCommited =0;  
   
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
				@ExceptionMessage=CONVERT(VARCHAR(500),ERROR_NUMBER())+'_'+ERROR_MESSAGE(),
				@CreatedBy='usp_services_Export_UpdateStatus_ClipMeta_InsertFileLocation',
				@ModifiedBy='usp_services_Export_UpdateStatus_ClipMeta_InsertFileLocation',
				@CreatedDate=GETDATE(),
				@ModifiedDate=GETDATE(),
				@IsActive=1
				
		
	EXEC usp_IQMediaGroupExceptions_Insert @ExceptionStackTrace,@ExceptionMessage,@CreatedBy,@CreatedDate,NULL,@IQMediaGroupExceptionKey OUTPUT
    
 END CATCH  
  
 SELECT @ISCommited AS IsCommited  
  
END