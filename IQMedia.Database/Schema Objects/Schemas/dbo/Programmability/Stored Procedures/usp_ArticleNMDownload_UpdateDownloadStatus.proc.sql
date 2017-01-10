CREATE PROCEDURE [dbo].[usp_ArticleNMDownload_UpdateDownloadStatus]
	@ID					bigint,
	@DownloadStatus		tinyint,
	@FileLocation		varchar(255)
AS
BEGIN
	
	UPDATE 
			ArticleNMDownload
	SET
		   DownloadStatus = @DownloadStatus,
		   DownLoadedDateTime = CASE WHEN @DownloadStatus = 3 THEN GETDATE() ELSE NULL END,
		   DownloadLocation = (CASE  WHEN @FileLocation is null OR @FileLocation='' THEN 
									DownloadLocation 
							   ELSE 
									@FileLocation
							  END
							  )
	WHERE
		   ID = @ID	

END