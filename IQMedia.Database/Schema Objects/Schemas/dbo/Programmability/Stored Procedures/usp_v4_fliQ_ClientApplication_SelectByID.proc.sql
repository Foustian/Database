CREATE PROCEDURE [dbo].[usp_v4_fliQ_ClientApplication_SelectByID]
	@ID bigint
AS
BEGIN
	SELECT
			fliQ_ClientApplication.ID,
			Client.ClientKey,
			_FliqApplicationID,
			FTPHost,
			FTPPath,
			FTPLoginID,
			FTPPwd,
			fliQ_ClientApplication.IsCategoryEnable,
			fliQ_ClientApplication.IsActive,
			fliQ_ClientApplication.ForceLandscape,
			fliQ_ClientApplication.DefaultCategory,
			fliQ_ClientApplication.MaxVideoDuration

	FROM	
			fliQ_ClientApplication
				inner join Client	
					on fliQ_ClientApplication.ClientGUID = Client.ClientGUID
	WHERE
			ID = @ID
					
END