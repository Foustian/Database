CREATE PROCEDURE [dbo].[usp_v5_ArticleRadioDownload_Insert]
	@CustomerGUID	UNIQUEIDENTIFIER,
	@ID				BIGINT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @ClipGuid AS UNIQUEIDENTIFIER, @DownloadStatus AS INT

	DECLARE @ClientGUID UNIQUEIDENTIFIER
	
	Select
		@ClientGUID = ClientGUID
	From
		IQMediaGroup.dbo.Customer
			INNER JOIN IQMediaGroup.dbo.Client
				ON Customer.ClientID=Client.ClientKey
				AND Customer.CustomerGUID=@CustomerGUID

	SELECT	@ClipGuid = ClipGuid
	FROM	IQMediaGroup.dbo.IQArchive_Media WITH (NOLOCK)
	INNER	JOIN IQMediaGroup.dbo.ArchiveRadio WITH (NOLOCK)
			ON IQArchive_Media._ArchiveMediaID = ArchiveRadio.ArchiveRadioKey
			AND IQArchive_Media.v5SubMediaType = ArchiveRadio.v5SubMediaType
			AND IQArchive_Media.ClientGUID = @ClientGUID
	WHERE	IQArchive_Media.ID = @ID
	
 
    IF @ClipGuid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM IQMediaGroup.dbo.ArticleRadioDownload 
											WHERE CustomerGUID = @CustomerGUID 
											AND ClipGuid = @ClipGuid AND ClipDownloadStatus < 3 AND IsActive = 1) 
		BEGIN			
				INSERT INTO ArticleRadioDownload
				(
					ClipGuid,
					CustomerGUID,
					ClipDownloadStatus,
					ClipDLRequestDateTime,
					ClipDLFormat,
					ClipFileLocation,
					CreatedBy,
					ModifiedBy,
					CreatedDate,
					ModifiedDate,
					IsActive
				)
				VALUES 
				(
					@ClipGuid,
					@CustomerGUID,
					1,
					GETDATE(),
					NULL,
					NULL,
					'System',
					'System',
					GETDATE(),
					GETDATE(),
					1
				)
		END
END