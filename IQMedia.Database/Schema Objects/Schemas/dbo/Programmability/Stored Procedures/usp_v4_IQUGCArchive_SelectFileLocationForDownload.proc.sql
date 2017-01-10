CREATE PROCEDURE [dbo].[usp_v4_IQUGCArchive_SelectFileLocationForDownload]
	@IQUGCArchiveKey		BIGINT,
	@ClientGuid				UNIQUEIDENTIFIER
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @UGCGuid AS UNIQUEIDENTIFIER,@UGCFileLocation AS VARCHAR(2000),@UGCFileName AS VARCHAR(1000),@FileType varchar(50),@RootPathID int,@Localtion varchar(500)
	
	SELECT	
			@UGCGuid = UGCGUID ,
			@FileType = IQUGC_FileTypes.FileType,
			@RootPathID  = IQUGCArchive._RootPathID,
			@Localtion = IQUGCArchive.Location
	FROM 
			IQUGCArchive
				LEFT OUTER JOIN IQUGC_FileTypes 
					ON IQUGCArchive._FileTypeID = IQUGC_FileTypes.ID
					AND IQUGC_FileTypes.IsActive = 1
	WHERE	
			IQUGCArchiveKey=@IQUGCArchiveKey 
			AND		ClientGUID = @ClientGuid
			AND		IQUGCArchive.IsActive = 1
	
	
	IF @UGCGuid IS NOT NULL
		BEGIN
			IF(@FileType = 'VMedia' OR @FileType IS NULL)
			BEGIN
				SELECT	@UGCFileLocation = [Value] 
			FROM	IQCore_RecordFileMeta 
			WHERE	_RecordFileGuid = @UGCGuid 
			AND		Field = 'UGC-FileLocation'

				SELECT	@UGCFileName = [Value] 
			FROM	IQCore_RecordFileMeta 
			WHERE	_RecordFileGuid = @UGCGuid 
			AND		Field = 'UGC-FileName'
			
			END
			ELSE 
			BEGIN
				SELECT @UGCFileLocation = StoragePath From IQCore_RootPath Where ID = @RootPathID

				SET @UGCFileName = @Localtion
			END
			
			SELECT @UGCFileLocation AS UGCFileLocation,@UGCFileName AS UGCFileName
		END
	ELSE
		BEGIN
			SELECT NULL AS UGCFileLocation,NULL AS UGCFileName
		END

END
