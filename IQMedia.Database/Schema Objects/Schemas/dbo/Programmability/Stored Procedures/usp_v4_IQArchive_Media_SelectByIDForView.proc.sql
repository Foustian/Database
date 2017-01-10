CREATE PROCEDURE [dbo].[usp_v4_IQArchive_Media_SelectByIDForView] 
	@ID				BIGINT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @MediaType AS VARCHAR(10),@ArchiveMediaID AS BIGINT
	
	SELECT 
			@MediaType = MediaType,
			@ArchiveMediaID = _ArchiveMediaID
	FROM 
			IQArchive_Media 
	WHERE	ID = @ID
	
	IF @ArchiveMediaID IS NOT NULL AND @MediaType = 'PQ'
		BEGIN
				SELECT 
						@MediaType as MediaType,
						Content,
						ContentHTML,
						MediaDate,
						Author,
						Publication,
						Title,
						Copyright
				FROM
						ArchivePQ WITH (NOLOCK)
				WHERE	ArchivePQKey = @ArchiveMediaID
		END
END
