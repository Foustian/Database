CREATE PROCEDURE [dbo].[usp_metadataupd_IQService_ArchiveMetaDataUpdate_UpdateArchiveMedia]
(
	@MediaID BIGINT,
	@MediaType VARCHAR(2),
	@MediaContent NVARCHAR(MAX)
)
AS
BEGIN	
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	BEGIN TRANSACTION

	DECLARE @SubMediaType VARCHAR(50)

    IF @MediaType = 'NM'
      BEGIN
		UPDATE	ArchiveNM
		SET		ArticleContent = @MediaContent,
				ModifiedDate = GETDATE()
		WHERE	ArchiveNMKey = @MediaID	

		SELECT	@SubMediaType = v5SubMediaType
		FROM	ArchiveNM
		WHERE	ArchiveNMKey = @MediaID	
      END
    ELSE IF @MediaType = 'SM'
      BEGIN
		UPDATE	ArchiveSM
		SET		ArticleContent = @MediaContent,
				ModifiedDate = GETDATE()
		WHERE	ArchiveSMKey = @MediaID	

		SELECT	@SubMediaType = v5SubMediaType
		FROM	ArchiveSM
		WHERE	ArchiveSMKey = @MediaID		
      END
    ELSE IF @MediaType = 'TV'
      BEGIN
		UPDATE	ArchiveClip
		SET		ClosedCaption = @MediaContent,
				ModifiedDate = GETDATE()
		WHERE	ArchiveClipKey = @MediaID		

		SELECT	@SubMediaType = v5SubMediaType
		FROM	ArchiveClip
		WHERE	ArchiveClipKey = @MediaID		
      END
	ELSE IF @MediaType = 'PQ'
	  BEGIN
		UPDATE	ArchivePQ
		SET		Content = @MediaContent,
				ModifiedDate = GETDATE()
		WHERE	ArchivePQKey = @MediaID

		SELECT	@SubMediaType = v5SubMediaType
		FROM	ArchivePQ
		WHERE	ArchivePQKey = @MediaID	
	  END
    ELSE IF @MediaType = 'IQR'
      BEGIN
		UPDATE	ArchiveRadio
		SET		ClosedCaption = @MediaContent,
				ModifiedDate = GETDATE()
		WHERE	ArchiveRadioKey = @MediaID		

		SELECT	@SubMediaType = v5SubMediaType
		FROM	ArchiveRadio
		WHERE	ArchiveRadioKey = @MediaID		
      END
      
    UPDATE	IQArchive_Media
	SET		Content = @MediaContent
	WHERE	_ArchiveMediaID = @MediaID
			AND v5SubMediaType = @SubMediaType
	
	COMMIT TRANSACTION
    
END
