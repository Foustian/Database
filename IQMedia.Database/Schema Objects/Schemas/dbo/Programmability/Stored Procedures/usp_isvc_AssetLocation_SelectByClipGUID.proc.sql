CREATE PROCEDURE [dbo].[usp_isvc_AssetLocation_SelectByClipGUID]
(
	@ClipGUID		UNIQUEIDENTIFIER
)
AS
BEGIN

	SET NOCOUNT ON;

	SELECT
			TOP(1)
			(IQCore_RootPath.StreamSuffixPath+IQCore_AssetLocation.Location)
	FROM
			IQCore_AssetLocation WITH(NOLOCK)
				INNER JOIN	IQCore_RootPath WITH(NOLOCK)
					ON	 IQCore_AssetLocation._RootPathID = IQCore_RootPath.ID
					AND	 IQCore_AssetLocation._AssetGuid = @ClipGUID

END