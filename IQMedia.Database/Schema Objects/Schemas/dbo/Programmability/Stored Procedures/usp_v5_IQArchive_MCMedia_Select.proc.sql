CREATE PROCEDURE [dbo].[usp_v5_IQArchive_MCMedia_Select]
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
		@MasterClientID int,
		@SinceID bigint output,
		@TotalResults bigint output
AS
BEGIN
	
	SET NOCOUNT ON;

	DECLARE @StopWatch datetime, @SPStartTime datetime,@SPTrackingID uniqueidentifier, @TimeDiff decimal(18,2),@SPName varchar(100),@QueryDetail varchar(500)
 
	Set @SPStartTime=GetDate()
	Set @Stopwatch=GetDate()
	SET @SPTrackingID = NEWID()
	SET @SPName ='usp_v5_IQArchive_MCMedia_Select'   

	DECLARE @MultiPlier float
	select @MultiPlier = CONVERT(float,ISNULL((select Value from IQClient_CustomSettings where Field = 'Multiplier' and _ClientGuid = @ClientGUID),(select Value from IQClient_CustomSettings where Field = 'Multiplier' and _ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER))))
	
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

	DECLARE @ReportGuid UNIQUEIDENTIFIER
	SELECT	@ReportGuid = ReportGUID
	FROM	IQ_Report WITH (NOLOCK)
	INNER	JOIN IQ_ReportType ON IQ_Report._ReportTypeID = IQ_ReportType.ID
	WHERE	MasterReportType = 'MCMediaTemplate'
			AND ClientGuid = @MasterClientGUID 
			AND IQ_Report.IsActive = 1
			AND IQ_ReportType.IsActive = 1

	IF(@CategoryGUID IS NULL)
	BEGIN
		SELECT	@SinceID = CASE WHEN (@SinceID IS NULL OR @SinceID = 0) THEN MAX(IQArchive_MCMedia.ID) ELSE @SinceID END,
				@TotalResults = COUNT(IQArchive_MCMedia.ID)
		FROM	IQArchive_MCMedia WITH (NOLOCK)
		INNER	JOIN IQArchive_Media WITH (NOLOCK)
				ON IQArchive_MCMedia.ArchiveID = IQArchive_Media.ID
		WHERE	IQArchive_Media.IsActive = 1
		AND		IQArchive_MCMedia.IsActive = 1
		AND		IQArchive_MCMedia.MasterClientGUID = @MasterClientGUID
		AND		(@MasterClientGUID = @ClientGUID OR IQArchive_Media.ClientGUID = @ClientGUID)
		AND		((@SinceID IS NULL OR @SinceID = 0) OR IQArchive_MCMedia.ID <= @SinceID )
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

			SELECT	@SinceID = CASE WHEN (@SinceID IS NULL OR @SinceID=0) THEN MAX(IQArchive_MCMedia.ID) ELSE @SinceID END,
					@TotalResults = COUNT(IQArchive_MCMedia.ID)
			FROM	IQArchive_MCMedia WITH (NOLOCK)
			INNER	JOIN IQArchive_Media WITH (NOLOCK)
					ON IQArchive_MCMedia.ArchiveID = IQArchive_Media.ID
			WHERE
				(
					IQArchive_Media.CategoryGUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
						OR IQArchive_Media.SubCategory1GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
						OR IQArchive_Media.SubCategory2GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
						OR IQArchive_Media.SubCategory3GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
				)			
			AND		IQArchive_Media.IsActive = 1
			AND		IQArchive_MCMedia.IsActive = 1
			AND		IQArchive_MCMedia.MasterClientGUID = @MasterClientGUID
			AND		(@MasterClientGUID = @ClientGUID OR IQArchive_Media.ClientGUID = @ClientGUID)
			AND		((@SinceID IS NULL OR @SinceID = 0) OR IQArchive_MCMedia.ID <= @SinceID )
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
			SELECT	@SinceID = CASE WHEN (@SinceID IS NULL OR @SinceID=0) THEN MAX(IQArchive_MCMedia.ID) ELSE @SinceID END,
					@TotalResults = COUNT(IQArchive_MCMedia.ID)
			FROM	IQArchive_MCMedia WITH (NOLOCK)
			INNER	JOIN IQArchive_Media WITH (NOLOCK)
					ON IQArchive_MCMedia.ArchiveID = IQArchive_Media.ID
			WHERE
				(
					IQArchive_Media.CategoryGUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
						OR IQArchive_Media.SubCategory1GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
						OR IQArchive_Media.SubCategory2GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
						OR IQArchive_Media.SubCategory3GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
				)			
			AND		IQArchive_Media.IsActive = 1
			AND		IQArchive_MCMedia.IsActive = 1
			AND		IQArchive_MCMedia.MasterClientGUID = @MasterClientGUID
			AND		(@MasterClientGUID = @ClientGUID OR IQArchive_Media.ClientGUID = @ClientGUID)
			AND		((@SinceID IS NULL OR @SinceID = 0) OR IQArchive_MCMedia.ID <= @SinceID )
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
		MCMedia_ID			BIGINT,
		ID					BIGINT,
		_ArchiveMediaID		BIGINT,
		MediaType			VARCHAR(2),
		HighlightingText	NVARCHAR(MAX),
		Content				NVARCHAR(MAX),
		MediaDate			DATETIME,
		Title				NVARCHAR(MAX),
		SubMediaType		VARCHAR(50),
		CreatedDate			DATETIME,
		IsPublished			BIT,
		DisplayDescription  BIT
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
									WHEN @SortColumn = 'CreatedDate' AND @IsAsc = 1 THEN ROW_NUMBER() OVER(ORDER By IQArchive_Media.CreatedDate ASC)
									WHEN @SortColumn = 'CreatedDate' AND @IsAsc = 0 THEN ROW_NUMBER() OVER(ORDER By IQArchive_Media.CreatedDate DESC)
									ELSE ROW_NUMBER() OVER(ORDER By MediaDate DESC)
								END AS RowNo,
								IQArchive_MCMedia.ID AS MCMedia_ID,
								IQArchive_Media.ID,
								_ArchiveMediaID,
								v5MediaType,		
								HighlightingText,
								Content,
								MediaDate,		
								IQArchive_Media.Title,			
								v5SubMediaType,
								IQArchive_Media.CreatedDate,
								(SELECT ReportRule.exist('MediaResults/ID[text()=sql:column("IQArchive_Media.ID")]') FROM IQ_Report WHERE ReportGUID = @ReportGuid) as IsPublished,
								IQArchive_Media.DisplayDescription	
						FROM	IQArchive_MCMedia WITH (NOLOCK)
						INNER	JOIN IQArchive_Media WITH (NOLOCK)
								ON IQArchive_MCMedia.ArchiveID = IQArchive_Media.ID
						WHERE 	IQArchive_Media.IsActive = 1
						AND		IQArchive_MCMedia.IsActive = 1
						AND		IQArchive_MCMedia.MasterClientGUID = @MasterClientGUID
						AND		(@MasterClientGUID = @ClientGUID OR IQArchive_Media.ClientGUID = @ClientGUID)
						AND		(@CustomerGUID IS NULL OR CustomerGUID = @CustomerGUID)
						AND		((@FromDate IS NULL OR @ToDate IS NULL) OR IQArchive_Media.MediaDate BETWEEN @FromDate AND @ToDate) 
						AND		(@SearchTerm IS NULL OR (Content LIKE '%' + @SearchTerm + '%' OR IQArchive_Media.Title LIKE '%' + @SearchTerm + '%'))
						AND		(@SubMediaType IS NULL OR v5SubMediaType = @SubMediaType)
					) AS T
			
		Where RowNo > @FromRecordID AND RowNo <= (@FromRecordID + @PageSize)
		AND	MCMedia_ID <= @SinceID
		Order By RowNo

		SET @QueryDetail ='populate #TempResults table from IQArchive_Media'
		SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
		INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
		SET @Stopwatch = GetDate()		
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
										WHEN @SortColumn = 'CreatedDate' AND @IsAsc = 1 THEN ROW_NUMBER() OVER(ORDER By IQArchive_Media.CreatedDate ASC)
										WHEN @SortColumn = 'CreatedDate' AND @IsAsc = 0 THEN ROW_NUMBER() OVER(ORDER By IQArchive_Media.CreatedDate DESC)
										ELSE ROW_NUMBER() OVER(ORDER By MediaDate DESC)
									END AS RowNo,
									IQArchive_MCMedia.ID AS MCMedia_ID,
									IQArchive_Media.ID,
									_ArchiveMediaID,
									v5MediaType,		
									HighlightingText,
									Content,
									MediaDate,		
									IQArchive_Media.Title,			
									v5SubMediaType,
									IQArchive_Media.CreatedDate,
									(SELECT ReportRule.exist('MediaResults/ID[text()=sql:column("IQArchive_Media.ID")]') FROM IQ_Report WHERE ReportGUID = @ReportGuid) as IsPublished,
									IQArchive_Media.DisplayDescription
							FROM	IQArchive_MCMedia WITH (NOLOCK)
							INNER	JOIN IQArchive_Media WITH (NOLOCK)
									ON IQArchive_MCMedia.ArchiveID = IQArchive_Media.ID
							WHERE	( IQArchive_Media.CategoryGUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
										OR IQArchive_Media.SubCategory1GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
										OR IQArchive_Media.SubCategory2GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
										OR IQArchive_Media.SubCategory3GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
									)
							AND		IQArchive_Media.IsActive = 1
							AND		IQArchive_MCMedia.IsActive = 1 
							AND		IQArchive_MCMedia.MasterClientGUID = @MasterClientGUID
							AND		(@MasterClientGUID = @ClientGUID OR IQArchive_Media.ClientGUID = @ClientGUID)
							AND		(@CustomerGUID IS NULL OR CustomerGUID = @CustomerGUID)
							AND		((@FromDate IS NULL OR @ToDate IS NULL) OR IQArchive_Media.MediaDate BETWEEN @FromDate AND @ToDate) 
							AND		(@SearchTerm IS NULL OR (Content LIKE '%' + @SearchTerm + '%' OR IQArchive_Media.Title LIKE '%' + @SearchTerm + '%'))
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
			AND	MCMedia_ID <= @SinceID
			Order By RowNo

			SET @QueryDetail ='populate #TempResults table from IQArchive_Media'
			SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
			INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
			SET @Stopwatch = GetDate()		
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
										WHEN @SortColumn = 'CreatedDate' AND @IsAsc = 1 THEN ROW_NUMBER() OVER(ORDER By IQArchive_Media.CreatedDate ASC)
										WHEN @SortColumn = 'CreatedDate' AND @IsAsc = 0 THEN ROW_NUMBER() OVER(ORDER By IQArchive_Media.CreatedDate DESC)
										ELSE ROW_NUMBER() OVER(ORDER By MediaDate DESC)
									END AS RowNo,
									IQArchive_MCMedia.ID AS MCMedia_ID,
									IQArchive_Media.ID,
									_ArchiveMediaID,
									v5MediaType,		
									HighlightingText,
									Content,
									MediaDate,		
									IQArchive_Media.Title,			
									v5SubMediaType,
									IQArchive_Media.CreatedDate,
									(SELECT ReportRule.exist('MediaResults/ID[text()=sql:column("IQArchive_Media.ID")]') FROM IQ_Report WHERE ReportGUID = @ReportGuid) as IsPublished,
									IQArchive_Media.DisplayDescription	
							FROM	IQArchive_MCMedia WITH (NOLOCK)
							INNER	JOIN IQArchive_Media WITH (NOLOCK)
									ON IQArchive_MCMedia.ArchiveID = IQArchive_Media.ID
							WHERE
								(
									IQArchive_Media.CategoryGUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
										OR IQArchive_Media.SubCategory1GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
										OR IQArchive_Media.SubCategory2GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
										OR IQArchive_Media.SubCategory3GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
								)			
							AND		IQArchive_Media.IsActive = 1
							AND		IQArchive_MCMedia.IsActive = 1 
							AND		IQArchive_MCMedia.MasterClientGUID = @MasterClientGUID
							AND		(@MasterClientGUID = @ClientGUID OR IQArchive_Media.ClientGUID = @ClientGUID)
							AND		(@CustomerGUID IS NULL OR CustomerGUID = @CustomerGUID)
							AND		((@FromDate IS NULL OR @ToDate IS NULL) OR IQArchive_Media.MediaDate BETWEEN @FromDate AND @ToDate) 
							AND		(@SearchTerm IS NULL OR (Content LIKE '%' + @SearchTerm + '%' OR IQArchive_Media.Title LIKE '%' + @SearchTerm + '%'))
							AND		(@SubMediaType IS NULL OR v5SubMediaType = @SubMediaType)
						) AS T
			
			Where RowNo > @FromRecordID AND RowNo <= (@FromRecordID + @PageSize)
			AND	MCMedia_ID <= @SinceID
			Order By RowNo

			SET @QueryDetail ='populate #TempResults table from IQArchive_Media'
			SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
			INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
			SET @Stopwatch = GetDate()		
		END
	END
	    
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
			TempResults.IsPublished,
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
			TempResults.IsPublished,
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
			TempResults.IsPublished,
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
			TempResults.IsPublished,
			Description,
			TempResults.DisplayDescription,
			ArchiveSM.ThumbUrl,
			ArchiveSM.ArticleStats
			
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
			TempResults.IsPublished,
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
			TempResults.IsPublished,
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
			TempResults.IsPublished,
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
			TempResults.IsPublished,
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
			TempResults.IsPublished,
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

	-- Return dummy tables for TV/NM child records, to match result signature of other Archive select procedures
	SELECT NULL
	WHERE 1 = 2

	SELECT NULL
	WHERE 1 = 2
    
    IF @IsEnableFilter IS NOT NULL AND @IsEnableFilter = 1
		BEGIN
			-- SELECT DISTINCT Filters With Count
			EXEC [dbo].[usp_v5_IQArchive_MCMedia_SelectFilter] @FromDate,@ToDate,@SubMediaType,@SearchTerm,@CategoryGUID,@ClientGUID,@CustomerGUID,@SelectionType,@SinceID,@MasterClientGUID

			SET @QueryDetail ='usp_v5_IQArchive_MCMedia_SelectFilter sp'
			SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
			INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
			SET @Stopwatch = GetDate()		

		END

	SET @QueryDetail ='0'
	SET @TimeDiff = DateDiff(ms, @SPStartTime, GetDate())
	INSERT INTO IQ_SPTimeTracking([Guid],SPName,Input,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,'<Input><ClientGUID>'+ convert(nvarchar(max),@ClientGUID) +'</ClientGUID><MasterClientID>' + convert(nvarchar(max),@MasterClientID) + '</MasterClientID><FromRecordID>'+ convert(nvarchar(max),@FromRecordID) +'</FromRecordID><PageSize>'+ convert(nvarchar(max),@PageSize) +'</PageSize><FromDate>'+ convert(nvarchar(max),@FromDate) +'</FromDate><ToDate>'+ convert(nvarchar(max),@ToDate) +'</ToDate><SubMediaType>'+ convert(nvarchar(max),@SubMediaType) +'</SubMediaType><SearchTerm>'+ convert(nvarchar(max),@SearchTerm) +'</SearchTerm><IsAsc>'+ convert(nvarchar(max),@IsAsc) +'</IsAsc><IsEnableFilter>'+ convert(nvarchar(max),@IsEnableFilter) +'</IsEnableFilter><SinceID>'+ convert(nvarchar(max),@SinceID) +'</SinceID><SortColumn>'+ convert(nvarchar(max),@SortColumn) +'</SortColumn><SelectionType>'+ convert(nvarchar(max),@SelectionType) +'</SelectionType><CategoryGUID>'+ convert(nvarchar(max),@CategoryGUID) +'</CategoryGUID><CustomerGUID>'+ convert(nvarchar(max),@CustomerGUID) +'</CustomerGUID></Input>',@QueryDetail,@TimeDiff)
END