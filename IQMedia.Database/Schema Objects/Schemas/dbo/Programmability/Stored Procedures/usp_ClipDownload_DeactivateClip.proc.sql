
CREATE PROCEDURE usp_ClipDownload_DeactivateClip
(
	@ClipID		uniqueidentifier
)
AS
BEGIN
	SET NOCOUNT OFF;
	
	update 
			ClipDownload
	Set
			IsActive=0
	Where
			ClipID=@ClipID
	

    
END
