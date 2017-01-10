
CREATE PROCEDURE usp_ClipDownloadSettings_CheckForClient
(
	@ClientGUID		uniqueidentifier
)
AS
BEGIN
	SET NOCOUNT ON;
	
	Select 
			COUNT(*) 
	From
			ClipDownloadSettings
	Where
			ClientGUID=@ClientGUID and
			IsActive=1


END
