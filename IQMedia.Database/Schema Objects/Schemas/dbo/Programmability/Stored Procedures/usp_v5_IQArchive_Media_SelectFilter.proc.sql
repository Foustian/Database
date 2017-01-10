USE [IQMediaGroup]
GO

/****** Object:  StoredProcedure [dbo].[usp_v4_IQArchive_Media_SelectFilter]    Script Date: 11/10/2015 10:28:10 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






-- =============================================
-- Author:		<Author,,Name>
-- Create date: 13 June 2013
-- Description:	Returns all the filters for IQArchive_Media
-- =============================================
ALTER PROCEDURE [dbo].[usp_v5_IQArchive_Media_SelectFilter]

	@FromDate			datetime,
	@ToDate				datetime,
	@SubMediaType		varchar(50),
	@SearchTerm			varchar(max),
	@CategoryGUID		xml,
	@ClientGUID			varchar(100),
	@CustomerGUID		varchar(100),
	@SelectionType		varchar(3),
	@SinceID			bigint
AS
BEGIN
	
	SET NOCOUNT ON;

	DECLARE @StopWatch datetime, @SPStartTime datetime,@SPTrackingID uniqueidentifier, @TimeDiff decimal(18,2),@SPName varchar(100),@QueryDetail varchar(500)
 
	Set @SPStartTime=GetDate()
	Set @Stopwatch=GetDate()
	SET @SPTrackingID = NEWID()
	SET @SPName ='usp_v5_IQArchive_Media_SelectFilter'   

			IF(@CategoryGUID IS NULL)
			BEGIN
				-- MediaDate Count Filter
				SELECT	
						DISTINCT CAST(MediaDate AS DATE) AS MediaDate
				FROM	IQArchive_Media WITH (NOLOCK)
			
				WHERE	IQArchive_Media.IsActive = 1
				AND		ClientGUID = @ClientGUID
				AND		ID <= @SinceID
				AND		(@CustomerGUID IS NULL OR IQArchive_Media.CustomerGUID = @CustomerGUID)
				AND		((@FromDate is null or @ToDate is null) OR IQArchive_Media.MediaDate BETWEEN @FromDate AND @ToDate) 
				AND		(@SearchTerm IS NULL OR (Content LIKE '%' + @SearchTerm + '%' OR Title LIKE '%' + @SearchTerm + '%'))
				AND		(@SubMediaType IS NULL OR v5SubMediaType = @SubMediaType)
				order by MediaDate

		SET @QueryDetail ='get date filter'
		SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
		INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
		SET @Stopwatch = GetDate()	
		    
				-- SubMediaType Count Filter
				SELECT	
						TblMediaTypes.MediaType,
						TblMediaTypes.DisplayName as MediaTypeDesc,
						TblMediaTypes.HasSubMediaTypes,
						TblSubMediaTypes.SubMediaType,
						TblSubMediaTypes.DisplayName as SubMediaTypeDesc,
						COUNT(IQArchive_Media.ID) AS SubMediaTypeCount
				FROM	IQArchive_Media WITH (NOLOCK)
				INNER	JOIN IQ_MediaTypes as TblSubMediaTypes
						ON TblSubMediaTypes.SubMediaType = IQArchive_Media.v5SubMediaType
				INNER	JOIN IQ_MediaTypes as TblMediaTypes
						ON TblSubMediaTypes.MediaType = TblMediaTypes.MediaType
						AND TblMediaTypes.TypeLevel = 1
			
				WHERE	IQArchive_Media.IsActive = 1
				AND		ClientGUID = @ClientGUID
				AND		IQArchive_Media.ID <= @SinceID
				AND		(@CustomerGUID IS NULL OR IQArchive_Media.CustomerGUID = @CustomerGUID)
				AND		((@FromDate is null or @ToDate is null) OR IQArchive_Media.MediaDate BETWEEN @FromDate AND @ToDate) 
				AND		(@SearchTerm IS NULL OR (Content LIKE '%' + @SearchTerm + '%' OR Title LIKE '%' + @SearchTerm + '%'))
				AND		(@SubMediaType IS NULL OR v5SubMediaType = @SubMediaType)
				GROUP BY TblMediaTypes.MediaType, TblMediaTypes.DisplayName, TblMediaTypes.SortOrder, TblMediaTypes.HasSubMediaTypes, 
							TblSubMediaTypes.SubMediaType, TblSubMediaTypes.DisplayName, TblSubMediaTypes.SortOrder
				order by TblMediaTypes.SortOrder, TblSubMediaTypes.SortOrder

		SET @QueryDetail ='get submedia type filter'
		SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
		INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
		SET @Stopwatch = GetDate()	
		    
				-- Customer Count Filter
				SELECT	
						IQArchive_Media.CustomerGUID,
						Customer.FirstName + ' ' + Customer.LastName AS CustomerName,
						COUNT(ID) AS CustomerCount
				FROM	IQArchive_Media WITH (NOLOCK)
			
				INNER JOIN Customer  WITH (NOLOCK)
				ON Customer.CustomerGUID = IQArchive_Media.CustomerGUID
			
				WHERE	IQArchive_Media.IsActive = 1			
				AND		ClientGUID = @ClientGUID
				AND		ID <= @SinceID
				AND		(@CustomerGUID IS NULL OR IQArchive_Media.CustomerGUID = @CustomerGUID)
				AND		((@FromDate is null or @ToDate is null) OR IQArchive_Media.MediaDate BETWEEN @FromDate AND @ToDate) 
				AND		(@SearchTerm IS NULL OR (Content LIKE '%' + @SearchTerm + '%' OR Title LIKE '%' + @SearchTerm + '%'))
				AND		(@SubMediaType IS NULL OR v5SubMediaType = @SubMediaType)
				GROUP BY IQArchive_Media.CustomerGUID,Customer.FirstName + ' ' + Customer.LastName
				ORDER BY Customer.FirstName + ' ' + Customer.LastName

		SET @QueryDetail ='get customer filter'
		SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
		INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
		SET @Stopwatch = GetDate()	
		    
				-- CustomCategory Count Filter
				SELECT	
						CustomCategory.CategoryGUID,
						CategoryName,
						COUNT(ID) AS CategoryCount
				FROM	IQArchive_Media WITH (NOLOCK)
			
				INNER JOIN CustomCategory  WITH (NOLOCK)
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

		SET @QueryDetail ='get category filter CatGUID is NULL '  + convert(varchar(100),@ClientGUID)
		SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
		INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
		SET @Stopwatch = GetDate()	
		   
		END
		ELSE
		BEGIN

			DECLARE @TotalCats  int 					
			DECLARE @TempTable table(CategoryGuid uniqueidentifier)


			INSERT INTO @TempTable
			SELECT cat.item.value('@guid','uniqueidentifier') FROM @CategoryGUID.nodes('list/item') as cat(item)

			SELECT @TotalCats = count(*) FROM @TempTable as t


			IF(UPPER(@SelectionType) = 'AND')
			BEGIN
				-- MediaDate Count Filter
				SELECT	
						DISTINCT CAST(MediaDate AS DATE) AS MediaDate
				FROM	IQArchive_Media WITH (NOLOCK)
				WHERE	(
							IQArchive_Media.CategoryGUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
							OR IQArchive_Media.SubCategory1GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
							OR IQArchive_Media.SubCategory2GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
							OR IQArchive_Media.SubCategory3GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
						)
				AND		IQArchive_Media.IsActive = 1
				AND		ClientGUID = @ClientGUID
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
				order by MediaDate

			SET @QueryDetail ='get date filter'
		SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
		INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
		SET @Stopwatch = GetDate()	
		    
				-- SubMediaType Count Filter
				SELECT	
						TblMediaTypes.MediaType,
						TblMediaTypes.DisplayName as MediaTypeDesc,
						TblMediaTypes.HasSubMediaTypes,
						TblSubMediaTypes.SubMediaType,
						TblSubMediaTypes.DisplayName as SubMediaTypeDesc,
						COUNT(IQArchive_Media.ID) AS SubMediaTypeCount
				FROM	IQArchive_Media WITH (NOLOCK)
				INNER	JOIN IQ_MediaTypes as TblSubMediaTypes
						ON TblSubMediaTypes.SubMediaType = IQArchive_Media.v5SubMediaType
				INNER	JOIN IQ_MediaTypes as TblMediaTypes
						ON TblSubMediaTypes.MediaType = TblMediaTypes.MediaType
						AND TblMediaTypes.TypeLevel = 1	
				WHERE	(
							IQArchive_Media.CategoryGUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
							OR IQArchive_Media.SubCategory1GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
							OR IQArchive_Media.SubCategory2GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
							OR IQArchive_Media.SubCategory3GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
						)
				AND		IQArchive_Media.IsActive = 1
				AND		ClientGUID = @ClientGUID
				AND		IQArchive_Media.ID <= @SinceID
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
				GROUP BY TblMediaTypes.MediaType, TblMediaTypes.DisplayName, TblMediaTypes.SortOrder, TblMediaTypes.HasSubMediaTypes, 
							TblSubMediaTypes.SubMediaType, TblSubMediaTypes.DisplayName, TblSubMediaTypes.SortOrder
				order by TblMediaTypes.SortOrder, TblSubMediaTypes.SortOrder
		    
			SET @QueryDetail ='get submedia type filter'
		SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
		INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
		SET @Stopwatch = GetDate()	

				-- Customer Count Filter
				SELECT	
						IQArchive_Media.CustomerGUID,
						Customer.FirstName + ' ' + Customer.LastName AS CustomerName,
						COUNT(ID) AS CustomerCount
				FROM	IQArchive_Media WITH (NOLOCK)
							INNER JOIN Customer
								ON Customer.CustomerGUID = IQArchive_Media.CustomerGUID
			
				WHERE	(
							IQArchive_Media.CategoryGUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
							OR IQArchive_Media.SubCategory1GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
							OR IQArchive_Media.SubCategory2GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
							OR IQArchive_Media.SubCategory3GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
						)
				AND		IQArchive_Media.IsActive = 1
				AND		ClientGUID = @ClientGUID
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
				GROUP BY IQArchive_Media.CustomerGUID,Customer.FirstName + ' ' + Customer.LastName
				ORDER BY Customer.FirstName + ' ' + Customer.LastName


		SET @QueryDetail ='get customer filter'
		SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
		INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
		SET @Stopwatch = GetDate()	
		    
				-- CustomCategory Count Filter
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

		SET @QueryDetail ='get category filter SelectionType = AND'
		SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
		INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
		SET @Stopwatch = GetDate()

			END
			ELSE
			BEGIN
				-- MediaDate Count Filter
				SELECT	
						DISTINCT CAST(MediaDate AS DATE) AS MediaDate
				FROM	IQArchive_Media WITH (NOLOCK)
				WHERE	(
							IQArchive_Media.CategoryGUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
							OR IQArchive_Media.SubCategory1GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
							OR IQArchive_Media.SubCategory2GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
							OR IQArchive_Media.SubCategory3GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
						)
				AND		IQArchive_Media.IsActive = 1
				AND		ClientGUID = @ClientGUID
				AND		ID <= @SinceID
				AND		(@CustomerGUID IS NULL OR IQArchive_Media.CustomerGUID = @CustomerGUID)
				AND		((@FromDate is null or @ToDate is null) OR IQArchive_Media.MediaDate BETWEEN @FromDate AND @ToDate) 
				AND		(@SearchTerm IS NULL OR (Content LIKE '%' + @SearchTerm + '%' OR Title LIKE '%' + @SearchTerm + '%'))
				AND		(@SubMediaType IS NULL OR v5SubMediaType = @SubMediaType)
				order by MediaDate

				SET @QueryDetail ='get date filter'
		SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
		INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
		SET @Stopwatch = GetDate()	
		    
				-- SubMediaType Count Filter
				SELECT	
						TblMediaTypes.MediaType,
						TblMediaTypes.DisplayName as MediaTypeDesc,
						TblMediaTypes.HasSubMediaTypes,
						TblSubMediaTypes.SubMediaType,
						TblSubMediaTypes.DisplayName as SubMediaTypeDesc,
						COUNT(IQArchive_Media.ID) AS SubMediaTypeCount
				FROM	IQArchive_Media WITH (NOLOCK)
				INNER	JOIN IQ_MediaTypes as TblSubMediaTypes
						ON TblSubMediaTypes.SubMediaType = IQArchive_Media.v5SubMediaType
				INNER	JOIN IQ_MediaTypes as TblMediaTypes
						ON TblSubMediaTypes.MediaType = TblMediaTypes.MediaType
						AND TblMediaTypes.TypeLevel = 1		
				WHERE	(
							IQArchive_Media.CategoryGUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
							OR IQArchive_Media.SubCategory1GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
							OR IQArchive_Media.SubCategory2GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
							OR IQArchive_Media.SubCategory3GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
						)
				AND		IQArchive_Media.IsActive = 1
				AND		ClientGUID = @ClientGUID
				AND		IQArchive_Media.ID <= @SinceID
				AND		(@CustomerGUID IS NULL OR IQArchive_Media.CustomerGUID = @CustomerGUID)
				AND		((@FromDate is null or @ToDate is null) OR IQArchive_Media.MediaDate BETWEEN @FromDate AND @ToDate) 
				AND		(@SearchTerm IS NULL OR (Content LIKE '%' + @SearchTerm + '%' OR Title LIKE '%' + @SearchTerm + '%'))
				AND		(@SubMediaType IS NULL OR v5SubMediaType = @SubMediaType)
				GROUP BY TblMediaTypes.MediaType, TblMediaTypes.DisplayName, TblMediaTypes.SortOrder, TblMediaTypes.HasSubMediaTypes, 
							TblSubMediaTypes.SubMediaType, TblSubMediaTypes.DisplayName, TblSubMediaTypes.SortOrder
				order by TblMediaTypes.SortOrder, TblSubMediaTypes.SortOrder

				SET @QueryDetail ='get submedia type filter'
		SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
		INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
		SET @Stopwatch = GetDate()	
		    
				-- Customer Count Filter
				SELECT	
						IQArchive_Media.CustomerGUID,
						Customer.FirstName + ' ' + Customer.LastName AS CustomerName,
						COUNT(ID) AS CustomerCount
				FROM	IQArchive_Media WITH (NOLOCK)
						INNER JOIN Customer
							ON Customer.CustomerGUID = IQArchive_Media.CustomerGUID
			
				WHERE	(
							IQArchive_Media.CategoryGUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
							OR IQArchive_Media.SubCategory1GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
							OR IQArchive_Media.SubCategory2GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
							OR IQArchive_Media.SubCategory3GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
						)
				AND		IQArchive_Media.IsActive = 1			
				AND		ClientGUID = @ClientGUID
				AND		ID <= @SinceID
				AND		(@CustomerGUID IS NULL OR IQArchive_Media.CustomerGUID = @CustomerGUID)
				AND		((@FromDate is null or @ToDate is null) OR IQArchive_Media.MediaDate BETWEEN @FromDate AND @ToDate) 
				AND		(@SearchTerm IS NULL OR (Content LIKE '%' + @SearchTerm + '%' OR Title LIKE '%' + @SearchTerm + '%'))
				AND		(@SubMediaType IS NULL OR v5SubMediaType = @SubMediaType)
				GROUP BY IQArchive_Media.CustomerGUID,Customer.FirstName + ' ' + Customer.LastName
				ORDER BY Customer.FirstName + ' ' + Customer.LastName
		    
			SET @QueryDetail ='get customer filter'
		SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
		INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
		SET @Stopwatch = GetDate()	

				-- CustomCategory Count Filter
				SELECT	
						CustomCategory.CategoryGUID,
						CategoryName,
						COUNT(ID) AS CategoryCount
				FROM	IQArchive_Media WITH (NOLOCK)
							INNER JOIN CustomCategory
								ON	CustomCategory.CategoryGUID IN (SELECT t1.CategoryGUID FROM @TempTable t1)
								AND (
									CustomCategory.CategoryGUID = IQArchive_Media.CategoryGUID
									OR CustomCategory.CategoryGUID = IQArchive_Media.SubCategory1GUID
									OR CustomCategory.CategoryGUID = IQArchive_Media.SubCategory2GUID
									OR CustomCategory.CategoryGUID = IQArchive_Media.SubCategory3GUID
								)
								AND	CustomCategory.ClientGUID = @ClientGUID
			
				WHERE	(
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
				GROUP BY CustomCategory.CategoryGUID,CategoryName
				ORDER BY CategoryName

				SET @QueryDetail ='get category filter'
		SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
		INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
		SET @Stopwatch = GetDate()
			END
		END
    
	SET @QueryDetail ='0'
	SET @TimeDiff = DateDiff(ms, @SPStartTime, GetDate())
	INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)

	/*
	INSERT INTO IQ_SPTimeTracking([Guid],SPName,Input,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,'<Input><ClientGUID>'+ convert(nvarchar(max),@ClientGUID) +'</ClientGUID><FromDate>'+ convert(nvarchar(max),@FromDate) +'</FromDate><ToDate>'+ convert(nvarchar(max),@ToDate) +'</ToDate><SubMediaType>'+ convert(nvarchar(max),@SubMediaType) +'</SubMediaType><SearchTerm>'+ convert(nvarchar(max),@SearchTerm) +'</SearchTerm><SinceID>'+ convert(nvarchar(max),@SinceID) +'</SinceID><SelectionType>'+ convert(nvarchar(max),@SelectionType) +'</SelectionType><CategoryGUID>'+ convert(nvarchar(max),@CategoryGUID) +'</CategoryGUID><CustomerGUID>'+ convert(nvarchar(max),@CustomerGUID) +'</CustomerGUID></Input>',@QueryDetail,@TimeDiff)
	*/
END




