CREATE PROCEDURE [dbo].[usp_IQCore_NM_SelectArticleFilePathByArticleID]
	@ArticleID varchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	SELECT 
			ISNULL(IQCore_RootPath.StoragePath + '\' + IQCore_Nm.Location,'') As DownloadLocation
	FROM 
			IQcore_NM INNER JOIN IQcore_RootPath
				ON IQcore_NM._RootPathID = IQcore_RootPath.ID
			AND IQcore_NM.ArticleID = @ArticleID
END
