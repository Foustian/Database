CREATE PROCEDURE [dbo].[usp_v4_IQReport_Folder_SelectbyClientGuid]
	@ClientGuid uniqueidentifier
AS
BEGIN
	SELECT
			ID,
			Name as [text],
			_ParentID as parent
	FROM 
			IQReport_Folder
	Where
			_ClientGUID  = @ClientGuid
			and IsActive = 1
	order by [text]
END