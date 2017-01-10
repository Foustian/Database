-- =============================================
-- Author:		<Author,,Name>
-- Create date: 14 June 2013
-- Description:	Return no of download count by customer
-- =============================================
CREATE PROCEDURE [dbo].[usp_v4_ArticleNMDownload_SelectDownloadLimit]
	@CustomerGUID	UNIQUEIDENTIFIER
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT	
			COUNT(*) AS DownloadCount 
	FROM 
			[dbo].[ArticleNMDownload]
	WHERE	
			CustomerGUID = @CustomerGUID
	AND		DownloadStatus != 3
	AND		IsActive=1
END