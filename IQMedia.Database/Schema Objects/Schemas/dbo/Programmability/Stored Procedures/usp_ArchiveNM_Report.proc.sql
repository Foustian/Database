CREATE PROCEDURE [dbo].[usp_ArchiveNM_Report]
	@ClientGUID uniqueidentifier,
	@ArticleDate	date
AS
BEGIN

	SELECT 
			MAX(CustomCategory.CategoryName) as CategoryName,
			ArchiveNM.CategoryGuid,
			COUNT(ArchiveNM.CategoryGuid) As Total
	FROM
			ArchiveNM 
				Inner JOIN CustomCategory
					ON ArchiveNM.CategoryGuid = CustomCategory.CategoryGUID
	WHERE
			ArchiveNM.ClientGuid = @ClientGUID
			AND CONVERT(Date,ArchiveNM.CreatedDate) = @ArticleDate
			AND ArchiveNM.IsActive = 1
	GROUP BY 
			ArchiveNM.CategoryGuid
	HAVING
			COUNT(ArchiveNM.CategoryGuid) > 0

END