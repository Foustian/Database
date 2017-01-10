CREATE PROCEDURE [dbo].[usp_ArchiveSM_Report]
	@ClientGUID uniqueidentifier,
	@ArticleDate date
AS
BEGIN

	SELECT 
			MAX(CustomCategory.CategoryName) as CategoryName,
			ArchiveSM.CategoryGuid,
			COUNT(ArchiveSM.ArchiveSMKey) As Total
	FROM
			ArchiveSM 
				Inner JOIN CustomCategory
					ON ArchiveSM.CategoryGuid = CustomCategory.CategoryGUID
	WHERE
			ArchiveSM.ClientGuid = @ClientGUID
			AND CONVERT(Date,ArchiveSM.CreatedDate) = @ArticleDate
			AND ArchiveSM.IsActive = 1
	GROUP BY 
			ArchiveSM.CategoryGuid
	HAVING
			COUNT(ArchiveSM.ArchiveSMKey) > 0

END