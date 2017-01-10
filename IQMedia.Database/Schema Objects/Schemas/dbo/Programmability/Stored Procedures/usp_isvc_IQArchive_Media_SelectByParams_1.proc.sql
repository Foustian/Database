CREATE PROCEDURE [dbo].[usp_isvc_IQArchive_Media_SelectByParams]
		@PageSize int,
		@FromDate datetime,
		@ToDate datetime,
		@SubMediaType	varchar(50),
		@CategoryGUID	uniqueidentifier,
		@ClientGUID uniqueidentifier,
		@CustomerGUID  uniqueidentifier,
		@SeqID bigint
AS
BEGIN
	
	SET NOCOUNT ON;

	DECLARE @IsRadioAccess		bit,@MaxSinceID bigint
	
	SELECT 
		@IsRadioAccess = CASE WHEN  ClientRole.IsAccess = 1 AND CustomerRole.IsAccess = 1 THEN 1 ELSE 0 END
	FROM 
		Role INNER JOIN CustomerRole 
			on CustomerRole.RoleID = Role.RoleKey
			INNER JOIN ClientRole
			   ON ClientRole.RoleID = Role.RoleKey
			   AND 	CustomerRole.RoleID =ClientRole.RoleID 
			 inner join Customer ON 
				Customer.CustomerKey = CustomerRole.CustomerID 
	WHERE
		Customer.CustomerGUID   = @CustomerGUID   
		AND Role.IsActive = 1 AND ClientRole.IsActive = 1 AND CustomerRole.IsActive = 1		
		and RoleName ='v4TM'
		
	
	
	DECLARE @TotalResults bigint
	
	SELECT	@MaxSinceID = ISNuLL(MAX(ID),0),
			@TotalResults = COUNT(ID)
	FROM	IQArchive_Media
	WHERE	IsActive = 1
	AND		(@IsRadioAccess = 1 OR MediaType != 'TM')
	AND		ClientGUID = @ClientGUID
	AND		((ISNULL(@CategoryGUID,CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER))  =CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER)) OR CategoryGUID = @CategoryGUID)
	AND		((ISNULL(@FromDate,'') = '' or ISNULL(@ToDate,'') ='') OR ((CAST(IQArchive_Media.MediaDate AS DATE) BETWEEN @FromDate AND @ToDate) OR (CAST(IQArchive_Media.CreatedDate AS DATE) BETWEEN @FromDate AND @ToDate))) 
	AND		(ISNULL(@SubMediaType,'') ='' OR SubMediaType = @SubMediaType)
	

	

    DECLARE @TempResults AS TABLE
    (
		ID					BIGINT,
		_ArchiveMediaID		BIGINT,
		MediaType			VARCHAR(2)
    )
    
    -- Fill Temp table from IQArchive_Media table
    
    INSERT INTO @TempResults
    SELECT top(@PageSize) * FROM 
				(
					SELECT
							ID,	
							_ArchiveMediaID,
							MediaType
					FROM	IQArchive_Media
					WHERE	IsActive = 1
					AND		ClientGUID = @ClientGUID
					AND		(@IsRadioAccess = 1 OR MediaType != 'TM')
					AND		((ISNULL(@CategoryGUID,CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER))  =CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER)) OR CategoryGUID = @CategoryGUID)
					AND		((ISNULL(@FromDate,'') = '' or ISNULL(@ToDate,'') ='') OR ((CAST(IQArchive_Media.MediaDate AS DATE) BETWEEN @FromDate AND @ToDate) OR (CAST(IQArchive_Media.CreatedDate AS DATE) BETWEEN @FromDate AND @ToDate))) 
					AND		(ISNULL(@SubMediaType,'') ='' OR SubMediaType = @SubMediaType)
					AND		ID > @SeqID
				) AS T
    Order By ID asc
    
    SELECT 
			TempResults.ID,
			ArchiveBLPM.Headline as Title,
			Convert(nvarchar(max),ArchiveBLPM.BLPMXml) as HighlightingText,
			ArchiveBLPM.PubDate as MediaDate,
			ArchiveBLPM.CreatedDate,
			'PM' as SubMediaType,
			ArchiveBLPM.Circulation,
			ArchiveBLPM.FileLocation,
			ArchiveBLPM.Pub_Name
    FROM @TempResults AS TempResults
    INNER JOIN ArchiveBLPM
    ON TempResults._ArchiveMediaID = ArchiveBLPM.ArchiveBLPMKey
    AND	TempResults.MediaType='PM'
	order by TempResults.ID asc
    
    -- Fill ArchiveClip table
    
    SELECT 
			TempResults.ID,
			ClipTitle as Title,
			Convert(nvarchar(max),ClosedCaption) as HighlightingText,
			ClipDate as MediaDate,
			'TV' as SubMediaType,
			ClipCreationDate as CreatedDate,
			ClipID,
			Nielsen_Audience,
			IQAdShareValue,
			(Select Dma_Name From IQ_Station Where IQ_Station_ID = SUBSTRING(IQ_CC_Key,0 ,CHARINDEX('_',IQ_CC_Key))) as 'Market',
			(Select Dma_Num From IQ_Station Where IQ_Station_ID = SUBSTRING(IQ_CC_Key,0 ,CHARINDEX('_',IQ_CC_Key))) as 'Dma_Rank',
			(Select Station_Affil From IQ_Station Where IQ_Station_ID = SUBSTRING(IQ_CC_Key,0 ,CHARINDEX('_',IQ_CC_Key))) as 'Station_Affil',
			(Select IQ_Station_ID From IQ_Station Where IQ_Station_ID = SUBSTRING(IQ_CC_Key,0 ,CHARINDEX('_',IQ_CC_Key))) as 'StationLogo',
			(Select TimeZone From IQ_Station Where IQ_Station_ID = SUBSTRING(IQ_CC_Key,0 ,CHARINDEX('_',IQ_CC_Key))) as 'TimeZone',
			PositiveSentiment,
			NegativeSentiment
    FROM	@TempResults AS TempResults
    
    INNER JOIN ArchiveClip
    ON TempResults._ArchiveMediaID = ArchiveClip.ArchiveClipKey
    AND	TempResults.MediaType='TV'
	order by TempResults.ID asc
    
    
    -- Fill ArchiveNM table
    
    SELECT 
			TempResults.ID,
			Title,
			ArticleContent as HighlightingText,
			Harvest_Time as MediaDate,
			'NM' as SubMediaType,
			CreatedDate,
			ArchiveNM.Url,
			ArchiveNM.ArticleID,
			Compete_Audience,
			IQAdShareValue,
			Compete_Result,
			Publication,
			PositiveSentiment,
			NegativeSentiment
			
										
    FROM @TempResults AS TempResults
    INNER JOIN ArchiveNM
    ON TempResults._ArchiveMediaID = ArchiveNM.ArchiveNMKey
    AND	TempResults.MediaType='NM'
   order by TempResults.ID asc
    
    -- Fill ArchiveSM table
    
    SELECT 
			TempResults.ID,
			Title,
			ArticleContent as HighlightingText,
			Url,
			Harvest_Time as MediaDate,
			Source_Category as SubMediaType,
			CreatedDate,
			ArticleID,
			Compete_Audience,
			IQAdShareValue,
			Compete_Result,
			homelink,
			PositiveSentiment,
			NegativeSentiment
			
    FROM @TempResults AS TempResults
    INNER JOIN ArchiveSM
    ON TempResults._ArchiveMediaID = ArchiveSM.ArchiveSMKey
    AND	TempResults.MediaType='SM'
   order by TempResults.ID asc
    
    -- Fill ArchiveTweets table
    
    SELECT 
			TempResults.ID,
			NULL as Title,
			Tweet_Body as HighlightingText,
			'TW',
			Tweet_PostedDateTime as MediaDate,
			CreatedDate,
			Tweet_ID,
			Actor_DisplayName, 
			Actor_PreferredUserName, 
			Actor_FollowersCount, 
			Actor_FriendsCount, 
			Actor_Image,
			Actor_link,
			gnip_Klout_Score,
			PositiveSentiment,
			NegativeSentiment

    FROM @TempResults AS TempResults
    INNER JOIN ArchiveTweets
    ON TempResults._ArchiveMediaID = ArchiveTweets.ArchiveTweets_Key
    AND	TempResults.MediaType='TW'
	order by TempResults.ID asc
	-- Fill ArchiveTVEyes table
    
    SELECT 
			TempResults.ID,
			Title,
			Transcript as HighlightingText,
			StationID,
			Market,
			DMARank,
			[UTCDateTime] as MediaDate,
			'Radio',
			CreatedDate,
			PositiveSentiment,
			NegativeSentiment
			
    FROM @TempResults AS TempResults
    INNER JOIN ArchiveTVEyes
    ON TempResults._ArchiveMediaID = ArchiveTVEyes.ArchiveTVEyesKey
    AND	TempResults.MediaType='TM'
	AND ArchiveTVEyes.IsDownLoaded = 1
	order by TempResults.ID asc
	
	SELECT	@TotalResults as TotalResults, @MaxSinceID as SinceID
   
END