CREATE PROCEDURE [dbo].[usp_v4_IQCore_RootPath_SelectUGCDocumentRootPath]
	
AS
BEGIN
	SELECT Top 1 
			IQCore_RootPath.StoragePath,
			IQCore_RootPath.ID
	FROM
			IQCore_RootPath 
				inner join IQCore_RootPathType
					on IQCore_RootPath._RootPathTypeID = IQCore_RootPathType.ID
					and IQCore_RootPath.IsActive  = 1
	WHERE
			IQCore_RootPathType.Name ='UGCDocuments'
	ORDER BY NEWID()
END