-- =============================================
-- Author:		<Author,,Name>
-- Create date: 19 June 2013
-- Description:	Update in ClipDownload table
-- =============================================
CREATE PROCEDURE [dbo].[usp_v4_ClipDownload_Update]
	@ClipDownloadKey	BIGINT,
	@FileLocation		VARCHAR(150),
	@FileExtension		VARCHAR(50),
	@DownloadStatus		INT,
	@CustomerGuid		uniqueidentifier
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	UPDATE ClipDownload
	SET		
		ClipFileLocation = CASE WHEN @FileLocation IS NOT NULL THEN @FileLocation ELSE ClipFileLocation END,
		ClipDLFormat = CASE WHEN @FileExtension IS NOT NULL THEN @FileExtension ELSE ClipDLFormat END,
		ClipDownloadStatus = @DownloadStatus,
		ClipDownLoadedDateTime = CASE WHEN @DownloadStatus = 4 THEN GETDATE() ELSE ClipDownLoadedDateTime END,
		ModifiedDate = GETDATE()
	WHERE
		IQ_ClipDownload_Key = @ClipDownloadKey AND CustomerGUID = @CustomerGuid
			
END
