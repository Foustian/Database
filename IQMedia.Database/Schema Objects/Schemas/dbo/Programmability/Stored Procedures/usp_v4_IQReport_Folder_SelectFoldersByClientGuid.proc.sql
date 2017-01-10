CREATE PROCEDURE [dbo].[usp_v4_IQReport_Folder_SelectFoldersByClientGuid]
	@ClientGuid uniqueidentifier
AS
BEGIN
	SELECT
			ID,
			Name,
			_ParentID
	FROM 
			IQReport_Folder
	Where
			_ClientGUID  = @ClientGuid
			and IsActive = 1
	ORDER BY NAME	
END