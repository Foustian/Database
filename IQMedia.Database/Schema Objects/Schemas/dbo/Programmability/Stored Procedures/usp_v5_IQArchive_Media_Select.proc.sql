CREATE PROCEDURE [dbo].[usp_v5_IQArchive_Media_Select]
		@FromRecordID bigint,
		@PageSize int,
		@FromDate datetime,
		@ToDate datetime,
		@SubMediaType	varchar(50),
		@SearchTerm	varchar(max),
		@CategoryGUID	xml,
		@ClientGUID varchar(100),
		@CustomerGUID varchar(100),
		@IsAsc bit,
		@SortColumn varchar(50),
		@IsEnableFilter	bit,
		@SelectionType		varchar(3),
		@SinceID bigint output,
		@TotalResults bigint output,
		@TotalResultsDisplay bigint output,
		@v4LibraryRollup bit
AS
BEGIN
	
	SET NOCOUNT ON;

	DECLARE @StopWatch datetime, @SPStartTime datetime,@SPTrackingID uniqueidentifier, @TimeDiff decimal(18,2),@SPName varchar(100),@QueryDetail varchar(500)
 
	Set @SPStartTime=GetDate()
	Set @Stopwatch=GetDate()
	SET @SPTrackingID = NEWID()
	SET @SPName ='usp_v5_IQArchive_Media_Select'   

	DECLARE @ChildRecordsCount bigint= 0

	DECLARE @MultiPlier float
	select @MultiPlier = CONVERT(float,ISNULL((select Value from IQClient_CustomSettings where Field = 'Multiplier' and _ClientGuid = @ClientGUID),(select Value from IQClient_CustomSettings where Field = 'Multiplier' and _ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER))))
	
	IF(@CategoryGUID IS NULL)
	BEGIN
		SELECT	@SinceID = CASE WHEN (@SinceID IS NULL OR @SinceID=0) THEN MAX(ID) ELSE @SinceID END,
				@TotalResultsDisplay = COUNT(ID)
		FROM	IQArchive_Media WITH (NOLOCK)
		WHERE	IsActive = 1
		AND		ClientGUID = @ClientGUID
		AND		((@SinceID IS NULL OR @SinceID = 0) OR ID <= @SinceID )
		AND		(@CustomerGUID IS NULL OR CustomerGUID = @CustomerGUID)
		AND		((@FromDate is null or @ToDate is null) OR IQArchive_Media.MediaDate BETWEEN @FromDate AND @ToDate) 
		AND		(@SearchTerm IS NULL OR (Content LIKE '%' + @SearchTerm + '%' OR Title LIKE '%' + @SearchTerm + '%'))
		AND		(@SubMediaType IS NULL OR v5SubMediaType = @SubMediaType)

		SET @QueryDetail ='get since id and total results display'
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

			SELECT	@SinceID = CASE WHEN (@SinceID IS NULL OR @SinceID=0) THEN MAX(ID) ELSE @SinceID END,
					@TotalResultsDisplay = COUNT(ID)
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
			AND		((@SinceID IS NULL OR @SinceID = 0) OR ID <= @SinceID )
			AND		(@CustomerGUID IS NULL OR CustomerGUID = @CustomerGUID)
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
							0 END
				) >= CASE WHEN @TotalCats < 4 THEN @TotalCats ELSE 4 END

			SET @QueryDetail ='get since id and total results display'
			SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
			INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
			SET @Stopwatch = GetDate()		

		END
		ELSE
		BEGIN
			SELECT	@SinceID = CASE WHEN (@SinceID IS NULL OR @SinceID=0) THEN MAX(ID) ELSE @SinceID END,
					@TotalResultsDisplay = COUNT(ID)
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
			AND		((@SinceID IS NULL OR @SinceID = 0) OR ID <= @SinceID )
			AND		(@CustomerGUID IS NULL OR CustomerGUID = @CustomerGUID)
			AND		((@FromDate is null or @ToDate is null) OR IQArchive_Media.MediaDate BETWEEN @FromDate AND @ToDate) 
			AND		(@SearchTerm IS NULL OR (Content LIKE '%' + @SearchTerm + '%' OR Title LIKE '%' + @SearchTerm + '%'))
			AND		(@SubMediaType IS NULL OR v5SubMediaType = @SubMediaType)

			SET @QueryDetail ='get since id and total results display'
			SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
			INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
			SET @Stopwatch = GetDate()		
		END
	END

	

    CREATE TABLE #TempResults 
    (
		RowNo				BIGINT,
		ID					BIGINT,
		_ArchiveMediaID		BIGINT,
		MediaType			VARCHAR(2),
		HighlightingText	NVARCHAR(MAX),
		Content				NVARCHAR(MAX),
		MediaDate			DATETIME,
		Title				NVARCHAR(MAX),
		SubMediaType		VARCHAR(50),
		CreatedDate			DATETIME,
		DisplayDescription	BIT
    )

	Declare @tempChild table
	(
		ID					BIGINT,
		_ArchiveMediaID		BIGINT,
		MediaType			VARCHAR(2),
		HighlightingText	NVARCHAR(MAX),
		Content				NVARCHAR(MAX),
		MediaDate			DATETIME,
		Title				NVARCHAR(MAX),
		SubMediaType		VARCHAR(50),
		CreatedDate			DATETIME,
		_ParentID			BIGINT
	)
    
    -- Fill Temp table from IQArchive_Media table
    IF(@CategoryGUID IS NULL)
	BEGIN
		INSERT INTO #TempResults 
		SELECT * FROM 
					(
						SELECT	
								CASE
									WHEN @SortColumn = 'MediaDate' AND @IsAsc = 1 THEN ROW_NUMBER() OVER(ORDER By MediaDate ASC)
									WHEN @SortColumn = 'MediaDate' AND @IsAsc = 0 THEN ROW_NUMBER() OVER(ORDER By MediaDate DESC)
									WHEN @SortColumn = 'CreatedDate' AND @IsAsc = 1 THEN ROW_NUMBER() OVER(ORDER By CreatedDate ASC)
									WHEN @SortColumn = 'CreatedDate' AND @IsAsc = 0 THEN ROW_NUMBER() OVER(ORDER By CreatedDate DESC)
									ELSE ROW_NUMBER() OVER(ORDER By MediaDate DESC)
								END AS RowNo,
								ID,
								_ArchiveMediaID,
								v5MediaType,		
								HighlightingText,
								Content,
								MediaDate,		
								Title,			
								v5SubMediaType,
								CreatedDate,
								DisplayDescription	
						FROM	IQArchive_Media WITH (NOLOCK)
						WHERE	IsActive = 1
						AND		ClientGUID = @ClientGUID
						AND		ISNULL(IQArchive_Media._ParentID,0) =  case when @v4LibraryRollup =1  then  0 else ISNULL(IQArchive_Media._ParentID,0) end
						AND		(@CustomerGUID IS NULL OR CustomerGUID = @CustomerGUID)
						AND		((@FromDate IS NULL OR @ToDate IS NULL) OR IQArchive_Media.MediaDate BETWEEN @FromDate AND @ToDate) 
						AND		(@SearchTerm IS NULL OR (Content LIKE '%' + @SearchTerm + '%' OR Title LIKE '%' + @SearchTerm + '%'))
						AND		(@SubMediaType IS NULL OR v5SubMediaType = @SubMediaType)
					) AS T
			
		Where RowNo > @FromRecordID AND RowNo <= (@FromRecordID + @PageSize)
		AND	ID <= @SinceID
		Order By RowNo

		SET @QueryDetail ='populate #TempResults table from IQArchive_Media'
		SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
		INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
		SET @Stopwatch = GetDate()		

		IF(@v4LibraryRollup = 1) begin
			INSERT INTO @tempChild
			SELECT 
					IQArchive_Media.ID,
					IQArchive_Media._ArchiveMediaID,
					IQArchive_Media.v5MediaType,		
					IQArchive_Media.HighlightingText,
					IQArchive_Media.Content,
					IQArchive_Media.MediaDate,		
					IQArchive_Media.Title,			
					IQArchive_Media.v5SubMediaType,
					IQArchive_Media.CreatedDate,
					IQArchive_Media._ParentID
			FROM	
				#TempResults as tempParent
					Inner Join IQArchive_Media WITH (NOLOCK) 
						ON tempParent.ID = IQArchive_Media._ParentID
						AND IQArchive_Media.IsActive = 1
						AND ClientGUID = @ClientGUID
			WHERE
				(@CustomerGUID IS NULL OR IQArchive_Media.CustomerGUID = @CustomerGUID)
				AND		((@FromDate IS NULL OR @ToDate IS NULL) OR IQArchive_Media.MediaDate BETWEEN @FromDate AND @ToDate) 
				AND		(@SearchTerm IS NULL OR (IQArchive_Media.Content LIKE '%' + @SearchTerm + '%' OR IQArchive_Media.Title LIKE '%' + @SearchTerm + '%'))
				AND		(@SubMediaType IS NULL OR IQArchive_Media.v5SubMediaType = @SubMediaType)
				AND	IQArchive_Media.ID <= @SinceID

			SET @QueryDetail ='populate @tempChild table from #TempResults'
			SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
			INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
			SET @Stopwatch = GetDate()		

			SELECT 
					@ChildRecordsCount = COUNT(*)
			FROM	
					IQArchive_Media WITH (NOLOCK) 
			WHERE		IsActive = 1
				AND		ClientGUID = @ClientGUID
				AND		IQArchive_Media._ParentID IS NOT NULL
				AND		(@CustomerGUID IS NULL OR CustomerGUID = @CustomerGUID)
				AND		((@FromDate IS NULL OR @ToDate IS NULL) OR IQArchive_Media.MediaDate BETWEEN @FromDate AND @ToDate) 
				AND		(@SearchTerm IS NULL OR (Content LIKE '%' + @SearchTerm + '%' OR Title LIKE '%' + @SearchTerm + '%'))
				AND		(@SubMediaType IS NULL OR v5SubMediaType = @SubMediaType)

			SET @QueryDetail ='get total child results count from IQArchive_Media'
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
									CASE
										WHEN @SortColumn = 'MediaDate' AND @IsAsc = 1 THEN ROW_NUMBER() OVER(ORDER By MediaDate ASC)
										WHEN @SortColumn = 'MediaDate' AND @IsAsc = 0 THEN ROW_NUMBER() OVER(ORDER By MediaDate DESC)
										WHEN @SortColumn = 'CreatedDate' AND @IsAsc = 1 THEN ROW_NUMBER() OVER(ORDER By CreatedDate ASC)
										WHEN @SortColumn = 'CreatedDate' AND @IsAsc = 0 THEN ROW_NUMBER() OVER(ORDER By CreatedDate DESC)
										ELSE ROW_NUMBER() OVER(ORDER By MediaDate DESC)
									END AS RowNo,
									ID,
									_ArchiveMediaID,
									v5MediaType,			
									HighlightingText,
									Content,
									MediaDate,		
									Title,			
									v5SubMediaType,
									CreatedDate,
									DisplayDescription	
							FROM	IQArchive_Media WITH (NOLOCK)
							WHERE	( IQArchive_Media.CategoryGUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
										OR IQArchive_Media.SubCategory1GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
										OR IQArchive_Media.SubCategory2GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
										OR IQArchive_Media.SubCategory3GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
									)
							AND IsActive = 1 
							AND		ClientGUID = @ClientGUID
							AND		ISNULL(IQArchive_Media._ParentID,0) =  case when @v4LibraryRollup =1  then  0 else ISNULL(IQArchive_Media._ParentID,0) end
							AND		(@CustomerGUID IS NULL OR CustomerGUID = @CustomerGUID)
							AND		((@FromDate IS NULL OR @ToDate IS NULL) OR IQArchive_Media.MediaDate BETWEEN @FromDate AND @ToDate) 
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
									0 END
						) >= CASE WHEN @TotalCats < 4 THEN @TotalCats ELSE 4 END
						) AS T
			
			Where RowNo > @FromRecordID AND RowNo <= (@FromRecordID + @PageSize)
			AND	ID <= @SinceID
			Order By RowNo

			SET @QueryDetail ='populate #TempResults table from IQArchive_Media'
			SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
			INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
			SET @Stopwatch = GetDate()		
			
			IF(@v4LibraryRollup = 1) begin
				INSERT INTO @tempChild
			SELECT 
				IQArchive_Media.ID,
				IQArchive_Media._ArchiveMediaID,
				IQArchive_Media.v5MediaType,			
				IQArchive_Media.HighlightingText,
				IQArchive_Media.Content,
				IQArchive_Media.MediaDate,		
				IQArchive_Media.Title,			
				IQArchive_Media.v5SubMediaType,
				IQArchive_Media.CreatedDate,
				IQArchive_Media._ParentID
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
							AND		(@CustomerGUID IS NULL OR IQArchive_Media.CustomerGUID = @CustomerGUID)
							AND		((@FromDate IS NULL OR @ToDate IS NULL) OR IQArchive_Media.MediaDate BETWEEN @FromDate AND @ToDate) 
							AND		(@SearchTerm IS NULL OR (IQArchive_Media.Content LIKE '%' + @SearchTerm + '%' OR IQArchive_Media.Title LIKE '%' + @SearchTerm + '%'))
							AND		(@SubMediaType IS NULL OR IQArchive_Media.v5SubMediaType = @SubMediaType)
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

				SELECT 
				@ChildRecordsCount = COUNT(*)
			FROM	
					IQArchive_Media WITH (NOLOCK) 
			WHERE	( IQArchive_Media.CategoryGUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
										OR IQArchive_Media.SubCategory1GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
										OR IQArchive_Media.SubCategory2GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
										OR IQArchive_Media.SubCategory3GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
									)
							AND IsActive = 1 
							AND		ClientGUID = @ClientGUID
							AND		IQArchive_Media._ParentID IS NOT NULL
							AND		(@CustomerGUID IS NULL OR CustomerGUID = @CustomerGUID)
							AND		((@FromDate IS NULL OR @ToDate IS NULL) OR IQArchive_Media.MediaDate BETWEEN @FromDate AND @ToDate) 
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
									0 END
						) >= CASE WHEN @TotalCats < 4 THEN @TotalCats ELSE 4 END

				SET @QueryDetail ='get total child results count from IQArchive_Media'
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
									CASE
										WHEN @SortColumn = 'MediaDate' AND @IsAsc = 1 THEN ROW_NUMBER() OVER(ORDER By MediaDate ASC)
										WHEN @SortColumn = 'MediaDate' AND @IsAsc = 0 THEN ROW_NUMBER() OVER(ORDER By MediaDate DESC)
										WHEN @SortColumn = 'CreatedDate' AND @IsAsc = 1 THEN ROW_NUMBER() OVER(ORDER By CreatedDate ASC)
										WHEN @SortColumn = 'CreatedDate' AND @IsAsc = 0 THEN ROW_NUMBER() OVER(ORDER By CreatedDate DESC)
										ELSE ROW_NUMBER() OVER(ORDER By MediaDate DESC)
									END AS RowNo,
									ID,
									_ArchiveMediaID,
									v5MediaType,			
									HighlightingText,
									Content,
									MediaDate,		
									Title,			
									v5SubMediaType,
									CreatedDate,
									DisplayDescription	
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
							AND		ISNULL(IQArchive_Media._ParentID,0) =  case when @v4LibraryRollup =1  then  0 else ISNULL(IQArchive_Media._ParentID,0) end
							AND		(@CustomerGUID IS NULL OR CustomerGUID = @CustomerGUID)
							AND		((@FromDate IS NULL OR @ToDate IS NULL) OR IQArchive_Media.MediaDate BETWEEN @FromDate AND @ToDate) 
							AND		(@SearchTerm IS NULL OR (Content LIKE '%' + @SearchTerm + '%' OR Title LIKE '%' + @SearchTerm + '%'))
							AND		(@SubMediaType IS NULL OR v5SubMediaType = @SubMediaType)
						) AS T
			
			Where RowNo > @FromRecordID AND RowNo <= (@FromRecordID + @PageSize)
			AND	ID <= @SinceID
			Order By RowNo

			SET @QueryDetail ='populate #TempResults table from IQArchive_Media'
			SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
			INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
			SET @Stopwatch = GetDate()		
			
			IF(@v4LibraryRollup = 1) begin
				INSERT INTO @tempChild
			SELECT 
				IQArchive_Media.ID,
				IQArchive_Media._ArchiveMediaID,
				IQArchive_Media.v5MediaType,			
				IQArchive_Media.HighlightingText,
				IQArchive_Media.Content,
				IQArchive_Media.MediaDate,		
				IQArchive_Media.Title,			
				IQArchive_Media.v5SubMediaType,
				IQArchive_Media.CreatedDate,
				IQArchive_Media._ParentID
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
				AND		(@CustomerGUID IS NULL OR IQArchive_Media.CustomerGUID = @CustomerGUID)
				AND		((@FromDate IS NULL OR @ToDate IS NULL) OR IQArchive_Media.MediaDate BETWEEN @FromDate AND @ToDate) 
				AND		(@SearchTerm IS NULL OR (IQArchive_Media.Content LIKE '%' + @SearchTerm + '%' OR IQArchive_Media.Title LIKE '%' + @SearchTerm + '%'))
				AND		(@SubMediaType IS NULL OR IQArchive_Media.v5SubMediaType = @SubMediaType)
				AND	IQArchive_Media.ID <= @SinceID

				SET @QueryDetail ='populate @tempChild table from #TempResults'
			SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
			INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
			SET @Stopwatch = GetDate()	

				SELECT 
				@ChildRecordsCount = COUNT(*)
			FROM	
					IQArchive_Media WITH (NOLOCK) 
			WHERE
				(
					IQArchive_Media.CategoryGUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
						OR IQArchive_Media.SubCategory1GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
						OR IQArchive_Media.SubCategory2GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
						OR IQArchive_Media.SubCategory3GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
				)			
			AND		IsActive = 1
			AND		ClientGUID = @ClientGUID
			AND		IQArchive_Media._ParentID IS NOT NULL
			AND		(@CustomerGUID IS NULL OR CustomerGUID = @CustomerGUID)
			AND		((@FromDate IS NULL OR @ToDate IS NULL) OR IQArchive_Media.MediaDate BETWEEN @FromDate AND @ToDate) 
			AND		(@SearchTerm IS NULL OR (Content LIKE '%' + @SearchTerm + '%' OR Title LIKE '%' + @SearchTerm + '%'))
			AND		(@SubMediaType IS NULL OR v5SubMediaType = @SubMediaType)

				SET @QueryDetail ='get total child results count from IQArchive_Media'
			SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
			INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
			SET @Stopwatch = GetDate()		
			end
		END
	END

	SELECT @TotalResults = (@TotalResultsDisplay - @ChildRecordsCount)
    		
    -- Fill ArchiveBLPM table
    
    SELECT 
			TempResults.ID,
			_ArchiveMediaID,
			TempResults.Title,
			TempResults.HighlightingText,
			TempResults.Content,
			TempResults.MediaDate,
			TempResults.CreatedDate,
			TempResults.MediaType,
			TempResults.SubMediaType,
			ArchiveBLPM.Circulation,
			ArchiveBLPM.FileLocation,
			ArchiveBLPM.Pub_Name,
			Description,
			TempResults.DisplayDescription
    FROM #TempResults AS TempResults
    INNER JOIN ArchiveBLPM WITH (NOLOCK)
    ON TempResults._ArchiveMediaID = ArchiveBLPM.ArchiveBLPMKey
    AND	TempResults.SubMediaType=ArchiveBLPM.v5SubMediaType

	SET @QueryDetail ='select archive blpm records'
	SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
	INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
	SET @Stopwatch = GetDate()		
    
    -- Fill ArchiveClip table
    
    SELECT 
			TempResults.ID,
			_ArchiveMediaID,
			TempResults.Title,
			TempResults.HighlightingText,
			TempResults.Content,
			TempResults.MediaDate,
			TempResults.MediaType,
			TempResults.SubMediaType,
			TempResults.CreatedDate,
			ArchiveClip.ClipID,
			ArchiveClip.ClipDate,
			Nielsen_Audience,
			IQAdShareValue,
			Nielsen_Result,
			(Select Dma_Name From IQ_Station Where IQ_Station_ID = SUBSTRING(IQ_CC_Key,0 ,CHARINDEX('_',IQ_CC_Key))) as 'Market',
			(Select IQ_Station_ID From IQ_Station Where IQ_Station_ID = SUBSTRING(IQ_CC_Key,0 ,CHARINDEX('_',IQ_CC_Key))) as 'StationLogo',
			(Select TimeZone From IQ_Station Where IQ_Station_ID = SUBSTRING(IQ_CC_Key,0 ,CHARINDEX('_',IQ_CC_Key))) as 'TimeZone',
			(Select  Dma_Num From IQ_Station Where IQ_Station_ID = SUBSTRING(IQ_CC_Key,0 ,CHARINDEX('_',IQ_CC_Key))) as 'Dma_Num',
			PositiveSentiment,
			NegativeSentiment,
			Description,
			TempResults.DisplayDescription,
			(SELECT SUM(IQSSP_NationalNielsen.Audience) FROM IQSSP_NationalNielsen Where LocalDate = CONVERT(Date,ArchiveClip.ClipDate) AND Title120 = ArchiveClip.Title120 and Station_Affil = (Select Station_Affil From IQ_Station Where IQ_Station_ID = SUBSTRING(IQ_CC_Key,0 ,CHARINDEX('_',IQ_CC_Key)))) as National_Nielsen_Audience,
			(SELECT (SUM(IQSSP_NationalNielsen.MediaValue) * @MultiPlier *  (CONVERT(decimal(18,2),(IQCore_Clip.endOffset - IQCore_Clip.startOffset + 1)) /30 )) FROM IQSSP_NationalNielsen Where LocalDate = CONVERT(Date,ArchiveClip.ClipDate) AND Title120 = ArchiveClip.Title120 and Station_Affil = (Select Station_Affil From IQ_Station Where IQ_Station_ID = SUBSTRING(IQ_CC_Key,0 ,CHARINDEX('_',IQ_CC_Key)))) as National_IQAdShareValue,			
			(SELECT CASE WHEN min(CONVERT(int,IQSSP_NationalNielsen.IsActual)) = 1 THEN 'A' ELSE 'E' END FROM IQSSP_NationalNielsen Where LocalDate = CONVERT(Date,ArchiveClip.ClipDate) AND Title120 = ArchiveClip.Title120 and Station_Affil = (Select Station_Affil From IQ_Station Where IQ_Station_ID = SUBSTRING(IQ_CC_Key,0 ,CHARINDEX('_',IQ_CC_Key)))) as National_Nielsen_Result

    FROM	#TempResults AS TempResults
    
    INNER JOIN ArchiveClip WITH (NOLOCK)
    ON TempResults._ArchiveMediaID = ArchiveClip.ArchiveClipKey
    AND	TempResults.SubMediaType=ArchiveClip.v5SubMediaType
	INNER JOIN IQCore_Clip 
		ON ArchiveClip.ClipID = IQCore_Clip.[Guid]
    
	SET @QueryDetail ='select archive clip records'
	SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
	INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
	SET @Stopwatch = GetDate()		
    -- Fill ArchiveNM table
    
    SELECT 
			TempResults.ID,
			_ArchiveMediaID,
			TempResults.Title,
			TempResults.HighlightingText,
			TempResults.Content,
			TempResults.MediaDate,
			TempResults.MediaType,
			TempResults.SubMediaType,
			TempResults.CreatedDate,
			ArchiveNM.Url,
			Compete_Audience,
			IQAdShareValue,
			Compete_Result,
			ArchiveNM.Publication,
			PositiveSentiment,
			NegativeSentiment,
			IQLicense,
			Description,
			TempResults.DisplayDescription
			
										
    FROM #TempResults AS TempResults
    INNER JOIN ArchiveNM WITH (NOLOCK)
    ON TempResults._ArchiveMediaID = ArchiveNM.ArchiveNMKey
    AND	TempResults.SubMediaType=ArchiveNM.v5SubMediaType
   
	SET @QueryDetail ='select archive nm records'
	SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
	INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
	SET @Stopwatch = GetDate()		

    
    -- Fill ArchiveSM table
    
    SELECT 
			TempResults.ID,
			_ArchiveMediaID,
			TempResults.Title,
			TempResults.HighlightingText,
			TempResults.Content,
			ArchiveSM.Url,
			TempResults.MediaDate,
			TempResults.MediaType,
			TempResults.SubMediaType,
			TempResults.CreatedDate,
			Compete_Audience,
			IQAdShareValue,
			Compete_Result,
			ArchiveSM.homelink,
			PositiveSentiment,
			NegativeSentiment,
			Description,
			TempResults.DisplayDescription,
			ThumbUrl,
			ArticleStats
			
    FROM #TempResults AS TempResults
    INNER JOIN ArchiveSM WITH (NOLOCK)
    ON TempResults._ArchiveMediaID = ArchiveSM.ArchiveSMKey
    AND	TempResults.SubMediaType=ArchiveSM.v5SubMediaType
  
	SET @QueryDetail ='select archive sm records'
	SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
	INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
	SET @Stopwatch = GetDate()		

   
    -- Fill ArchiveTweets table
    
    SELECT 
			TempResults.ID,
			_ArchiveMediaID,
			TempResults.Title,
			TempResults.HighlightingText,
			TempResults.Content,
			TempResults.MediaType,
			TempResults.SubMediaType,
			TempResults.MediaDate,
			TempResults.CreatedDate,
			Actor_DisplayName, 
			Actor_PreferredUserName, 
			Actor_FollowersCount, 
			Actor_FriendsCount, 
			Actor_Image,
			Actor_link,
			Tweet_ID,
			gnip_Klout_Score,
			PositiveSentiment,
			NegativeSentiment,
			Description,
			TempResults.DisplayDescription

    FROM #TempResults AS TempResults
    INNER JOIN ArchiveTweets WITH (NOLOCK)
    ON TempResults._ArchiveMediaID = ArchiveTweets.ArchiveTweets_Key
    AND	TempResults.SubMediaType=ArchiveTweets.v5SubMediaType

	SET @QueryDetail ='select archive tweets records'
	SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
	INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
	SET @Stopwatch = GetDate()		


	-- Fill ArchiveTVEyes table
    
    SELECT 
			TempResults.ID,
			_ArchiveMediaID,
			TempResults.Title,
			TempResults.HighlightingText,
			TempResults.Content,
			ArchiveTVEyes.StationID,
			ArchiveTVEyes.Market,
			ArchiveTVEyes.DMARank,
			TempResults.MediaDate,
			TempResults.MediaType,
			TempResults.SubMediaType,
			TempResults.CreatedDate,
			PositiveSentiment,
			NegativeSentiment,
			ArchiveTVEyes.LocalDateTime,
			ArchiveTVEyes.TimeZone,
			Description,
			TempResults.DisplayDescription
			
    FROM #TempResults AS TempResults
    INNER JOIN ArchiveTVEyes WITH (NOLOCK)
    ON TempResults._ArchiveMediaID = ArchiveTVEyes.ArchiveTVEyesKey
    AND	TempResults.SubMediaType=ArchiveTVEyes.v5SubMediaType
	AND ArchiveTVEyes.IsDownLoaded = 1

	SET @QueryDetail ='select archive tveyes records'
	SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
	INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
	SET @Stopwatch = GetDate()		
		
	-- Fill ArchiveMS table   
    SELECT 
			TempResults.ID,
			_ArchiveMediaID,
			TempResults.Title,
			TempResults.HighlightingText,
			TempResults.Content,
			TempResults.MediaDate,
			TempResults.CreatedDate,
			TempResults.MediaType,
			TempResults.SubMediaType,
			ArchiveMisc.CreateDT,
			ArchiveMisc.CreateDTTimeZone,
			IQUGC_FileTypes.FileType,
			(SELECT ISNULL(StreamSuffixPath + REPLACE(ArchiveMisc.Location,'\','/'),'') FROM IQCore_RootPath Where ID = ArchiveMisc._RootPathID) as MediaUrl,
			Description		
    FROM #TempResults AS TempResults
    INNER JOIN ArchiveMisc WITH (NOLOCK)
		ON TempResults._ArchiveMediaID = ArchiveMisc.ArchiveMiscKey
    INNER JOIN IQUGC_FileTypes
		ON IQUGC_FileTypes.ID = ArchiveMisc._FileTypeID
    AND	TempResults.SubMediaType=ArchiveMisc.v5SubMediaType

	SET @QueryDetail ='select archive miscellaneous records'
	SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
	INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
	SET @Stopwatch = GetDate()	
    
    -- Fill ArchivePQ table    
    SELECT 
			TempResults.ID,
			_ArchiveMediaID,
			TempResults.Title,
			TempResults.HighlightingText,
			TempResults.Content,
			TempResults.MediaDate,
			TempResults.CreatedDate,
			TempResults.MediaType,
			TempResults.SubMediaType,
			ArchivePQ.Publication,
			ArchivePQ.Author,
			PositiveSentiment,
			NegativeSentiment,
			Description,
			TempResults.DisplayDescription
    FROM #TempResults AS TempResults
    INNER JOIN ArchivePQ WITH (NOLOCK)
    ON TempResults._ArchiveMediaID = ArchivePQ.ArchivePQKey
    AND	TempResults.SubMediaType=ArchivePQ.v5SubMediaType

	SET @QueryDetail ='select archive proquest records'
	SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
	INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
	SET @Stopwatch = GetDate()	

	-- Fill ArchiveRadio table
	SELECT	TempResults.ID,
			_ArchiveMediaID,
			TempResults.Title,
			TempResults.HighlightingText,
			TempResults.Content,
			TempResults.MediaDate,
			TempResults.MediaType,
			TempResults.SubMediaType,
			TempResults.CreatedDate,
			ArchiveRadio.ClipGuid,
			ArchiveRadio.LocalDatetime,
			IQ_Station.Dma_Name,
			IQ_Station.IQ_Station_ID,
			IQ_Station.TimeZone,
			IQ_Station.Dma_Num,
			PositiveSentiment,
			NegativeSentiment,
			Description,
			TempResults.DisplayDescription
	FROM	#TempResults as TempResults
	INNER	JOIN ArchiveRadio WITH (NOLOCK)
		ON TempResults._ArchiveMediaID = ArchiveRadio.ArchiveRadioKey
		AND TempResults.SubMediaType = ArchiveRadio.v5SubMediaType
	INNER	JOIN IQ_Station
		ON IQ_Station_ID = SUBSTRING(ArchiveRadio.IQ_CC_Key,0 ,CHARINDEX('_',ArchiveRadio.IQ_CC_Key))

	SET @QueryDetail ='select archive radio records'
	SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
	INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
	SET @Stopwatch = GetDate()

	SELECT 
			TempResults._ParentID,
			TempResults.ID,
			_ArchiveMediaID,
			TempResults.Title,
			TempResults.HighlightingText,
			TempResults.Content,
			TempResults.MediaDate,
			TempResults.MediaType,
			TempResults.SubMediaType,
			TempResults.CreatedDate,
			ArchiveClip.ClipID,
			ArchiveClip.ClipDate,
			Nielsen_Audience,
			IQAdShareValue,
			Nielsen_Result,
			(Select Dma_Name From IQ_Station Where IQ_Station_ID = SUBSTRING(IQ_CC_Key,0 ,CHARINDEX('_',IQ_CC_Key))) as 'Market',
			(Select IQ_Station_ID From IQ_Station Where IQ_Station_ID = SUBSTRING(IQ_CC_Key,0 ,CHARINDEX('_',IQ_CC_Key))) as 'StationLogo',
			(Select TimeZone From IQ_Station Where IQ_Station_ID = SUBSTRING(IQ_CC_Key,0 ,CHARINDEX('_',IQ_CC_Key))) as 'TimeZone',
			(Select  Dma_Num From IQ_Station Where IQ_Station_ID = SUBSTRING(IQ_CC_Key,0 ,CHARINDEX('_',IQ_CC_Key))) as 'Dma_Num',
			PositiveSentiment,
			NegativeSentiment
    FROM	@tempChild AS TempResults
    
    INNER JOIN ArchiveClip WITH (NOLOCK)
    ON TempResults._ArchiveMediaID = ArchiveClip.ArchiveClipKey
    AND	TempResults.SubMediaType=ArchiveClip.v5SubMediaType

	SET @QueryDetail ='select archive clip child records'
	SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
	INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
	SET @Stopwatch = GetDate()		


	SELECT
			TempResults._ParentID, 
			TempResults.ID,
			_ArchiveMediaID,
			TempResults.Title,
			TempResults.HighlightingText,
			TempResults.Content,
			TempResults.MediaDate,
			TempResults.MediaType,
			TempResults.SubMediaType,
			TempResults.CreatedDate,
			ArchiveNM.Url,
			Compete_Audience,
			IQAdShareValue,
			Compete_Result,
			ArchiveNM.Publication,
			PositiveSentiment,
			NegativeSentiment,
			IQLicense
			
										
    FROM @tempChild AS TempResults
    INNER JOIN ArchiveNM WITH (NOLOCK)
    ON TempResults._ArchiveMediaID = ArchiveNM.ArchiveNMKey
    AND	TempResults.SubMediaType=ArchiveNM.v5SubMediaType

	SET @QueryDetail ='select archive tv child records'
	SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
	INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
	SET @Stopwatch = GetDate()		
    
    IF @IsEnableFilter IS NOT NULL AND @IsEnableFilter = 1
		BEGIN
			-- SELECT DISTINCT Filters With Count
			EXEC [dbo].[usp_v5_IQArchive_Media_SelectFilter] @FromDate,@ToDate,@SubMediaType,@SearchTerm,@CategoryGUID,@ClientGUID,@CustomerGUID,@SelectionType,@SinceID

			SET @QueryDetail ='usp_v5_IQArchive_Media_SelectFilter sp'
			SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
			INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
			SET @Stopwatch = GetDate()		

		END

	SET @QueryDetail ='0'
	SET @TimeDiff = DateDiff(ms, @SPStartTime, GetDate())
	INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
END