CREATE PROCEDURE [dbo].[usp_v5_TAdsResult_GetFilters]
AS  
BEGIN   
	SET NOCOUNT ON;  
   
	--Logos
	SELECT DISTINCT IQ_LR_Search_Images.Brand_ID AS 'BrandID', DisplayFileName AS 'Name', IQ_LR_Search_Images.ID AS 'ID', IQCore_RootPath.StreamSuffixPath + IQ_LR_Search_Images.filepath + DisplayFileName AS 'URL'
	FROM [IQMediaGroup].[dbo].[IQ_LR_Search_Images]
	INNER JOIN IQMediaGroup.dbo.IQCore_RootPath 
		ON IQCore_RootPath.ID = IQ_LR_Search_Images.RPID
	WHERE IQ_LR_Search_Images.IsActive = 1
	ORDER BY DisplayFileName

	--Brand
	SELECT DISTINCT IQ_LR_Brand.ID AS 'ID', IQ_LR_Brand.Brand AS 'Name', IQCore_RootPath.StreamSuffixPath + IQ_LR_Brand.filepath + logo_thumbs AS 'URL'
	FROM [IQMediaGroup].[dbo].[IQ_LR_Brand]
	INNER JOIN IQMediaGroup.dbo.IQCore_RootPath 
		ON IQCore_RootPath.ID = IQ_LR_Brand.RPID
	WHERE IQ_LR_Brand.IsActive = 1
	ORDER BY Brand

	--Industry
	SELECT DISTINCT ID AS 'ID', Industry AS 'Name'
	FROM [IQMediaGroup].[dbo].[IQ_LR_Industry]
	WHERE IsActive = 1
	ORDER BY Industry

	--Company
	SELECT DISTINCT ID AS 'ID', Company_Name AS 'Name'
	FROM [IQMediaGroup].[dbo].[IQ_LR_Company]
	WHERE IsActive = 1
	ORDER BY Company_Name

END