CREATE PROCEDURE [dbo].[usp_v5_ArticleRadioDownload_SelectByID]
	@ClipDownloadKey BIGINT,
	@CustomerGuid   uniqueidentifier
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT
			ID,
			ClipGuid,
			ClipDownloadStatus,
			ClipFileLocation,
			ClipDLFormat,
			ClipDLRequestDateTime,
			ClipDownLoadedDateTime,
			IsActive
	FROM 
			IQMediaGroup.dbo.ArticleRadioDownload 
	WHERE	ID = @ClipDownloadKey
	AND		IsActive = 1 AND CustomerGUID = @CustomerGuid
	
	
END