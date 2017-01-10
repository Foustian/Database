-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_UGCAutoClip_Insert]
	
	@ClipGUID			uniqueidentifier output,
	@StartOffset		int,
	@EndOffset			int,	
	@LastModified		datetime,
	@RecordFileGuid		uniqueidentifier,
	@ClipData			XML,
	@FileLocation		varchar(2048),
	@FileName			varchar(2048),
	@IOSLocation		varchar(2048),
	@IOSRootPathID		varchar(2048),	
	@Message			VARCHAR(500)  output
	
AS
BEGIN
	
	SET NOCOUNT ON;

    Begin Transaction    
 
 BEGIN try  
		Declare @UserGuid uniqueidentifier
		
			Select @UserGuid =	
						xmldata.b.query('User').value('.', 'varchar(max)')		
							FROM
						@ClipData.nodes('/IngestionData/ClipInfo') AS xmldata(b)
		
		
						SET @ClipGUID = NEWID()
						INSERT INTO IQCore_Clip(
										Guid,
										StartOffset,
										EndOffset,
										DateCreated,
										_RecordfileGuid,
										_UserGuid   
										)
								VALUES (
										@ClipGUID,
										@StartOffset,
										@EndOffset,
										GETDATE(),
										@RecordFileGuid,
										@UserGuid					
									   )
						  
		
								INSERT INTO IQCore_ClipInfo(
															_ClipGuid,
															Title,
															[Description],
															Category,
															Keywords	
															)												
															
															SELECT	
																@ClipGUID,
																xmldata.b.query('Title').value('.','varchar(max)') AS 'Title',
																xmldata.b.query('Description').value('.', 'Varchar(50)') AS 'Description',
																xmldata.b.query('Category').value('.','Varchar(50)') AS 'Category',
																xmldata.b.query('Keywords').value('.','Varchar(50)') AS 'Keywords'
															FROM
																@ClipData.nodes('/IngestionData/ClipInfo') AS xmldata(b)
															
													
												
			
				
					DECLARE @Location xml;
					SET @Location = N'<Meta Key="FileLocation" Value="'+@FileLocation+'" />
									  <Meta Key="FileName" Value="'+@FileName+'" />
									  <Meta Key="IOSLocation" Value="'+@IOSLocation+'" />
									  <Meta Key="IOSRootPathID" Value="'+@IOSRootPathID+'" />
									  <Meta Key="NoOfTimesDownloaded" Value="0" />';
									  
					SET @ClipData.modify('insert sql:variable("@Location") into (/IngestionData/ClipInfo/MetaData)[1]') 
				
				
					INSERT INTO IQCore_ClipMeta
					(
						_ClipGuid,
						Field,
						Value
					)
					SELECT 
							@ClipGUID, 
							xmldata.b.value('@Key', 'varchar(max)'),
							xmldata.b.value('@Value', 'varchar(max)')
					FROM 
							@ClipData.nodes('/IngestionData/ClipInfo/MetaData/Meta') AS xmldata(b)
										
   
					SET @Message='Record inserted successfully.' 
	COMMIT Transaction  
	
 END TRY  
   
 
 BEGIN CATCH
 SET @ClipGUID=Null  
  Set @Message='Error: '+ERROR_MESSAGE()+' Procedure:'+ERROR_PROCEDURE()+' Line:'+ CONVERT(varchar,ERROR_LINE())  
   IF @@TRANCOUNT > 0  
   BEGIN  
    ROLLBACK TRANSACTION
   END
	 
  
 END CATCH		
 
    
END
