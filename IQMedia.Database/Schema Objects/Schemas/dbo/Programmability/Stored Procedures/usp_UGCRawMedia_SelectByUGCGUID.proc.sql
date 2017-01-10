CREATE PROCEDURE [dbo].[usp_UGCRawMedia_SelectByUGCGUID] 
	-- Add the parameters for the stored procedure here
	@UGCGUID uniqueidentifier
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    
    SELECT
		IQUGCArchiveKey,
		UGCGUID,
		Title,
		CategoryGUID,
		Keywords,
		[Description],
		CustomerGUID,
		SubCategory1GUID,
		SubCategory2GUID,
		SubCategory3GUID
	FROM
		IQUGCArchive
	WHERE
		IQUGCArchive.UGCGUID=@UGCGUID and IQUGCArchive.IsActive = 1
END
