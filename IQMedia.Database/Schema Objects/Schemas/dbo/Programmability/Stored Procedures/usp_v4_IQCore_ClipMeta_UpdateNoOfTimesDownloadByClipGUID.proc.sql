CREATE PROCEDURE [dbo].[usp_v4_IQCore_ClipMeta_UpdateNoOfTimesDownloadByClipGUID]
(
	@ClipGUID		uniqueidentifier
)
AS
BEGIN
	SET NOCOUNT ON;

	Update 
		IQCore_ClipMeta 
	Set 
		Value = CONVERT(int,Value) + 1
	Where 
		Field ='NoOfTimesDownloaded' And
		_ClipGuid = @ClipGUID
		
	

END