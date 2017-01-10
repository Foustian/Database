CREATE PROCEDURE [dbo].[usp_v5_IQArchive_Media_SelectCategoryFilter]
	@FromDate			datetime,
	@ToDate				datetime,
	@SubMediaType		varchar(50),
	@SearchTerm			varchar(max),
	@CategoryGUID		xml,
	@ClientGUID			varchar(100),
	@CustomerGUID		varchar(100),
	@SinceID			bigint
AS
BEGIN
		DECLARE @TotalCats  int 					
		DECLARE @TempTable table(CategoryGuid uniqueidentifier)


		INSERT INTO @TempTable
		SELECT cat.item.value('@guid','uniqueidentifier') FROM @CategoryGUID.nodes('list/item') as cat(item)

		SELECT @TotalCats = count(*) FROM @TempTable as t
		IF(@CategoryGUID IS NULL)
		BEGIN
				SELECT	
						CustomCategory.CategoryGUID,
						CategoryName,
						COUNT(ID) AS CategoryCount
				FROM	IQArchive_Media WITH (NOLOCK)
			
				INNER JOIN CustomCategory
				ON	(
					CustomCategory.CategoryGUID = IQArchive_Media.CategoryGUID
					OR CustomCategory.CategoryGUID = IQArchive_Media.SubCategory1GUID
					OR CustomCategory.CategoryGUID = IQArchive_Media.SubCategory2GUID
					OR CustomCategory.CategoryGUID = IQArchive_Media.SubCategory3GUID
				)
				AND	CustomCategory.ClientGUID = @ClientGUID
			
				WHERE	IQArchive_Media.IsActive = 1
				AND		IQArchive_Media.ClientGUID = @ClientGUID
				AND		ID <= @SinceID
				AND		(@CustomerGUID IS NULL OR IQArchive_Media.CustomerGUID = @CustomerGUID)
				AND		((@FromDate is null or @ToDate is null) OR IQArchive_Media.MediaDate BETWEEN @FromDate AND @ToDate) 
				AND		(@SearchTerm IS NULL OR (Content LIKE '%' + @SearchTerm + '%' OR Title LIKE '%' + @SearchTerm + '%'))
				AND		(@SubMediaType IS NULL OR v5SubMediaType = @SubMediaType)
				GROUP BY CustomCategory.CategoryGUID,CategoryName
				ORDER BY CategoryName
		END
		ELSE
		BEGIN
			SELECT							
						CustomCategory.CategoryGUID,
						CategoryName,
						COUNT(ID) AS CategoryCount
			FROM	
						IQArchive_Media WITH (NOLOCK)
							INNER JOIN CustomCategory
								
								ON (
									CustomCategory.CategoryGUID = IQArchive_Media.CategoryGUID
									OR CustomCategory.CategoryGUID = IQArchive_Media.SubCategory1GUID
									OR CustomCategory.CategoryGUID = IQArchive_Media.SubCategory2GUID
									OR CustomCategory.CategoryGUID = IQArchive_Media.SubCategory3GUID
								)
								AND	CustomCategory.ClientGUID = @ClientGUID
			
			WHERE		(
							IQArchive_Media.CategoryGUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
							OR IQArchive_Media.SubCategory1GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
							OR IQArchive_Media.SubCategory2GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
							OR IQArchive_Media.SubCategory3GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
						)
						AND		IQArchive_Media.IsActive = 1
						AND		IQArchive_Media.ClientGUID = @ClientGUID
						AND		ID <= @SinceID
						AND		(@CustomerGUID IS NULL OR IQArchive_Media.CustomerGUID = @CustomerGUID)
						AND		((@FromDate is null or @ToDate is null) OR IQArchive_Media.MediaDate BETWEEN @FromDate AND @ToDate) 
						AND		(@SearchTerm IS NULL OR (Content LIKE '%' + @SearchTerm + '%' OR Title LIKE '%' + @SearchTerm + '%'))
						AND		(@SubMediaType IS NULL OR v5SubMediaType = @SubMediaType)
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
						GROUP BY CustomCategory.CategoryGUID,CategoryName
						ORDER BY CategoryName
		END
END