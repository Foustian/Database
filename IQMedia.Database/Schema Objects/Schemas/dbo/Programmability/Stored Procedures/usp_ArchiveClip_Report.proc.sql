CREATE PROCEDURE [dbo].[usp_ArchiveClip_Report]
	@ClientGUID uniqueidentifier,
	@ClipDate	date
AS
BEGIN

	SELECT 
			MAX(CustomCategory.CategoryName) as CategoryName,
			ArchiveClip.CategoryGUID,
			COUNT(ArchiveClip.CategoryGUID) As Total
	FROM
			ArchiveClip 
				Inner JOIN CustomCategory
					ON ArchiveClip.CategoryGUID = CustomCategory.CategoryGUID
	WHERE
			ArchiveClip.ClientGUID = @ClientGUID
			AND CONVERT(Date,ArchiveClip.ClipCreationDate) = @ClipDate
			AND ArchiveClip.IsActive = 1
	GROUP BY 
			ArchiveClip.CategoryGUID
	HAVING
			COUNT(ArchiveClip.CategoryGUID) > 0

END