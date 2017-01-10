-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_CustomCategory_Delete]
	
	@CategoryKey			BIGINT
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT OFF;
	
	DECLARE @ClipCount int
    SELECT @ClipCount = Sum(RefCount) From
    (
	(SELECT 
		COUNT(CategoryKey) as RefCount 
	FROM CustomCategory
		inner join ArchiveClip 
			on 
			(ArchiveClip.CategoryGUID = CustomCategory.CategoryGUID 
				OR ArchiveClip.SubCategory1Guid = CustomCategory.CategoryGUID
				OR ArchiveClip.SubCategory2Guid = CustomCategory.CategoryGUID
				OR ArchiveClip.SubCategory3Guid = CustomCategory.CategoryGUID
				)
    WHERE 
		ArchiveClip.IsActive = 1 AND CategoryKey=@CategoryKey)
    Union
    (SELECT 
		COUNT(CategoryKey) as RefCount 
	FROM CustomCategory 
		inner join IQUGCArchive 
			on (IQUGCArchive.CategoryGUID = CustomCategory.CategoryGUID
			OR IQUGCArchive.SubCategory1Guid = CustomCategory.CategoryGUID
				OR IQUGCArchive.SubCategory2Guid = CustomCategory.CategoryGUID
				OR IQUGCArchive.SubCategory3Guid = CustomCategory.CategoryGUID
			)
    WHERE 
		IQUGCArchive.IsActive = 1 AND  CategoryKey=@CategoryKey)
	Union
    (SELECT 
		COUNT(CategoryKey) as RefCount 
	FROM CustomCategory 
		inner join ArchiveNM 
			on (ArchiveNM.CategoryGUID = CustomCategory.CategoryGUID
			OR ArchiveNM.SubCategory1Guid = CustomCategory.CategoryGUID
				OR ArchiveNM.SubCategory2Guid = CustomCategory.CategoryGUID
				OR ArchiveNM.SubCategory3Guid = CustomCategory.CategoryGUID)
    WHERE 
		ArchiveNM.IsActive = 1 AND CategoryKey=@CategoryKey)
		
	Union
    (SELECT 
		COUNT(CategoryKey) as RefCount 
	FROM CustomCategory 
		inner join ArchiveSM 
			on (ArchiveSM.CategoryGUID = CustomCategory.CategoryGUID
			OR ArchiveSM.SubCategory1Guid = CustomCategory.CategoryGUID
				OR ArchiveSM.SubCategory2Guid = CustomCategory.CategoryGUID
				OR ArchiveSM.SubCategory3Guid = CustomCategory.CategoryGUID)
    WHERE 
		 ArchiveSM.IsActive = 1 AND CategoryKey=@CategoryKey)	

	Union
    (SELECT 
		COUNT(CategoryKey) as RefCount 
	FROM CustomCategory 
		inner join IQCustomer_SavedSearch
			on IQCustomer_SavedSearch.CategoryGuid = CustomCategory.CategoryGUID
    WHERE 
		IQCustomer_SavedSearch.IsActive = 1 AND CategoryKey=@CategoryKey)
		
	Union
    (SELECT 
		COUNT(CategoryKey) as RefCount 
	FROM CustomCategory 
		inner join ArchiveTweets 
			on (ArchiveTweets.CategoryGUID = CustomCategory.CategoryGUID
			OR ArchiveTweets.SubCategory1Guid = CustomCategory.CategoryGUID
				OR ArchiveTweets.SubCategory2Guid = CustomCategory.CategoryGUID
				OR ArchiveTweets.SubCategory3Guid = CustomCategory.CategoryGUID)
    WHERE 
		 ArchiveTweets.IsActive = 1 AND CategoryKey=@CategoryKey)
		 
	Union
    (SELECT 
		COUNT(CategoryKey) as RefCount 
	FROM CustomCategory 
		inner join ArchiveBLPM
			on (ArchiveBLPM.CategoryGUID = CustomCategory.CategoryGUID
			OR ArchiveBLPM.SubCategory1Guid = CustomCategory.CategoryGUID
				OR ArchiveBLPM.SubCategory2Guid = CustomCategory.CategoryGUID
				OR ArchiveBLPM.SubCategory3Guid = CustomCategory.CategoryGUID)
    WHERE 
		 ArchiveBLPM.IsActive = 1 AND CategoryKey=@CategoryKey)	
		) as RefCategoryList
    
    
    IF @ClipCount = 0 
    BEGIN 
    
	UPDATE CustomCategory
	SET
		IsActive = 0
	WHERE
		CategoryKey = @CategoryKey
		
	end

END
