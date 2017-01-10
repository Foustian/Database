-- =============================================
-- Author:		<Author,,Name>
-- Create date: 19 June 2013
-- Description:	Select Clip download record by ClipDownloadKey
-- =============================================
CREATE PROCEDURE [dbo].[usp_v4_ClipDownload_SelectByClipDownloadKey]
	@ClipDownloadKey BIGINT,
	@CustomerGuid   uniqueidentifier
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT
			IQ_ClipDownload_Key,
			ClipID,
			ClipDownloadStatus,
			ClipFileLocation,
			ClipDLFormat,
			ClipDLRequestDateTime,
			ClipDownLoadedDateTime,
			IsActive
	FROM 
			ClipDownload 
	WHERE	IQ_ClipDownload_Key = @ClipDownloadKey
	AND		IsActive = 1 AND CustomerGUID = @CustomerGuid
	
	
END
