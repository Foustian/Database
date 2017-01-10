-- =============================================
-- Author:		<Author,,Name>
-- Create date: 16 July 2013
-- Description:	Delete customcategory record
-- =============================================
CREATE PROCEDURE [dbo].[usp_v4_CustomCategory_DeleteByCategoryKey] 
	@CustomCategoryKey	BIGINT,
	@ClientGuid			UNIQUEIDENTIFIER,
	@Status				INT OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

		DECLARE @ClipCount INT
	
		SELECT @ClipCount = SUM(RefCount) From
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
			ArchiveClip.IsActive = 1 AND CategoryKey=@CustomCategoryKey)
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
			IQUGCArchive.IsActive = 1 AND  CategoryKey=@CustomCategoryKey)
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
			ArchiveNM.IsActive = 1 AND CategoryKey=@CustomCategoryKey)
		
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
			 ArchiveSM.IsActive = 1 AND CategoryKey=@CustomCategoryKey)	

		Union
		(SELECT 
			COUNT(CategoryKey) as RefCount 
		FROM CustomCategory 
			inner join IQArchive_Media 
				on (IQArchive_Media.CategoryGUID = CustomCategory.CategoryGUID
				OR IQArchive_Media.SubCategory1Guid = CustomCategory.CategoryGUID
					OR IQArchive_Media.SubCategory2Guid = CustomCategory.CategoryGUID
					OR IQArchive_Media.SubCategory3Guid = CustomCategory.CategoryGUID)
		WHERE 
			 IQArchive_Media.IsActive = 1 AND CategoryKey=@CustomCategoryKey)	
		
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
			 ArchiveTweets.IsActive = 1 AND CategoryKey=@CustomCategoryKey)
		 
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
			 ArchiveBLPM.IsActive = 1 AND CategoryKey=@CustomCategoryKey)
		
		Union
		(SELECT 
			COUNT(CategoryKey) as RefCount 
		FROM CustomCategory 
			inner join ArchiveTVEyes
				on (ArchiveTVEyes.CategoryGUID = CustomCategory.CategoryGUID
				OR ArchiveTVEyes.SubCategory1Guid = CustomCategory.CategoryGUID
					OR ArchiveTVEyes.SubCategory2Guid = CustomCategory.CategoryGUID
					OR ArchiveTVEyes.SubCategory3Guid = CustomCategory.CategoryGUID)
		WHERE 
			 ArchiveTVEyes.IsActive = 1 AND CategoryKey=@CustomCategoryKey)
		Union
		(SELECT 
			COUNT(CategoryKey) as RefCount 
		FROM CustomCategory 
			inner join IQReport_Feeds
				on IQReport_Feeds.CategoryGuid = CustomCategory.CategoryGUID
			inner join IQ_Report
				on IQReport_Feeds.ReportGUID = IQ_Report.ReportGUID
		WHERE 
			 IQReport_Feeds.IsActive = 1 
			 AND IQ_Report.IsActive = 1
			 AND CategoryKey=@CustomCategoryKey)	 
		Union
		(SELECT 
			COUNT(CategoryKey) as RefCount 
		FROM CustomCategory 
			inner join IQReport_Discovery
				on IQReport_Discovery.CategoryGuid = CustomCategory.CategoryGUID
			inner join IQ_Report
				on IQReport_Discovery.ReportGUID = IQ_Report.ReportGUID
		WHERE 
			 IQReport_Discovery.IsActive = 1 
			 AND IQ_Report.IsActive = 1
			 AND CategoryKey=@CustomCategoryKey)	
			) as RefCategoryList

		IF @ClipCount = 0 
			BEGIN

				UPDATE	CustomCategory
				SET		IsActive = 0,
						ModifiedDate = GETDATE()
				WHERE	CategoryKey = @CustomCategoryKey
				AND		ClientGuid = @ClientGuid
				AND		IsActive = 1
			
				SET @Status = 1
			
			END
		ELSE
			BEGIN
				SET @Status = -1
			END
   
END
