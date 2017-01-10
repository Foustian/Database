CREATE PROCEDURE [dbo].[usp_v4_OptiQ_LRResults_SelectByGuid]
	@RecordfileGuid uniqueidentifier
AS
BEGIN
	SET NOCOUNT ON;

	SELECT	DISTINCT IQ_LR_Brand.ID as LogoID,
			Brand as CompanyName,
			IQCore_RootPath.StreamSuffixPath + IQ_LR_Brand.Filepath + IQ_LR_Brand.Logo_thumbs as ThumbnailPath,
			offset.value('(Offset/text())[1]', 'int') as Offset,
			IQCore_RootPath.StreamSuffixPath + IQ_LR_Search_Images.filepath + IQ_LR_Search_Images.DisplayFileName as HitLogoPath
	FROM	IQMediaGroup.dbo.IQ_LR_Results
	CROSS	APPLY Hits.nodes('/LROffsets/Hits') as Results(offset)
    INNER	JOIN IQMediaGroup.dbo.IQ_LR_Search_Images ON IQ_LR_Search_Images.ID = IQ_LR_Results._SearchLogoID
	INNER	JOIN IQMediaGroup.dbo.IQ_LR_Brand ON IQ_LR_Brand.ID = IQ_LR_Search_Images.Brand_ID
	INNER	JOIN IQMediaGroup.dbo.IQCore_RootPath ON IQCore_RootPath.ID = IQ_LR_Brand.RPID
	WHERE	IQ_LR_Results.RecordfileGuid = @RecordfileGuid
			AND IQ_LR_Results.IsActive = 1
	ORDER	BY LogoID,
			Offset
END
