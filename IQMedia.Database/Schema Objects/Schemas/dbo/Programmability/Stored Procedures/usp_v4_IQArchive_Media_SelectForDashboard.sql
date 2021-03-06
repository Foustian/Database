CREATE PROCEDURE [dbo].[usp_v4_IQArchive_Media_SelectForDashboard]
		@FromDate datetime,
		@ToDate datetime,
		@SubMediaType varchar(50),
		@SearchTerm	varchar(max),
		@CategoryGUID xml,
		@ClientGUID varchar(100),
		@CustomerGUID varchar(100),
		@IsRadioAccess bit,
		@SelectionType varchar(3),
		@SinceID bigint,
		@v4LibraryRollup bit,
		@IsOnlyParents bit
AS
BEGIN
	
	SET NOCOUNT ON;

	DECLARE @StopWatch datetime, @SPStartTime datetime,@SPTrackingID uniqueidentifier, @TimeDiff decimal(18,2),@SPName varchar(100),@QueryDetail varchar(500)
 
	Set @SPStartTime=GetDate()
	Set @Stopwatch=GetDate()
	SET @SPTrackingID = NEWID()
	SET @SPName ='usp_v4_IQArchive_Media_SelectForDashboard'   
	
	IF(@CategoryGUID IS NOT NULL)
	BEGIN
		DECLARE @TotalCats  int 					
		DECLARE @TempTable table(CategoryGuid uniqueidentifier)


		INSERT INTO @TempTable
		SELECT cat.item.value('@guid','uniqueidentifier') FROM @CategoryGUID.nodes('list/item') as cat(item)

		SELECT @TotalCats = count(*) FROM @TempTable as t		
	END

    CREATE TABLE #TempResults (ID BIGINT)
	Declare @tempChild table (ID BIGINT)
    
    -- Fill Temp table from IQArchive_Media table
    IF(@CategoryGUID IS NULL)
	BEGIN
		INSERT INTO #TempResults 
		SELECT * FROM 
					(
						SELECT	
								ID
						FROM	IQArchive_Media WITH (NOLOCK)
						WHERE	IsActive = 1
						AND		ClientGUID = @ClientGUID
						AND		(@IsRadioAccess = 1 OR MediaType != 'TM')
						AND		(@v4LibraryRollup = 0 OR _ParentID IS NULL)
						AND		(@CustomerGUID IS NULL OR CustomerGUID = @CustomerGUID)
						AND		((@FromDate IS NULL OR @ToDate IS NULL) OR IQArchive_Media.MediaDate BETWEEN @FromDate AND @ToDate) 
						AND		(@SearchTerm IS NULL OR (Content LIKE '%' + @SearchTerm + '%' OR Title LIKE '%' + @SearchTerm + '%'))
						AND		(@SubMediaType IS NULL OR SubMediaType = @SubMediaType)
					) AS T			
		Where ID <= @SinceID

		SET @QueryDetail ='populate #TempResults table from IQArchive_Media'
		SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
		INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
		SET @Stopwatch = GetDate()		

		IF(@v4LibraryRollup = 1 AND @IsOnlyParents = 0) begin
			INSERT INTO @tempChild
			SELECT 
					IQArchive_Media.ID
			FROM	
				#TempResults as tempParent
					Inner Join IQArchive_Media WITH (NOLOCK) 
						ON tempParent.ID = IQArchive_Media._ParentID
						AND IQArchive_Media.IsActive = 1
						AND ClientGUID = @ClientGUID
			WHERE
				(@IsRadioAccess = 1 OR IQArchive_Media.MediaType != 'TM')
				AND		(@CustomerGUID IS NULL OR IQArchive_Media.CustomerGUID = @CustomerGUID)
				AND		((@FromDate IS NULL OR @ToDate IS NULL) OR IQArchive_Media.MediaDate BETWEEN @FromDate AND @ToDate) 
				AND		(@SearchTerm IS NULL OR (IQArchive_Media.Content LIKE '%' + @SearchTerm + '%' OR IQArchive_Media.Title LIKE '%' + @SearchTerm + '%'))
				AND		(@SubMediaType IS NULL OR IQArchive_Media.SubMediaType = @SubMediaType)
				AND	IQArchive_Media.ID <= @SinceID

			SET @QueryDetail ='populate @tempChild table from #TempResults'
			SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
			INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
			SET @Stopwatch = GetDate()			
		end
	END 
	ELSE
	BEGIN
		IF(UPPER(@SelectionType) = 'AND')
		BEGIN

			INSERT INTO #TempResults
			SELECT * FROM 
						(
							SELECT	
									ID
							FROM	IQArchive_Media WITH (NOLOCK)
							WHERE	( IQArchive_Media.CategoryGUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
										OR IQArchive_Media.SubCategory1GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
										OR IQArchive_Media.SubCategory2GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
										OR IQArchive_Media.SubCategory3GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
									)
							AND IsActive = 1 
							AND		ClientGUID = @ClientGUID
							AND		(@v4LibraryRollup = 0 OR _ParentID IS NULL)
							AND		(@IsRadioAccess = 1 OR MediaType != 'TM')
							AND		(@CustomerGUID IS NULL OR CustomerGUID = @CustomerGUID)
							AND		((@FromDate IS NULL OR @ToDate IS NULL) OR IQArchive_Media.MediaDate BETWEEN @FromDate AND @ToDate) 
							AND		(@SearchTerm IS NULL OR (Content LIKE '%' + @SearchTerm + '%' OR Title LIKE '%' + @SearchTerm + '%'))
							AND		(@SubMediaType IS NULL OR SubMediaType = @SubMediaType)
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
									0 END
						) >= CASE WHEN @TotalCats < 4 THEN @TotalCats ELSE 4 END
						) AS T
			
			Where ID <= @SinceID

			SET @QueryDetail ='populate #TempResults table from IQArchive_Media'
			SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
			INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
			SET @Stopwatch = GetDate()		
			
			IF(@v4LibraryRollup = 1 AND @IsOnlyParents = 0) begin
				INSERT INTO @tempChild
			SELECT 
				IQArchive_Media.ID
			FROM	
				#TempResults as tempParent
					Inner Join IQArchive_Media WITH (NOLOCK) 
						ON tempParent.ID = IQArchive_Media._ParentID
						AND IQArchive_Media.IsActive = 1
						AND IQArchive_Media.ClientGUID = @ClientGUID
			WHERE	( IQArchive_Media.CategoryGUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
										OR IQArchive_Media.SubCategory1GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
										OR IQArchive_Media.SubCategory2GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
										OR IQArchive_Media.SubCategory3GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
									)
							AND IQArchive_Media.IsActive = 1 
							AND		IQArchive_Media.ClientGUID = @ClientGUID
							AND		(@IsRadioAccess = 1 OR IQArchive_Media.MediaType != 'TM')
							AND		(@CustomerGUID IS NULL OR IQArchive_Media.CustomerGUID = @CustomerGUID)
							AND		((@FromDate IS NULL OR @ToDate IS NULL) OR IQArchive_Media.MediaDate BETWEEN @FromDate AND @ToDate) 
							AND		(@SearchTerm IS NULL OR (IQArchive_Media.Content LIKE '%' + @SearchTerm + '%' OR IQArchive_Media.Title LIKE '%' + @SearchTerm + '%'))
							AND		(@SubMediaType IS NULL OR IQArchive_Media.SubMediaType = @SubMediaType)
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
									0 END
						) >= CASE WHEN @TotalCats < 4 THEN @TotalCats ELSE 4 END
						AND	IQArchive_Media.ID <= @SinceID

				SET @QueryDetail ='populate @tempChild table from #TempResults'
			SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
			INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
			SET @Stopwatch = GetDate()	

			end
		END
		ELSE
		BEGIN
			INSERT INTO #TempResults
			SELECT * FROM 
						(
							SELECT	
									ID
							FROM	IQArchive_Media WITH (NOLOCK)
							WHERE
								(
									IQArchive_Media.CategoryGUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
										OR IQArchive_Media.SubCategory1GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
										OR IQArchive_Media.SubCategory2GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
										OR IQArchive_Media.SubCategory3GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
								)			
							AND		IsActive = 1
							AND		ClientGUID = @ClientGUID
							AND		(@v4LibraryRollup = 0 OR _ParentID IS NULL)
							AND		(@IsRadioAccess = 1 OR MediaType != 'TM')
							AND		(@CustomerGUID IS NULL OR CustomerGUID = @CustomerGUID)
							AND		((@FromDate IS NULL OR @ToDate IS NULL) OR IQArchive_Media.MediaDate BETWEEN @FromDate AND @ToDate) 
							AND		(@SearchTerm IS NULL OR (Content LIKE '%' + @SearchTerm + '%' OR Title LIKE '%' + @SearchTerm + '%'))
							AND		(@SubMediaType IS NULL OR SubMediaType = @SubMediaType)
						) AS T
			
			Where ID <= @SinceID

			SET @QueryDetail ='populate #TempResults table from IQArchive_Media'
			SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
			INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
			SET @Stopwatch = GetDate()		
			
			IF(@v4LibraryRollup = 1 AND @IsOnlyParents = 0) begin
				INSERT INTO @tempChild
			SELECT 
				IQArchive_Media.ID
			FROM	
				#TempResults as tempParent
					Inner Join IQArchive_Media WITH (NOLOCK) 
						ON tempParent.ID = IQArchive_Media._ParentID
						AND IQArchive_Media.IsActive = 1
						AND ClientGUID = @ClientGUID
			WHERE
				(
					IQArchive_Media.CategoryGUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
						OR IQArchive_Media.SubCategory1GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
						OR IQArchive_Media.SubCategory2GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
						OR IQArchive_Media.SubCategory3GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
				)			
				AND		IQArchive_Media.IsActive = 1
				AND		IQArchive_Media.ClientGUID = @ClientGUID
				AND		(@IsRadioAccess = 1 OR IQArchive_Media.MediaType != 'TM')
				AND		(@CustomerGUID IS NULL OR IQArchive_Media.CustomerGUID = @CustomerGUID)
				AND		((@FromDate IS NULL OR @ToDate IS NULL) OR IQArchive_Media.MediaDate BETWEEN @FromDate AND @ToDate) 
				AND		(@SearchTerm IS NULL OR (IQArchive_Media.Content LIKE '%' + @SearchTerm + '%' OR IQArchive_Media.Title LIKE '%' + @SearchTerm + '%'))
				AND		(@SubMediaType IS NULL OR IQArchive_Media.SubMediaType = @SubMediaType)
				AND	IQArchive_Media.ID <= @SinceID

				SET @QueryDetail ='populate @tempChild table from #TempResults'
			SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
			INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
			SET @Stopwatch = GetDate()	
			end
		END
	END

	SELECT ID FROM #TempResults
	UNION
	SELECT ID FROM @tempChild
	order by ID	

	SET @QueryDetail ='0'
	SET @TimeDiff = DateDiff(ms, @SPStartTime, GetDate())
	INSERT INTO IQ_SPTimeTracking([Guid],SPName,Input,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,'<Input><ClientGUID>'+ convert(nvarchar(max),@ClientGUID) +'</ClientGUID><FromDate>'+ convert(nvarchar(max),@FromDate) +'</FromDate><ToDate>'+ convert(nvarchar(max),@ToDate) +'</ToDate><SubMediaType>'+ convert(nvarchar(max),@SubMediaType) +'</SubMediaType><SearchTerm>'+ convert(nvarchar(max),@SearchTerm) +'</SearchTerm><IsRadioAccess>'+ convert(nvarchar(max),@IsRadioAccess) +'</IsRadioAccess><SinceID>'+ convert(nvarchar(max),@SinceID) +'</SinceID><SelectionType>'+ convert(nvarchar(max),@SelectionType) +'</SelectionType><v4LibraryRollup>'+ convert(nvarchar(max),@v4LibraryRollup) +'</v4LibraryRollup><CategoryGUID>'+ convert(nvarchar(max),@CategoryGUID) +'</CategoryGUID><CustomerGUID>'+ convert(nvarchar(max),@CustomerGUID) +'</CustomerGUID></Input>',@QueryDetail,@TimeDiff)
END