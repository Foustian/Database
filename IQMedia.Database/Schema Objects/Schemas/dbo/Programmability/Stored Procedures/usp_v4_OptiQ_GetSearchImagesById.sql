CREATE PROCEDURE [dbo].[usp_v4_OptiQ_GetSearchImagesById]
	@LRSearchIDs varchar(max)
AS
BEGIN
	DECLARE @IDsXML XML
	SET @IDsXML = CAST('<i>' + REPLACE(@LRSearchIDs, ',', '</i><i>') + '</i>' AS XML)

    Select [IQMediaGroup].[dbo].[IQ_LR_Search_Images].ID, IQCore_RootPath.StreamSuffixPath + IQ_LR_Search_Images.filepath + IQ_LR_Search_Images.DisplayFileName as HitLogoPath
	From [IQMediaGroup].[dbo].[IQ_LR_Search_Images] with (nolock) 
	INNER JOIN IQMediaGroup.dbo.IQ_LR_Brand with (nolock) ON IQ_LR_Brand.ID = IQ_LR_Search_Images.Brand_ID
	INNER JOIN IQMediaGroup.dbo.IQCore_RootPath with (nolock) ON IQCore_RootPath.ID = IQ_LR_Brand.RPID
	INNER JOIN @IDsXML.nodes('i') x(i) ON  [IQMediaGroup].[dbo].[IQ_LR_Search_Images].ID = x.i.value('.', 'VARCHAR(MAX)')
	Where [IQMediaGroup].[dbo].[IQ_LR_Search_Images].IsActive = 1 	
END