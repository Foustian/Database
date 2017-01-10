CREATE PROCEDURE [dbo].[usp_ClipDownload_UpdateClipDownloadStatus]
(
	@IQ_ClipDownload_Key	bigint,
	@ClipDownloadStatus		tinyint,
	@Location varchar(max)

)
AS
BEGIN
	SET NOCOUNT OFF;
	
	if (@ClipDownloadStatus=4)
		begin
				Update
						ClipDownload
				set
						ClipDownloadStatus=@ClipDownloadStatus,
						ClipDownLoadedDateTime=GETDATE()
				Where
						IQ_ClipDownload_Key=@IQ_ClipDownload_Key				
						

		end
	else
		begin
		
				Update
						ClipDownload
				set
						ClipDownloadStatus=@ClipDownloadStatus,
						ClipFileLocation = (CASE 
											WHEN @Location is null OR @Location='' THEN ClipFileLocation
											ELSE @Location
											END)
				Where
						IQ_ClipDownload_Key=@IQ_ClipDownload_Key    
		
		end
    
END



