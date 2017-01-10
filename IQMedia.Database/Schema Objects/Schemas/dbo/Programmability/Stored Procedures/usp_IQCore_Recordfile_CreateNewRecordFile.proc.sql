-- =============================================
-- Description:	This will create new record into Record Files
-- Parameters Description
-- 1.	RecordFileGuid = Return newly created RecordFileGuid
-- 2. 	Destination File = File Name with Location i.e \YYYY\MM\DD\HH\SOURCEID_YYYYMMDD_HH.ext
-- 3. 	FileExtension = File extension need to added into Record File (.mp3,.mp4,.flv,.xml etc....)
-- 4. 	StartDate = Represents StartDate field in IQCore_Recording table & format is YYYY-MM-DD_HH
-- 5. 	EndDate = Represents EndDate field in IQCore_Recording table & it is StartDate + 1 Hour(If not UGC file). Format is YYYY-MM-DD_HH
-- 6. 	EndOffset = Record File End Offset
-- 7. 	RecordFileTypeID = Represents field value from IQCore_RecordFileType
-- 8. 	RootPathID = Represents field value from IQCore_RootPath
-- 9. 	Status = Record File Status(READY,DELETED etc....)
-- 10.	IsUGC = Specify whether we are adding UGC file or not. Specify 1 if UGC file else 0
-- 11.  UGCMetaData = Xml contains meta data of ugc
-- 12.  Message = Contains success message or error message
-- =============================================


CREATE PROCEDURE [dbo].[usp_IQCore_Recordfile_CreateNewRecordFile]
	@RecordFileGuid			UNIQUEIDENTIFIER	OUTPUT,
	@DestinationFile		VARCHAR(200) OUTPUT,
	@FileExtension			VARCHAR(10),
	@StartDate				DATETIME,
	@EndDate				DATETIME,
	@EndOffset				INT,
	@SourceGuid				UNIQUEIDENTIFIER,
	@RecordFileTypeID		INT,
	@RootPathID				INT,
	@Status					VARCHAR(25),
	@IsUGC					BIT,
	@UGCMetaData			XML=NULL,
	@Message				VARCHAR(500)=NULL OUTPUT
AS
BEGIN

	BEGIN TRY
	
			BEGIN TRAN
			
			-- SET NOCOUNT ON added to prevent extra result sets from
			-- interfering with SELECT statements.
			--SET NOCOUNT ON;

			--Check If Recording for given SourceID & StartDate is already Exists
	
			DECLARE @RecordingID AS INT
	
			SELECT @RecordingID = ID FROM IQCore_Recording 
			WHERE _SourceGuid = @SourceGuid 
			AND StartDate = @StartDate
			Declare @temp varchar(100)
			
	
			IF @RecordingID IS NULL OR @RecordingID = 0
				BEGIN
				
					INSERT INTO IQCore_Recording
					(
						_SourceGuid,
						StartDate,
						EndDate
					)
					VALUES
					(
						@SourceGuid,
						@StartDate,
						@EndDate
					)	
					
					SET @RecordingID = SCOPE_IDENTITY()
					
				END
		
			
		
			-- Check if Record files under Recording is already exists or not
	
			IF @RecordingID IS NOT NULL AND @RecordingID > 0
							
				BEGIN
				
					-- If record file is not UGC file then only we need to check for duplicate file & Rename current file
					
					IF @IsUGC IS NOT NULL AND @IsUGC = 0
						BEGIN
				
							DECLARE @DuplicateFileCount AS INT
							set @DuplicateFileCount = 0
							SELECT @DuplicateFileCount = COUNT(*) 
							FROM IQCore_Recordfile 
							WHERE _RecordingID = @RecordingID AND Location LIKE '%'+@FileExtension+'%'
			
							IF @DuplicateFileCount > 0
								BEGIN
								
							
								
									UPDATE IQCore_Recordfile SET [Status] = 'DUPLICATE'
									WHERE  [Guid] IN (	
														SELECT [Guid] FROM IQCore_Recordfile WHERE _RecordingID = @RecordingID 
														AND Location LIKE '%'+@FileExtension+'%'
													  )
														 
									-- Change Destination File if Duplicate file(s) found
									-- Source File Pattern =  C:\test\ingest\WXIN_20111207_12.mp4
									-- Destincation File Pattern = \2011\12\07\12\WXIN_20111207_12.mp4
									DECLARE @Pos AS INT
									SET @Pos = LEN(@DestinationFile) - CHARINDEX('.',REVERSE(@DestinationFile),0)
									SET @DestinationFile = SUBSTRING(@DestinationFile,1,@Pos) + '-' + CAST((@DuplicateFileCount + 1) AS VARCHAR) + SUBSTRING(@DestinationFile,@Pos + 1,LEN(@DestinationFile))
									
								END
						END
		
		
					-- INSERT New Record into Record Files
					
					SET @RecordFileGuid = NEWID()
					
					INSERT INTO IQCore_Recordfile
					(
						[Guid],
						Location,
						[Status],
						StartOffset,
						EndOffset,
						DateCreated,
						LastModified,
						_RecordingID,
						_RecordfileTypeID,
						_RootPathID,
						_ParentGuid
					)
					VALUES
					(
						@RecordFileGuid,
						@DestinationFile,
						@Status,
						0,
						@EndOffset,
						GETDATE(),
						GETDATE(),
						@RecordingID,
						@RecordFileTypeID,
						@RootPathID,
						NULL
					)
					
					IF(@IsUGC IS NOT NULL AND @IsUGC = 1)
						BEGIN
								
								
								Insert into IQCore_RecordfileMeta
								(
									_RecordfileGuid,
									Field,
									Value
								)
								Select
									@RecordFileGuid,
									tbl.c.value('@Key','varchar(128)') as Field,
									tbl.c.value('@Value','varchar(Max)') as Value
								From
										@UGCMetaData.nodes('/IngestionData/RawInfo/MetaData/Meta') as tbl(c)
								set @temp =  'total '+ CONVERT(varchar(50),@@ROWCOUNT) +' Affected';
								
						
						END
				
					SET @Message='Record Inserted Successfully'
				
					COMMIT TRAN
			END
	END TRY
	
	BEGIN CATCH
	
		SELECT
			  @Message='Error: '+ERROR_MESSAGE()+' Procedure:'+ERROR_PROCEDURE()+' Line:'+ CONVERT(varchar,ERROR_LINE())
				 
		SET @RecordFileGuid=Null
				
		
		IF @@TRANCOUNT > 0
			BEGIN
				ROLLBACK TRAN
			END
		
	
			
	END CATCH
	
	select @temp

END
