USE [IQMediaGroup]
GO

/****** Object:  StoredProcedure [dbo].[usp_v4_IQ_Report_MCMediaTemplateTrivago_SelectCategoryFilter]    Script Date: 12/14/2015 8:48:51 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_v5_IQ_Report_MCMediaTemplateTrivago_SelectCategoryFilter]
	@FromDate			datetime,
	@ToDate				datetime,
	@SubMediaType		varchar(50),
	@SearchTerm			varchar(max),
	@SentimentFlag		int,
	@CategoryXml		xml,
	@ReportGUID			varchar(100)
AS
BEGIN
		DECLARE @MasterClientID bigint
		SELECT	@MasterClientID = ClientKey
		FROM	Client
		INNER	JOIN IQ_Report WITH (NOLOCK)
				ON IQ_Report.ClientGuid = Client.ClientGUID
				AND IQ_Report.ReportGUID = @ReportGUID

		DECLARE @TotalCats  int 					
		DECLARE @TempTable table(CategoryGuid uniqueidentifier, CategoryName varchar(150))
				
		-- If multiple clients within a master client have categories with the same name, they're grouped together by name for filtering purposes.
		-- Split them out into their individual GUIDs, making sure to filter out categories with the same name on other clients.
		INSERT INTO @TempTable
		SELECT	CategoryGUID,
				CategoryName
		FROM	CustomCategory
		INNER	JOIN @CategoryXml.nodes('list/item') as cat(item)
				ON CustomCategory.CategoryName = cat.item.value('@name','varchar(150)')
		INNER	JOIN Client
				ON CustomCategory.ClientGUID = Client.ClientGUID
				AND Client.MCID = @MasterClientID

		SELECT @TotalCats = count(distinct CategoryName) FROM @TempTable as t
		IF(@CategoryXml IS NULL)
		BEGIN
				SELECT	
						CategoryName,
						COUNT(IQArchive_Media.ID) AS CategoryCount
				FROM	IQArchive_Media WITH (NOLOCK)
				INNER JOIN IQArchive_MCMedia WITH (NOLOCK)
					ON IQArchive_MCMedia.ArchiveID = IQArchive_Media.ID
						AND IQArchive_MCMedia.IsActive = 1
			
				INNER JOIN CustomCategory
				ON	(
					CustomCategory.CategoryGUID = IQArchive_Media.CategoryGUID
					OR CustomCategory.CategoryGUID = IQArchive_Media.SubCategory1GUID
					OR CustomCategory.CategoryGUID = IQArchive_Media.SubCategory2GUID
					OR CustomCategory.CategoryGUID = IQArchive_Media.SubCategory3GUID
				)
			
				WHERE	IQArchive_Media.IsActive = 1
				AND		((@FromDate is null or @ToDate is null) OR IQArchive_Media.MediaDate BETWEEN @FromDate AND @ToDate) 
				AND		(@SearchTerm IS NULL OR (Content LIKE '%' + @SearchTerm + '%' OR Title LIKE '%' + @SearchTerm + '%'))
				AND		(@SubMediaType IS NULL OR v5SubMediaType = @SubMediaType)
				AND		(@SentimentFlag IS NULL 
						OR (@SentimentFlag = 0 AND ISNULL(NegativeSentiment, 0) = 0 AND ISNULL(PositiveSentiment, 0) = 0)
						OR (CASE @SentimentFlag
								WHEN 1 THEN PositiveSentiment

								WHEN -1 THEN NegativeSentiment
							END > 0)																					
						)
				AND		(SELECT ReportRule.exist('MediaResults/ID[text()=sql:column("IQArchive_Media.ID")]')	
							FROM IQ_Report WITH (NOLOCK)
							WHERE ReportGUID = @ReportGUID) = 1		
				GROUP BY CategoryName
				ORDER BY CategoryName
		END
		ELSE
		BEGIN
			SELECT							
						CategoryName,
						COUNT(IQArchive_Media.ID) AS CategoryCount
			FROM	
						IQArchive_Media WITH (NOLOCK)
						INNER JOIN IQArchive_MCMedia WITH (NOLOCK)
							ON IQArchive_MCMedia.ArchiveID = IQArchive_Media.ID
								AND IQArchive_MCMedia.IsActive = 1
						INNER JOIN CustomCategory
								
							ON (
								CustomCategory.CategoryGUID = IQArchive_Media.CategoryGUID
								OR CustomCategory.CategoryGUID = IQArchive_Media.SubCategory1GUID
								OR CustomCategory.CategoryGUID = IQArchive_Media.SubCategory2GUID
								OR CustomCategory.CategoryGUID = IQArchive_Media.SubCategory3GUID
							)
			
			WHERE		(
							IQArchive_Media.CategoryGUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
							OR IQArchive_Media.SubCategory1GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
							OR IQArchive_Media.SubCategory2GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
							OR IQArchive_Media.SubCategory3GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
						)
						AND		IQArchive_Media.IsActive = 1
						AND		((@FromDate is null or @ToDate is null) OR IQArchive_Media.MediaDate BETWEEN @FromDate AND @ToDate) 
						AND		(@SearchTerm IS NULL OR (Content LIKE '%' + @SearchTerm + '%' OR Title LIKE '%' + @SearchTerm + '%'))
						AND		(@SubMediaType IS NULL OR v5SubMediaType = @SubMediaType)
						AND		(@SentimentFlag IS NULL 
								OR (@SentimentFlag = 0 AND ISNULL(NegativeSentiment, 0) = 0 AND ISNULL(PositiveSentiment, 0) = 0)
								OR (CASE @SentimentFlag
										WHEN 1 THEN PositiveSentiment

										WHEN -1 THEN NegativeSentiment
									END > 0)																					
								)
						AND		(SELECT ReportRule.exist('MediaResults/ID[text()=sql:column("IQArchive_Media.ID")]')	
									FROM IQ_Report WITH (NOLOCK)
									WHERE ReportGUID = @ReportGUID) = 1
						AND (CASE WHEN  IQArchive_Media.CategoryGUID in (SELECT t1.CategoryGUID FROM @TempTable t1) THEN
								1
						ELSE
								0
						END + 
						CASE WHEN  IQArchive_Media.SubCategory1GUID in (SELECT t1.CategoryGUID FROM @TempTable t1) THEN
								1
						ELSE
								0
						END +
						CASE WHEN  IQArchive_Media.SubCategory2GUID in (SELECT t1.CategoryGUID FROM @TempTable t1) THEN
								1
						ELSE
								0
						END +
						CASE WHEN  IQArchive_Media.SubCategory3GUID in (SELECT t1.CategoryGUID FROM @TempTable t1) THEN
								1
						ELSE
								0 
						END) >= CASE WHEN @TotalCats < 4 THEN @TotalCats ELSE 4 END
						GROUP BY CategoryName
						ORDER BY CategoryName
		END
END


