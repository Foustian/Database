CREATE PROCEDURE [dbo].[usp_v5_IQArchive_MCMedia_SelectCategoryFilter]
	@FromDate			datetime,
	@ToDate				datetime,
	@SubMediaType		varchar(50),
	@SearchTerm			varchar(max),
	@CategoryGUID		xml,
	@ClientGUID			varchar(100),
	@CustomerGUID		varchar(100),
	@SinceID			bigint,
	@MasterClientID		int,
	@ReportGUID			varchar(100)
AS
BEGIN
		DECLARE @TotalCats  int 					
		DECLARE @TempTable table(CategoryGuid uniqueidentifier)

		-- Get the master client
		DECLARE @MasterClientGUID uniqueidentifier = null
		IF @MasterClientID IS NOT NULL
		  BEGIN
			SELECT @MasterClientGUID = ClientGUID FROM Client WHERE ClientKey = @MasterClientID AND ClientGUID != @ClientGUID

			-- If MasterClientGUID is null, then the current client is the master
			IF @MasterClientGUID IS NULL
			  BEGIN
				SET @MasterClientGUID = @ClientGUID
			  END
		  END		  

		INSERT INTO @TempTable
		SELECT cat.item.value('@guid','uniqueidentifier') FROM @CategoryGUID.nodes('list/item') as cat(item)

		SELECT @TotalCats = count(*) FROM @TempTable as t
		IF(@CategoryGUID IS NULL)
		BEGIN
				SELECT	
						CustomCategory.CategoryGUID,
						CategoryName,
						COUNT(IQArchive_Media.ID) AS CategoryCount
				FROM	IQArchive_Media WITH (NOLOCK)
				INNER JOIN IQArchive_MCMedia WITH (NOLOCK)
					ON IQArchive_MCMedia.ArchiveID = IQArchive_Media.ID
						AND (@MasterClientGUID IS NULL OR IQArchive_MCMedia.MasterClientGUID = @MasterClientGUID)
						AND IQArchive_MCMedia.IsActive = 1
			
				INNER JOIN CustomCategory
				ON	(
					CustomCategory.CategoryGUID = IQArchive_Media.CategoryGUID
					OR CustomCategory.CategoryGUID = IQArchive_Media.SubCategory1GUID
					OR CustomCategory.CategoryGUID = IQArchive_Media.SubCategory2GUID
					OR CustomCategory.CategoryGUID = IQArchive_Media.SubCategory3GUID
				)
			
				WHERE	IQArchive_Media.IsActive = 1
				AND		(@ClientGUID IS NULL OR @MasterClientGUID = @ClientGUID OR IQArchive_Media.ClientGUID = @ClientGUID)
				AND		(IQArchive_MCMedia.ID <= @SinceID OR @SinceID = 0)
				AND		(@CustomerGUID IS NULL OR IQArchive_Media.CustomerGUID = @CustomerGUID)
				AND		((@FromDate is null or @ToDate is null) OR IQArchive_Media.MediaDate BETWEEN @FromDate AND @ToDate) 
				AND		(@SearchTerm IS NULL OR (Content LIKE '%' + @SearchTerm + '%' OR Title LIKE '%' + @SearchTerm + '%'))
				AND		(@SubMediaType IS NULL OR v5SubMediaType = @SubMediaType)
				AND		(@ReportGuid IS NULL OR
							(SELECT ReportRule.exist('MediaResults/ID[text()=sql:column("IQArchive_Media.ID")]')	
							 FROM	IQ_Report WITH (NOLOCK)
							 WHERE	ReportGUID = @ReportGUID) = 1)		
				GROUP BY CustomCategory.CategoryGUID,CategoryName
				ORDER BY CategoryName
		END
		ELSE
		BEGIN
			SELECT							
						CustomCategory.CategoryGUID,
						CategoryName,
						COUNT(IQArchive_Media.ID) AS CategoryCount
			FROM	
						IQArchive_Media WITH (NOLOCK)
						INNER JOIN IQArchive_MCMedia WITH (NOLOCK)
							ON IQArchive_MCMedia.ArchiveID = IQArchive_Media.ID
								AND (@MasterClientGUID IS NULL OR IQArchive_MCMedia.MasterClientGUID = @MasterClientGUID)
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
						AND		(@ClientGUID IS NULL OR @MasterClientGUID = @ClientGUID OR IQArchive_Media.ClientGUID = @ClientGUID)
						AND		IQArchive_Media.IsActive = 1
						AND		(IQArchive_MCMedia.ID <= @SinceID OR @SinceID = 0)
						AND		(@CustomerGUID IS NULL OR IQArchive_Media.CustomerGUID = @CustomerGUID)
						AND		((@FromDate is null or @ToDate is null) OR IQArchive_Media.MediaDate BETWEEN @FromDate AND @ToDate) 
						AND		(@SearchTerm IS NULL OR (Content LIKE '%' + @SearchTerm + '%' OR Title LIKE '%' + @SearchTerm + '%'))
						AND		(@SubMediaType IS NULL OR v5SubMediaType = @SubMediaType)
						AND		(@ReportGuid IS NULL OR
									(SELECT ReportRule.exist('MediaResults/ID[text()=sql:column("IQArchive_Media.ID")]')	
									 FROM	IQ_Report WITH (NOLOCK)
									 WHERE	ReportGUID = @ReportGUID) = 1)
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
