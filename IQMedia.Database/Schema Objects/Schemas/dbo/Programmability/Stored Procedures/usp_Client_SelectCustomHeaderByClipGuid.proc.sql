CREATE PROCEDURE [dbo].[usp_Client_SelectCustomHeaderByClipGuid]
	@ClipGuid			uniqueidentifier
AS
BEGIN
	Select 
		CustomHeaderImage
	from Client 
		inner join IQCore_ClipMeta 
			on IQCore_ClipMeta.Value = Client.ClientGUID 
			AND IQCore_ClipMeta.Field ='iqClientid'
		AND IQCore_ClipMeta._ClipGuid = @ClipGuid
		Where Client.IsCustomHeader = 1
END