-- =============================================
-- Author:		<Author,,Name>
-- Create date: 19 June 2013
-- Description:	Insert into ClipDownload
-- =============================================
CREATE PROCEDURE [dbo].[usp_v4_ClipDownload_Insert]
	@CustomerGUID	UNIQUEIDENTIFIER,
	@ID				BIGINT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @ClipID AS UNIQUEIDENTIFIER,@DownloadStatus AS INT

	DECLARE @ClientGUID UNIQUEIDENTIFIER
	
	Select
		@ClientGUID=ClientGUID
	From
		Customer
			INNER JOIN Client
				ON Customer.ClientID=Client.ClientKey
				AND Customer.CustomerGUID=@CustomerGUID

	SELECT @ClipID = ClipID
	FROM	IQArchive_Media
	INNER JOIN ArchiveClip
	ON		IQArchive_Media._ArchiveMediaID = ArchiveClip.ArchiveClipKey
	AND		IQArchive_Media.ID = @ID
	AND		IQArchive_Media.ClientGUID = @ClientGUID
	WHERE	IQArchive_Media.ID = @ID
	
 
    IF @ClipID IS NOT NULL AND NOT EXISTS (SELECT 1 FROM ClipDownload 
											WHERE CustomerGUID = @CustomerGUID 
											AND ClipID = @ClipID AND ClipDownloadStatus < 3 AND IsActive = 1) 
		BEGIN
			
				INSERT INTO ClipDownload
				(
					ClipID,
					CustomerGUID,
					ClipDownloadStatus,
					ClipDLRequestDateTime,
					ClipDLFormat,
					ClipFileLocation,
					ClipDownLoadedDateTime,
					CreatedBy,
					ModifiedBy,
					CreatedDate,
					ModifiedDate,
					IsActive
				)
				VALUES 
				(
					@ClipID,
					@CustomerGUID,
					1,
					GETDATE(),
					NULL,
					NULL,
					GETDATE(),
					'System',
					'System',
					GETDATE(),
					GETDATE(),
					1
				)
		END
END
