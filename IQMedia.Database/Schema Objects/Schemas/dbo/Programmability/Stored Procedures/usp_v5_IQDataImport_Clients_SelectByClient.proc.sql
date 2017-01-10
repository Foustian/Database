CREATE PROCEDURE [dbo].[usp_v5_IQDataImport_Clients_SelectByClient]  
	@ClientGuid UNIQUEIDENTIFIER
AS  
BEGIN  	
	SELECT	ID,
			ViewPath,
			GetResultsMethod
	FROM	IQMediaGroup.dbo.IQDataImport_Clients	
	WHERE	_ClientGuid = @ClientGUID
			AND IsActive = 1
END