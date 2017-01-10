
CREATE PROCEDURE [dbo].[usp_IQCore_Recordfile_UGCInsert]

	
	@StartOffset		int,
	@EndOffset			int,
	@DateCreated		datetime ,
	@LastModified		datetime ,
	@Location			varchar(2048),
	@RecordfileTypeID	int,
	@RecordingID		int,
	@RootPathID			int,
	@Status				varchar(50),
	@SourceGUID			uniqueidentifier,
	@StartDate			datetime,
	@EndDate			datetime,
	@ParentGUID			uniqueidentifier,
	@RecordFileMeta		XML ,
	@RecordFileGuid		uniqueidentifier OUTPUT,
	@Message		    VARCHAR(500)=NULL OUTPUT  
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


	Begin Transaction    
 
 BEGIN try  
	IF(EXISTS(Select * from IQCore_Source where Guid = @SourceGUID))
	BEGIN	
	
		
		
		If(Not Exists(	Select
							 * 
						FROM 
							IQCore_Recording
						 Where
							 _SourceGuid = @SourceGUID
							 AND StartDate = @StartDate))
		BEGIN
				INSERT INTO IQCore_Recording(
											_SourceGuid,
											StartDate,
											EndDate
											)
									VALUES	
											(
											@SourceGUID,
											@StartDate,
											CASE 
												WHEN @EndDate IS null
													THEN DATEADD (HH , 1,@StartDate)
												ELSE
													 @EndDate
											END										
											)
											
		END
					
				
				Set @RecordFileGuid = NEWID()
					Insert into IQCore_Recordfile(
									  Guid,
									  StartOffset,
									  EndOffset,
									  DateCreated,
									  LastModified,
									  Location,
									  _RecordfileTypeID,
									  _RecordingID,
									  _RootPathID,
									  Status,
									  _ParentGuid
									  )
								Values(
									  @RecordFileGuid,				
									  @StartOffset,
									  @EndOffset,
									  @DateCreated,
									  @LastModified,
									  @Location,
									  @RecordfileTypeID,
									  @RecordingID,
									  @RootPathID	,
									  @Status,
									  @ParentGUID
									  )
						
			
						
					UPDATE IQCore_RecordfileMeta
					set Value= xmldata.b.value('@Value', 'Varchar(50)')
					FROM
							@recordfilemeta.nodes('/IngestionData/RawInfo/MetaData/Meta') AS xmldata(b)
							JOIN IQCore_RecordfileMeta
							ON IQCore_RecordfileMeta.Field = xmldata.b.value('@Key', 'varchar(max)') and IQCore_RecordfileMeta._RecordfileGUID = @RecordFileGuid				
							where IQCore_RecordfileMeta.Field= xmldata.b.value('@Key', 'varchar(max)') and
							IQCore_RecordfileMeta._RecordfileGUID=@RecordFileGuid	
						
				
				
					INSERT INTO IQCore_RecordfileMeta
					SELECT 
							@RecordFileGuid, xmldata.b.value('@Key', 'varchar(max)') ,xmldata.b.value('@Value', 'varchar(max)')
					FROM 
							@recordfilemeta.nodes('/IngestionData/RawInfo/MetaData/Meta') AS xmldata(b)	
							LEFT OUTER JOIN IQCore_RecordfileMeta
							ON IQCore_RecordfileMeta.Field = xmldata.b.value('@Key', 'varchar(max)') 
							and IQCore_RecordfileMeta._RecordfileGUID = @RecordFileGuid
							where IQCore_RecordfileMeta._RecordfileGuid is null
							
				
				 SET @Message='Record Inserted Successfully'  
   
   END
	COMMIT Transaction  
	
 END TRY  
   
 
 BEGIN CATCH
  Set  @Message='Error: '+ERROR_MESSAGE()+' Procedure:'+ERROR_PROCEDURE()+' Line:'+ CONVERT(varchar,ERROR_LINE())  
       
  SET @RecordFileGuid=Null  
  
   IF @@TRANCOUNT > 0  
   BEGIN  
    ROLLBACK TRANSACTION
   END
	 
  
 END CATCH		
   
   
END
