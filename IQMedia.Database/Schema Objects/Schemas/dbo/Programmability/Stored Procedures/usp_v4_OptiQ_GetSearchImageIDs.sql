CREATE PROCEDURE [dbo].[usp_v4_OptiQ_GetSearchImageIDs]
	@BrandID bigint
AS
BEGIN
    Select [IQMediaGroup].[dbo].[IQ_LR_Search_Images].ID
	From [IQMediaGroup].[dbo].[IQ_LR_Search_Images] with (nolock) 
	inner join [IQMediaGroup].[dbo].[IQ_LR_Brand] with (nolock) on Brand_ID = [IQMediaGroup].[dbo].[IQ_LR_Brand].ID
	Where 
		 [IQMediaGroup].[dbo].[IQ_LR_Search_Images].[IsActive] = 1 and [IQMediaGroup].[dbo].[IQ_LR_Brand].ID = @BrandID
    
END