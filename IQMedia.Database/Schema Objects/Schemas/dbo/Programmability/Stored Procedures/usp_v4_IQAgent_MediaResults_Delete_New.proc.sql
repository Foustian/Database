CREATE PROCEDURE [dbo].[usp_v4_IQAgent_MediaResults_Delete_New]
	@ID VARCHAR(MAX),
	@ClientGUID UNIQUEIDENTIFIER,
	@RowAffected INT OUTPUT
AS
BEGIN

	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
BEGIN TRY  		

	SET @ID=REPLACE(@ID,'''','')

	DECLARE @IDListTbl TABLE (ID BIGINT NOT NULL PRIMARY KEY)
	DECLARE	@GMT INT,
			@DST INT,
			@WDST INT
	
	SELECT
			@GMT= gmt,
			@DST=dst,
			@WDST=gmt+dst
	FROM
			 Client WHERE ClientGuid = @ClientGUID
	

	INSERT INTO @IDListTbl
	(	
		ID
	)
	SELECT ID FROM ufnGetIntTableFromStringsFn(@ID)
	
--#region MediaResult table var contains records to delete

	declare @TblSelectMR table
	(
		[ID] bigint not null,
		[_ParentID] bigint null
	)
	
	insert into @TblSelectMR
	(
		[ID],
		[_ParentID]
	)
	SELECT
		IQAgent_MediaResults.ID,		
		_ParentID		
	FROM
		@IDListTbl AS TmpIDList
			INNER JOIN IQAgent_MediaResults WITH(NOLOCK)
				ON		TmpIDList.ID=IQAgent_MediaResults.ID

	DECLARE @TblMediaResults TABLE
	(
		[ID] BIGINT NOT NULL,
		[_MediaID] BIGINT NOT NULL,
		[MediaType] VARCHAR(2) NOT NULL,
		[Category] VARCHAR(50) NOT NULL,
		[MediaDate] DATETIME NOT NULL,
		[_SearchRequestID] BIGINT NOT NULL,	
		[_ParentID] BIGINT NULL,
		[MediaDate_Date] DATE NOT NULL,
		[MediaDate_Hour] DATETIME NOT NULL,
		[LocalMediaDate] DATE NOT NULL,
		[PositiveSentiment] INT NULL,
		[NegativeSentiment] INT NULL
	)
	
	INSERT INTO @TblMediaResults
	(
		ID,
		_MediaID,
		MediaType,
		Category,
		MediaDate,
		_SearchRequestID,
		_ParentID,
		MediaDate_Date,
		MediaDate_Hour,
		LocalMediaDate,
		PositiveSentiment,
		NegativeSentiment
	)
	SELECT
		IQAgent_MediaResults.ID,
		_MediaID,
		MediaType,
		Category,
		MediaDate,
		_SearchRequestID,
		_ParentID,
		CONVERT(DATE,MediaDate),
		DATEADD (HOUR,DATEPART(HOUR,MediaDate), CONVERT(VARCHAR(10),MediaDate,101)),
		CASE WHEN dbo.fnIsDayLightSaving(IQAgent_MediaResults.MediaDate) = 1 THEN  DATEADD(HOUR,@WDST,IQAgent_MediaResults.MediaDate) ELSE DATEADD(HOUR,@GMT,IQAgent_MediaResults.MediaDate) END,
		ISNULL(PositiveSentiment,0),
		ISNULL(NegativeSentiment,0)
	FROM
		@IDListTbl AS TmpIDList
			INNER JOIN IQAgent_MediaResults WITH(NOLOCK)
				ON		TmpIDList.ID=IQAgent_MediaResults.ID
			INNER JOIN IQAgent_SearchRequest WITH(NOLOCK)
				ON		IQAgent_MediaResults._SearchRequestID=IQAgent_SearchRequest.ID
					AND	IQAgent_SearchRequest.ClientGUID=@ClientGUID
			WHERE
					IQAgent_MediaResults.IsActive=1
				AND	IQAgent_SearchRequest.IsActive=1
	UNION
	
	SELECT
		IQAgent_MediaResults.ID,
		_MediaID,
		MediaType,
		Category,
		MediaDate,
		_SearchRequestID,
		_ParentID,
		CONVERT(DATE,MediaDate),
		DATEADD (HOUR,DATEPART(HOUR,MediaDate), CONVERT(VARCHAR(10),MediaDate,101)),
		CASE WHEN dbo.fnIsDayLightSaving(IQAgent_MediaResults.MediaDate) = 1 THEN  DATEADD(HOUR,@WDST,IQAgent_MediaResults.MediaDate) ELSE DATEADD(HOUR,@GMT,IQAgent_MediaResults.MediaDate) END,
		PositiveSentiment,
		NegativeSentiment
	FROM
		@IDListTbl AS TmpIDList
			INNER JOIN IQAgent_MediaResults WITH(NOLOCK)
				ON		TmpIDList.ID=IQAgent_MediaResults._ParentID
			INNER JOIN IQAgent_SearchRequest WITH(NOLOCK)
				ON		IQAgent_MediaResults._SearchRequestID=IQAgent_SearchRequest.ID
					AND	IQAgent_SearchRequest.ClientGUID=@ClientGUID
			WHERE
					IQAgent_MediaResults.IsActive=1
				AND	IQAgent_SearchRequest.IsActive=1

--#endregion
	
	
--#region	Declaration of Temp Table DaySummary, DaySummaryLD and HourSummary
	
	CREATE TABLE #TmpDaySummaryResults 
	(
		[MediaDate] DATE NOT NULL,
		[ClientGUID] UNIQUEIDENTIFIER NOT NULL,
		[MediaType] VARCHAR(2) NOT NULL,
		[SubMediaType] VARCHAR(50),		
		[_SearchRequestID] BIGINT NOT NULL,
		[NoOfDocs] INT NOT NULL,
		[NoOfHits] BIGINT NOT NULL,
		[Audience] BIGINT NOT NULL,
		[MediaValue] DECIMAL(18,2) NOT NULL,
		[PositiveSentiment] BIGINT NOT NULL,
		[NegativeSentiment] BIGINT NOT NULL
	)
	
	CREATE TABLE #TmpDaySummaryLDResults 
	(
		[LocalMediaDate] DATE NOT NULL,
		[ClientGUID] UNIQUEIDENTIFIER NOT NULL,
		[MediaType] VARCHAR(2) NOT NULL,
		[SubMediaType] VARCHAR(50),		
		[_SearchRequestID] BIGINT NOT NULL,
		[NoOfDocs] INT NOT NULL,
		[NoOfHits] BIGINT NOT NULL,
		[Audience] BIGINT NOT NULL,
		[MediaValue] DECIMAL(18,2) NOT NULL,
		[PositiveSentiment] BIGINT NOT NULL,
		[NegativeSentiment] BIGINT NOT NULL
	)
	
	CREATE TABLE #TmpHourSummaryResults 
	(
		[MediaDateTime] DATETIME NOT NULL,
		[ClientGUID] UNIQUEIDENTIFIER NOT NULL,
		[MediaType] VARCHAR(2) NOT NULL,
		[SubMediaType] VARCHAR(50),		
		[_SearchRequestID] BIGINT NOT NULL,
		[NoOfDocs] INT NOT NULL,
		[NoOfHits] BIGINT NOT NULL,
		[Audience] BIGINT NOT NULL,
		[MediaValue] DECIMAL(18,2) NOT NULL,
		[PositiveSentiment] BIGINT NOT NULL,
		[NegativeSentiment] BIGINT NOT NULL
	)

--#endregion

--#region Temp Table DaySummary Insert
	
	--#region DS TV

	INSERT INTO #TmpDaySummaryResults
	(
		MediaDate,
		ClientGUID,
		MediaType,
		SubMediaType,
		_SearchRequestID,
		NoOfDocs,
		NoOfHits,
		Audience,
		MediaValue,
		PositiveSentiment,
		NegativeSentiment
	)
	SELECT 
			MediaDate_Date,
			@ClientGUID,
			MediaType,
			Category,
			_SearchRequestID,
			COUNT(IQAgent_TVResults.ID) AS NoOfDocs,
			SUM( ISNULL(IQAgent_TVResults.Number_Hits,0)) AS NoOfHits,
			SUM( ISNULL(Nielsen_Audience,0)) AS Audience,
			SUM( ISNULL(IQAdShareValue,0)) AS IQMediaValue,
			SUM( ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
			SUM( ISNULL(NegativeSentiment,0)) AS NegativeSentiment	
	FROM
			@TblMediaResults AS TblMR				
					INNER JOIN IQAgent_TVResults WITH(NOLOCK) 
						ON TblMR._MediaID = IQAgent_TVResults.ID
						AND TblMR.MediaType = 'TV'
						AND IQAgent_TVResults.IsActive = 1
	GROUP BY TblMR.MediaDate_Date,TblMR.MediaType,TblMR.Category,TblMR._SearchRequestID

--#endregion
		
	--#region DS NM
	
	INSERT INTO #TmpDaySummaryResults
	(
		MediaDate,
		ClientGUID,
		MediaType,
		SubMediaType,
		_SearchRequestID,
		NoOfDocs,
		NoOfHits,
		Audience,
		MediaValue,
		PositiveSentiment,
		NegativeSentiment
	)
	SELECT 
			MediaDate_Date,
			@ClientGUID,
			MediaType,
			TblMR.Category,
			_SearchRequestID,
			COUNT(IQAgent_NMResults.ID) AS NoOfDocs,
			SUM( ISNULL(IQAgent_NMResults.Number_Hits,0)) AS NoOfHits,
			SUM( ISNULL(Compete_Audience,0)) AS Audience,
			SUM( ISNULL(IQAdShareValue,0)) AS IQMediaValue,
			SUM( ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
			SUM( ISNULL(NegativeSentiment,0)) AS NegativeSentiment	
	FROM
			@TblMediaResults AS TblMR				
					INNER JOIN IQAgent_NMResults WITH(NOLOCK) 
						ON TblMR._MediaID = IQAgent_NMResults.ID
						AND TblMR.MediaType = 'NM'
						AND IQAgent_NMResults.IsActive = 1
	GROUP BY TblMR.MediaDate_Date,TblMR.MediaType,TblMR.Category,TblMR._SearchRequestID 

--#endregion
	
	--#region DS SM
	
	INSERT INTO #TmpDaySummaryResults
	(
		MediaDate,
		ClientGUID,
		MediaType,
		SubMediaType,
		_SearchRequestID,
		NoOfDocs,
		NoOfHits,
		Audience,
		MediaValue,
		PositiveSentiment,
		NegativeSentiment
	)
	SELECT 
			MediaDate_Date,
			@ClientGUID,
			MediaType,
			TblMR.Category,
			_SearchRequestID,
			COUNT(IQAgent_SMResults.ID) AS NoOfDocs,
			SUM( ISNULL(IQAgent_SMResults.Number_Hits,0)) AS NoOfHits,
			SUM( ISNULL(Compete_Audience,0)) AS Audience,
			SUM( ISNULL(IQAdShareValue,0)) AS IQMediaValue,
			SUM( ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
			SUM( ISNULL(NegativeSentiment,0)) AS NegativeSentiment	
	FROM
			@TblMediaResults AS TblMR				
					INNER JOIN IQAgent_SMResults WITH(NOLOCK)
						ON TblMR._MediaID = IQAgent_SMResults.ID
						AND TblMR.MediaType = 'SM'
						AND IQAgent_SMResults.IsActive = 1
	GROUP BY TblMR.MediaDate_Date,TblMR.MediaType,TblMR.Category,TblMR._SearchRequestID

--#endregion

	--#region DS TW

	INSERT INTO #TmpDaySummaryResults
	(
		MediaDate,
		ClientGUID,
		MediaType,
		SubMediaType,
		_SearchRequestID,
		NoOfDocs,
		NoOfHits,
		Audience,
		MediaValue,
		PositiveSentiment,
		NegativeSentiment
	)
	SELECT 
			MediaDate_Date,
			@ClientGUID,
			MediaType,
			TblMR.Category,
			_SearchRequestID,
			COUNT(IQAgent_TwitterResults.ID) AS NoOfDocs,
			SUM( ISNULL(IQAgent_TwitterResults.Number_Hits,0)) AS NoOfHits,
			SUM( ISNULL(actor_followersCount,0)) AS Audience,
			SUM( ISNULL(gnip_klout_score,0)) AS IQMediaValue,
			SUM( ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
			SUM( ISNULL(NegativeSentiment,0)) AS NegativeSentiment	
	FROM
			@TblMediaResults AS TblMR				
					INNER JOIN IQAgent_TwitterResults WITH(NOLOCK)
							ON TblMR._MediaID = IQAgent_TwitterResults.ID
							AND TblMR.MediaType = 'TW'
						AND IQAgent_TwitterResults.IsActive = 1
	GROUP BY TblMR.MediaDate_Date,TblMR.MediaType,TblMR.Category,TblMR._SearchRequestID

--#endregion

--#region DS TM

	INSERT INTO #TmpDaySummaryResults
	(
		MediaDate,
		ClientGUID,
		MediaType,
		SubMediaType,
		_SearchRequestID,
		NoOfDocs,
		NoOfHits,
		Audience,
		MediaValue,
		PositiveSentiment,
		NegativeSentiment
	)
	SELECT 
			MediaDate_Date,
			@ClientGUID,
			MediaType,
			TblMR.Category,
			_SearchRequestID,
			COUNT(IQAgent_TVEyesResults.ID) AS NoOfDocs,
			0 AS NoOfHits,
			0 AS Audience,
			0 AS IQMediaValue,
			SUM(ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
			SUM(ISNULL(NegativeSentiment,0)) AS NegativeSentiment	
	FROM
			@TblMediaResults AS TblMR				
					INNER JOIN IQAgent_TVEyesResults WITH(NOLOCK)
						ON TblMR._MediaID = IQAgent_TVEyesResults.ID
						AND TblMR.MediaType = 'TM'
						AND IQAgent_TVEyesResults.IsActive = 1
	GROUP BY TblMR.MediaDate_Date,TblMR.MediaType,TblMR.Category,TblMR._SearchRequestID	

--#endregion	
	
	--#region DS PM

	INSERT INTO #TmpDaySummaryResults
	(
		MediaDate,
		ClientGUID,
		MediaType,
		SubMediaType,
		_SearchRequestID,
		NoOfDocs,
		NoOfHits,
		Audience,
		MediaValue,
		PositiveSentiment,
		NegativeSentiment
	)
	SELECT 
			MediaDate_Date,
			@ClientGUID,
			MediaType,
			TblMR.Category,
			_SearchRequestID,
			COUNT(IQAgent_BLPMResults.ID) AS NoOfDocs,
			0 AS NoOfHits,
			SUM( ISNULL(IQAgent_BLPMResults.Circulation,0)) AS Audience,
			0 AS IQMediaValue,
			SUM(ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
			SUM(ISNULL(NegativeSentiment,0)) AS NegativeSentiment	
	FROM
			@TblMediaResults AS TblMR				
					INNER JOIN IQAgent_BLPMResults WITH(NOLOCK)
						ON TblMR._MediaID = IQAgent_BLPMResults.ID
						AND TblMR.MediaType = 'PM'
						AND IQAgent_BLPMResults.IsActive = 1
	GROUP BY TblMR.MediaDate_Date,TblMR.MediaType,TblMR.Category,TblMR._SearchRequestID

--#endregion
	

--#endregion			
	
	--#region Temp Table DaySummary LD Insert

	
	--#region DS LD TV
	
	INSERT INTO #TmpDaySummaryLDResults
	(
		LocalMediaDate,
		ClientGUID,
		MediaType,
		SubMediaType,
		_SearchRequestID,
		NoOfDocs,
		NoOfHits,
		Audience,
		MediaValue,
		PositiveSentiment,
		NegativeSentiment
	)
	SELECT 
			TblMR.LocalMediaDate,
			@ClientGUID,
			MediaType,
			Category,
			_SearchRequestID,
			COUNT(IQAgent_TVResults.ID) AS NoOfDocs,
			SUM( ISNULL(IQAgent_TVResults.Number_Hits,0)) AS NoOfHits,
			SUM( ISNULL(Nielsen_Audience,0)) AS Audience,
			SUM( ISNULL(IQAdShareValue,0)) AS IQMediaValue,
			SUM( ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
			SUM( ISNULL(NegativeSentiment,0)) AS NegativeSentiment	
	FROM
			@TblMediaResults AS TblMR				
					INNER JOIN IQAgent_TVResults WITH(NOLOCK) 
						ON TblMR._MediaID = IQAgent_TVResults.ID
						AND TblMR.MediaType = 'TV'
						AND IQAgent_TVResults.IsActive = 1
	GROUP BY TblMR.LocalMediaDate,TblMR.MediaType,TblMR.Category,TblMR._SearchRequestID   

--#endregion
	
	--#region DS LD NM
	
	INSERT INTO #TmpDaySummaryLDResults
	(
		LocalMediaDate,
		ClientGUID,
		MediaType,
		SubMediaType,
		_SearchRequestID,
		NoOfDocs,
		NoOfHits,
		Audience,
		MediaValue,
		PositiveSentiment,
		NegativeSentiment
	)
	SELECT 
			TblMR.LocalMediaDate,
			@ClientGUID,
			MediaType,
			TblMR.Category,
			_SearchRequestID,
			COUNT(IQAgent_NMResults.ID) AS NoOfDocs,
			SUM( ISNULL(IQAgent_NMResults.Number_Hits,0)) AS NoOfHits,
			SUM( ISNULL(Compete_Audience,0)) AS Audience,
			SUM( ISNULL(IQAdShareValue,0)) AS IQMediaValue,
			SUM( ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
			SUM( ISNULL(NegativeSentiment,0)) AS NegativeSentiment	
	FROM
			@TblMediaResults AS TblMR				
					INNER JOIN IQAgent_NMResults WITH(NOLOCK) 
						ON TblMR._MediaID = IQAgent_NMResults.ID
						AND TblMR.MediaType = 'NM'
						AND IQAgent_NMResults.IsActive = 1
	GROUP BY TblMR.LocalMediaDate,TblMR.MediaType,TblMR.Category,TblMR._SearchRequestID  

--#endregion
	
	--#region DS LD SM

	INSERT INTO #TmpDaySummaryLDResults
	(
		LocalMediaDate,
		ClientGUID,
		MediaType,
		SubMediaType,
		_SearchRequestID,
		NoOfDocs,
		NoOfHits,
		Audience,
		MediaValue,
		PositiveSentiment,
		NegativeSentiment
	)
	SELECT 
			TblMR.LocalMediaDate,
			@ClientGUID,
			MediaType,
			TblMR.Category,
			_SearchRequestID,
			COUNT(IQAgent_SMResults.ID) AS NoOfDocs,
			SUM( ISNULL(IQAgent_SMResults.Number_Hits,0)) AS NoOfHits,
			SUM( ISNULL(Compete_Audience,0)) AS Audience,
			SUM( ISNULL(IQAdShareValue,0)) AS IQMediaValue,
			SUM( ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
			SUM( ISNULL(NegativeSentiment,0)) AS NegativeSentiment	
	FROM
			@TblMediaResults AS TblMR				
					INNER JOIN IQAgent_SMResults WITH(NOLOCK)
						ON TblMR._MediaID = IQAgent_SMResults.ID
						AND TblMR.MediaType = 'SM'
						AND IQAgent_SMResults.IsActive = 1
	GROUP BY TblMR.LocalMediaDate,TblMR.MediaType,TblMR.Category,TblMR._SearchRequestID

--#endregion
	
	--#region DS LD TW

	INSERT INTO #TmpDaySummaryLDResults
	(
		LocalMediaDate,
		ClientGUID,
		MediaType,
		SubMediaType,
		_SearchRequestID,
		NoOfDocs,
		NoOfHits,
		Audience,
		MediaValue,
		PositiveSentiment,
		NegativeSentiment
	)
	SELECT 
			TblMR.LocalMediaDate,
			@ClientGUID,
			MediaType,
			TblMR.Category,
			_SearchRequestID,
			COUNT(IQAgent_TwitterResults.ID) AS NoOfDocs,
			SUM( ISNULL(IQAgent_TwitterResults.Number_Hits,0)) AS NoOfHits,
			SUM( ISNULL(actor_followersCount,0)) AS Audience,
			SUM( ISNULL(gnip_klout_score,0)) AS IQMediaValue,
			SUM( ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
			SUM( ISNULL(NegativeSentiment,0)) AS NegativeSentiment	
	FROM
			@TblMediaResults AS TblMR				
					INNER JOIN IQAgent_TwitterResults WITH(NOLOCK)
							ON TblMR._MediaID = IQAgent_TwitterResults.ID
							AND TblMR.MediaType = 'TW'
						AND IQAgent_TwitterResults.IsActive = 1
	GROUP BY TblMR.LocalMediaDate,TblMR.MediaType,TblMR.Category,TblMR._SearchRequestID	

--#endregion

--#region DS LD TM


	INSERT INTO #TmpDaySummaryLDResults
	(
		LocalMediaDate,
		ClientGUID,
		MediaType,
		SubMediaType,
		_SearchRequestID,
		NoOfDocs,
		NoOfHits,
		Audience,
		MediaValue,
		PositiveSentiment,
		NegativeSentiment
	)
	SELECT 
			TblMR.LocalMediaDate,
			@ClientGUID,
			MediaType,
			TblMR.Category,
			_SearchRequestID,
			COUNT(IQAgent_TVEyesResults.ID) AS NoOfDocs,
			0 AS NoOfHits,
			0 AS Audience,
			0 AS IQMediaValue,
			SUM(ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
			SUM(ISNULL(NegativeSentiment,0)) AS NegativeSentiment	
	FROM
			@TblMediaResults AS TblMR				
					INNER JOIN IQAgent_TVEyesResults WITH(NOLOCK)
						ON TblMR._MediaID = IQAgent_TVEyesResults.ID
						AND TblMR.MediaType = 'TM'
						AND IQAgent_TVEyesResults.IsActive = 1
	GROUP BY TblMR.LocalMediaDate,TblMR.MediaType,TblMR.Category,TblMR._SearchRequestID	

--#endregion

	--#region DS LD PM

	INSERT INTO #TmpDaySummaryLDResults
	(
		LocalMediaDate,
		ClientGUID,
		MediaType,
		SubMediaType,
		_SearchRequestID,
		NoOfDocs,
		NoOfHits,
		Audience,
		MediaValue,
		PositiveSentiment,
		NegativeSentiment
	)
	SELECT 
			TblMR.LocalMediaDate,
			@ClientGUID,
			MediaType,
			TblMR.Category,
			_SearchRequestID,
			COUNT(IQAgent_BLPMResults.ID) AS NoOfDocs,
			0 AS NoOfHits,
			SUM( ISNULL(IQAgent_BLPMResults.Circulation,0)) AS Audience,
			0 AS IQMediaValue,
			SUM(ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
			SUM(ISNULL(NegativeSentiment,0)) AS NegativeSentiment	
	FROM
			@TblMediaResults AS TblMR				
					INNER JOIN IQAgent_BLPMResults WITH(NOLOCK)
						ON TblMR._MediaID = IQAgent_BLPMResults.ID
						AND TblMR.MediaType = 'PM'
						AND IQAgent_BLPMResults.IsActive = 1
	GROUP BY TblMR.LocalMediaDate,TblMR.MediaType,TblMR.Category,TblMR._SearchRequestID

--#endregion
	
	--#endregion
	
	
--#region Temp Table HourSummary Insert

	
	--#region HS TV
	
	INSERT INTO #TmpHourSummaryResults
	(
		MediaDateTime,
		ClientGUID,
		MediaType,
		SubMediaType,
		_SearchRequestID,
		NoOfDocs,
		NoOfHits,
		Audience,
		MediaValue,
		PositiveSentiment,
		NegativeSentiment
	)
	SELECT 
			MediaDate_Hour,
			@ClientGUID,
			MediaType,
			Category,
			_SearchRequestID,
			COUNT(IQAgent_TVResults.ID) AS NoOfDocs,
			SUM( ISNULL(IQAgent_TVResults.Number_Hits,0)) AS NoOfHits,
			SUM( ISNULL(Nielsen_Audience,0)) AS Audience,
			SUM( ISNULL(IQAdShareValue,0)) AS IQMediaValue,
			SUM( ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
			SUM( ISNULL(NegativeSentiment,0)) AS NegativeSentiment	
	FROM
			@TblMediaResults AS TblMR
					INNER JOIN IQAgent_TVResults WITH(NOLOCK) 
						ON TblMR._MediaID = IQAgent_TVResults.ID
						AND TblMR.MediaType = 'TV'
						AND IQAgent_TVResults.IsActive = 1
	GROUP BY TblMR.MediaDate_Hour,TblMR.MediaType,TblMR.Category,TblMR._SearchRequestID 
	
--#endregion
		
	--#region HS NM
	
	INSERT INTO #TmpHourSummaryResults
	(
		MediaDateTime,
		ClientGUID,
		MediaType,
		SubMediaType,
		_SearchRequestID,
		NoOfDocs,
		NoOfHits,
		Audience,
		MediaValue,
		PositiveSentiment,
		NegativeSentiment
	)
	SELECT 
			MediaDate_Hour,
			@ClientGUID,
			MediaType,
			TblMR.Category,
			_SearchRequestID,
			COUNT(IQAgent_NMResults.ID) AS NoOfDocs,
			SUM( ISNULL(IQAgent_NMResults.Number_Hits,0)) AS NoOfHits,
			SUM( ISNULL(Compete_Audience,0)) AS Audience,
			SUM( ISNULL(IQAdShareValue,0)) AS IQMediaValue,
			SUM( ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
			SUM( ISNULL(NegativeSentiment,0)) AS NegativeSentiment	
	FROM
			@TblMediaResults AS TblMR
					INNER JOIN IQAgent_NMResults WITH(NOLOCK) 
						ON TblMR._MediaID = IQAgent_NMResults.ID
						AND TblMR.MediaType = 'NM'
						AND IQAgent_NMResults.IsActive = 1
	GROUP BY TblMR.MediaDate_Hour,TblMR.MediaType,TblMR.Category,TblMR._SearchRequestID  
	
--#endregion
		
	--#region HS SM

	INSERT INTO #TmpHourSummaryResults
	(
		MediaDateTime,
		ClientGUID,
		MediaType,
		SubMediaType,
		_SearchRequestID,
		NoOfDocs,
		NoOfHits,
		Audience,
		MediaValue,
		PositiveSentiment,
		NegativeSentiment
	)
	SELECT 
			MediaDate_Hour,
			@ClientGUID,
			MediaType,
			TblMR.Category,
			_SearchRequestID,
			COUNT(IQAgent_SMResults.ID) AS NoOfDocs,
			SUM( ISNULL(IQAgent_SMResults.Number_Hits,0)) AS NoOfHits,
			SUM( ISNULL(Compete_Audience,0)) AS Audience,
			SUM( ISNULL(IQAdShareValue,0)) AS IQMediaValue,
			SUM( ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
			SUM( ISNULL(NegativeSentiment,0)) AS NegativeSentiment	
	FROM
			@TblMediaResults AS TblMR				
					INNER JOIN IQAgent_SMResults WITH(NOLOCK)
						ON TblMR._MediaID = IQAgent_SMResults.ID
						AND TblMR.MediaType = 'SM'
						AND IQAgent_SMResults.IsActive = 1
	GROUP BY TblMR.MediaDate_Hour,TblMR.MediaType,TblMR.Category,TblMR._SearchRequestID

--#endregion
		
	--#region HS TW

	INSERT INTO #TmpHourSummaryResults
	(
		MediaDateTime,
		ClientGUID,
		MediaType,
		SubMediaType,
		_SearchRequestID,
		NoOfDocs,
		NoOfHits,
		Audience,
		MediaValue,
		PositiveSentiment,
		NegativeSentiment
	)
	SELECT 
			MediaDate_Hour,
			@ClientGUID,
			MediaType,
			TblMR.Category,
			_SearchRequestID,
			COUNT(IQAgent_TwitterResults.ID) AS NoOfDocs,
			SUM( ISNULL(IQAgent_TwitterResults.Number_Hits,0)) AS NoOfHits,
			SUM( ISNULL(actor_followersCount,0)) AS Audience,
			SUM( ISNULL(gnip_klout_score,0)) AS IQMediaValue,
			SUM( ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
			SUM( ISNULL(NegativeSentiment,0)) AS NegativeSentiment	
	FROM
			@TblMediaResults AS TblMR				
					INNER JOIN IQAgent_TwitterResults WITH(NOLOCK)
							ON TblMR._MediaID = IQAgent_TwitterResults.ID
							AND TblMR.MediaType = 'TW'
						AND IQAgent_TwitterResults.IsActive = 1
	GROUP BY TblMR.MediaDate_Hour,TblMR.MediaType,TblMR.Category,TblMR._SearchRequestID

--#endregion
	
	--#region HS TM

	INSERT INTO #TmpHourSummaryResults
	(
		MediaDateTime,
		ClientGUID,
		MediaType,
		SubMediaType,
		_SearchRequestID,
		NoOfDocs,
		NoOfHits,
		Audience,
		MediaValue,
		PositiveSentiment,
		NegativeSentiment
	)
	SELECT 
			MediaDate_Hour,
			@ClientGUID,
			MediaType,
			TblMR.Category,
			_SearchRequestID,
			COUNT(IQAgent_TVEyesResults.ID) AS NoOfDocs,
			0 AS NoOfHits,
			0 AS Audience,
			0 AS IQMediaValue,
			SUM(ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
			SUM(ISNULL(NegativeSentiment,0)) AS NegativeSentiment	
	FROM
			@TblMediaResults AS TblMR
					INNER JOIN IQAgent_TVEyesResults WITH(NOLOCK)
						ON TblMR._MediaID = IQAgent_TVEyesResults.ID
						AND TblMR.MediaType = 'TM'
						AND IQAgent_TVEyesResults.IsActive = 1
	GROUP BY TblMR.MediaDate_Hour,TblMR.MediaType,TblMR.Category,TblMR._SearchRequestID	

--#endregion

	--#region HS PM
	
	INSERT INTO #TmpHourSummaryResults
	(
		MediaDateTime,
		ClientGUID,
		MediaType,
		SubMediaType,
		_SearchRequestID,
		NoOfDocs,
		NoOfHits,
		Audience,
		MediaValue,
		PositiveSentiment,
		NegativeSentiment
	)
	SELECT 
			MediaDate_Hour,
			@ClientGUID,
			MediaType,
			TblMR.Category,
			_SearchRequestID,
			COUNT(IQAgent_BLPMResults.ID) AS NoOfDocs,
			0 AS NoOfHits,
			SUM( ISNULL(IQAgent_BLPMResults.Circulation,0)) AS Audience,
			0 AS IQMediaValue,
			SUM(ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
			SUM(ISNULL(NegativeSentiment,0)) AS NegativeSentiment	
	FROM
			@TblMediaResults AS TblMR
					INNER JOIN IQAgent_BLPMResults WITH(NOLOCK)
						ON TblMR._MediaID = IQAgent_BLPMResults.ID
						AND TblMR.MediaType = 'PM'
						AND IQAgent_BLPMResults.IsActive = 1
	GROUP BY TblMR.MediaDate_Hour,TblMR.MediaType,TblMR.Category,TblMR._SearchRequestID

--#endregion
	

--#endregion
	
	BEGIN TRANSACTION;   
	
		--#region UPDLock
	
		DECLARE @DayTbl TABLE(ID BIGINT)
		
		INSERT INTO @DayTbl
		(
			ID
		)
		SELECT
					IQDay.ID
		FROM
				IQAgent_DaySummary AS IQDay WITH(UPDLOCK)
					INNER JOIN #TmpDaySummaryResults AS TmpDSR
						 ON		
								 IQDay.DayDate = TmpDSR.MediaDate
							AND IQDay.SubMediaType = TmpDSR.SubMediaType
							AND IQDay._SearchRequestID = TmpDSR._SearchRequestID    
							AND IQDay.ClientGuid = @ClientGUID
							
		DECLARE @HourTbl TABLE(ID BIGINT)
		
		INSERT INTO @HourTbl
		(
			ID
		)
		SELECT
				DISTINCT IQHour.ID
		FROM
				IQAgent_HourSummary AS IQHour WITH(UPDLOCK)
					INNER JOIN #TmpHourSummaryResults AS TmpHSR 
						 ON		
								 IQHour.HourDateTime = TmpHSR.MediaDateTime
							AND IQHour.SubMediaType = TmpHSR.SubMediaType
							AND IQHour._SearchRequestID = TmpHSR._SearchRequestID    
							AND IQHour.ClientGuid = @ClientGUID
			
		DECLARE @DayLDTbl TABLE(ID BIGINT)
		
		INSERT INTO @DayLDTbl
		(
			ID
		)
		SELECT
					IQDay.ID	
		FROM
				IQAgent_DaySummary AS IQDay WITH(UPDLOCK)
					INNER JOIN #TmpDaySummaryLDResults AS TmpDSLDR
						  ON		IQDay.DayDate = TmpDSLDR.LocalMediaDate
							AND IQDay.SubMediaType = TmpDSLDR.SubMediaType
							AND IQDay._SearchRequestID = TmpDSLDR._SearchRequestID    
							AND IQDay.ClientGuid = @ClientGUID			
							
		DECLARE @TmpMR TABLE(ID BIGINT)
		
		INSERT INTO @TmpMR
		(
			ID
		)
		SELECT
			IQAgent_MediaResults.ID
		FROM @TblMediaResults AS TblMR
				INNER JOIN IQAgent_MediaResults WITH (UPDLOCK)								
					ON IQAgent_MediaResults.ID=TblMR.ID	
					
		DECLARE @TmpTWR TABLE(ID BIGINT)
		
		INSERT INTO @TmpTWR
		(
			ID
		)
		SELECT
			IQAgent_TwitterResults.ID
		FROM @TblMediaResults AS TblMR
				INNER JOIN	IQAgent_MediaResults WITH(NOLOCK)
					ON		TblMR.ID=IQAgent_MediaResults.ID
				INNER JOIN	IQAgent_TwitterResults WITH(UPDLOCK)
					ON		IQAgent_MediaResults._MediaID = IQAgent_TwitterResults.ID
						AND IQAgent_MediaResults.MediaType = 'TW'
						
		DECLARE @TmpNMR TABLE(ID BIGINT)
		
		INSERT INTO @TmpNMR
		(
			ID
		)
		SELECT
			IQAgent_NMResults.ID
		FROM	@TblMediaResults AS TblMR
					INNER JOIN	IQAgent_MediaResults WITH(NOLOCK)
						ON		TblMR.ID=IQAgent_MediaResults.ID
					INNER JOIN	IQAgent_NMResults WITH(UPDLOCK)
						ON		IQAgent_MediaResults._MediaID = IQAgent_NMResults.ID
							AND IQAgent_MediaResults.MediaType = 'NM'

		DECLARE @TmpSMR TABLE(ID BIGINT)
		
		INSERT INTO @TmpSMR
		(
			ID
		)
		SELECT
			IQAgent_SMResults.ID
		FROM @TblMediaResults AS TblMR
					INNER JOIN	IQAgent_MediaResults WITH(NOLOCK)
						ON		TblMR.ID=IQAgent_MediaResults.ID
					INNER JOIN IQAgent_SMResults WITH(UPDLOCK)
						ON		IQAgent_MediaResults._MediaID = IQAgent_SMResults.ID
							AND IQAgent_MediaResults.MediaType = 'SM'
			
		DECLARE @TmpTVR TABLE(ID BIGINT)
		
		INSERT INTO @TmpTVR
		(
			ID
		)
		SELECT
			IQAgent_TVResults.ID
		FROM	@TblMediaResults AS TblMR
					INNER JOIN	IQAgent_MediaResults WITH(NOLOCK)
						ON		TblMR.ID=IQAgent_MediaResults.ID
					INNER JOIN	IQAgent_TVResults WITH(UPDLOCK)
						ON		IQAgent_MediaResults._MediaID = IQAgent_TVResults.ID
							AND IQAgent_MediaResults.MediaType = 'TV'

		DECLARE @TmpTVER TABLE(ID BIGINT)
		
		INSERT INTO @TmpTVER
		(
			ID
		)
		SELECT
			IQAgent_TVEyesResults.ID
		FROM	@TblMediaResults AS TblMR
					INNER JOIN	IQAgent_MediaResults WITH(NOLOCK)
						ON		TblMR.ID=IQAgent_MediaResults.ID							
					INNER JOIN	IQAgent_TVEyesResults WITH(UPDLOCK)
						ON		IQAgent_MediaResults._MediaID = IQAgent_TVEyesResults.ID
							AND IQAgent_MediaResults.MediaType = 'TM'
			
		DECLARE @TmpBLPMR TABLE(ID BIGINT)
		
		INSERT INTO @TmpBLPMR
		(
			ID
		)
		SELECT
			iqagent_blpmresults.ID
		FROM	@TblMediaResults AS TblMR
					INNER JOIN	IQAgent_MediaResults WITH(NOLOCK)
						ON		TblMR.ID=IQAgent_MediaResults.ID
					INNER JOIN	iqagent_blpmresults WITH(UPDLOCK)
						ON		IQAgent_MediaResults._MediaID = iqagent_blpmresults.ID
							AND	IQAgent_MediaResults.MediaType = 'PM'
	
		--#endregion 
	
		UPDATE IQAgent_TwitterResults
		SET IsActive = 0,
		ModifiedDate = GETDATE()
		
		FROM @TblMediaResults AS TblMR				
				INNER JOIN IQAgent_TwitterResults
					ON		TblMR._MediaID = IQAgent_TwitterResults.ID
						AND TblMR.MediaType = 'TW'
		
		
		--------------
									
		UPDATE IQAgent_NMResults
		SET IsActive = 0,
		ModifiedDate = GETDATE()
		
		FROM @TblMediaResults AS TblMR				
				INNER JOIN IQAgent_NMResults
					ON		TblMR._MediaID = IQAgent_NMResults.ID
						AND TblMR.MediaType = 'NM'
		
		--------------
		
		UPDATE IQAgent_SMResults
		SET IsActive = 0,
		ModifiedDate = GETDATE()
		
		FROM @TblMediaResults AS TblMR				
				INNER JOIN IQAgent_SMResults
					ON		TblMR._MediaID = IQAgent_SMResults.ID
						AND TblMR.MediaType = 'SM'
		
		----------------------
		
		UPDATE IQAgent_TVResults
		SET IsActive = 0,
		ModifiedDate = GETDATE()
		
		FROM @TblMediaResults AS TblMR				
				INNER JOIN IQAgent_TVResults
					ON		TblMR._MediaID = IQAgent_TVResults.ID
						AND TblMR.MediaType = 'TV'
		
		--------------------------
		
		UPDATE IQAgent_TVEyesResults
		SET IsActive = 0,
		ModifiedDate = GETDATE()
		
		FROM @TblMediaResults AS TblMR				
				INNER JOIN IQAgent_TVEyesResults
					ON		TblMR._MediaID = IQAgent_TVEyesResults.ID
						AND TblMR.MediaType = 'TM'
						
		--------------------------
		
		UPDATE iqagent_blpmresults
		SET IsActive = 0,
		ModifiedDate = GETDATE()
		
		FROM @TblMediaResults AS TblMR				
				INNER JOIN iqagent_blpmresults
					ON		TblMR._MediaID = iqagent_blpmresults.ID
						AND TblMR.MediaType = 'PM'
		
		UPDATE IQAgent_MediaResults
				SET IsActive = 0
			FROM @TblMediaResults AS TblMR
				INNER JOIN IQAgent_MediaResults 						
					ON TblMR.ID=IQAgent_MediaResults.ID							
					

		SELECT @RowAffected = @@ROWCOUNT
		
												
		UPDATE 
				IQDay
		SET
			IQDay.NoOfDocs =  IQDay.NoOfDocs - TmpDSR.NoOfDocs, 
			IQDay.NoOfHits = IQDay.NoOfHits - TmpDSR.NoOfHits,
			IQDay.Audience = IQDay.Audience - TmpDSR.Audience,
			IQDay.IQMediaValue = IQDay.IQMediaValue - TmpDSR.MediaValue,
			IQDay.PositiveSentiment = IQDay.PositiveSentiment - TmpDSR.PositiveSentiment,
			IQDay.NegativeSentiment = IQDay.NegativeSentiment - TmpDSR.NegativeSentiment
		FROM	IQAgent_DaySummary AS IQDay 
					INNER JOIN #TmpDaySummaryResults AS TmpDSR
						 ON		IQDay.DayDate = TmpDSR.MediaDate
							AND IQDay.SubMediaType = TmpDSR.SubMediaType
							AND IQDay._SearchRequestID = TmpDSR._SearchRequestID    
							AND IQDay.ClientGuid = @ClientGUID
		
		DROP TABLE #TmpDaySummaryResults		
		
		UPDATE 
				IQHour
		SET
			IQHour.NoOfDocs =  IQHour.NoOfDocs - TmpHSR.NoOfDocs, 
			IQHour.NoOfHits = IQHour.NoOfHits - TmpHSR.NoOfHits,
			IQHour.Audience = IQHour.Audience - TmpHSR.Audience,
			IQHour.IQMediaValue = IQHour.IQMediaValue - TmpHSR.MediaValue,
			IQHour.PositiveSentiment = IQHour.PositiveSentiment - TmpHSR.PositiveSentiment,
			IQHour.NegativeSentiment = IQHour.NegativeSentiment - TmpHSR.NegativeSentiment
		FROM	IQAgent_HourSummary AS IQHour 
					INNER JOIN #TmpHourSummaryResults AS TmpHSR
						 ON		IQHour.HourDateTime = TmpHSR.MediaDateTime
							AND IQHour.SubMediaType = TmpHSR.SubMediaType
							AND IQHour._SearchRequestID = TmpHSR._SearchRequestID    
							AND IQHour.ClientGuid = @ClientGUID
		
		DROP TABLE #TmpHourSummaryResults
		
		UPDATE 
			IQDay
		SET
			IQDay.NoOfDocsLD =  IQDay.NoOfDocsLD - TmpDSLDR.NoOfDocs, 
			IQDay.NoOfHitsLD = IQDay.NoOfHitsLD - TmpDSLDR.NoOfHits,
			IQDay.AudienceLD = IQDay.AudienceLD - TmpDSLDR.Audience,
			IQDay.IQMediaValueLD = IQDay.IQMediaValueLD - TmpDSLDR.MediaValue,
			IQDay.PositiveSentimentLD = IQDay.PositiveSentimentLD - TmpDSLDR.PositiveSentiment,
			IQDay.NegativeSentimentLD = IQDay.NegativeSentimentLD - TmpDSLDR.NegativeSentiment
		FROM	IQAgent_DaySummary AS IQDay 
					INNER JOIN #TmpDaySummaryLDResults AS TmpDSLDR
						  ON		IQDay.DayDate = TmpDSLDR.LocalMediaDate
							AND IQDay.SubMediaType = TmpDSLDR.SubMediaType
							AND IQDay._SearchRequestID = TmpDSLDR._SearchRequestID    
							AND IQDay.ClientGuid = @ClientGUID
		
		DROP TABLE #TmpDaySummaryLDResults
	
			COMMIT TRANSACTION;        
		END TRY
		BEGIN CATCH
		
			IF(@@TRANCOUNT>0)
			BEGIN		          
				ROLLBACK TRANSACTION;  
			END
			
			SELECT @RowAffected = 0  
			
			DECLARE @IQMediaGroupExceptionKey BIGINT,
			@ExceptionStackTrace VARCHAR(500),
			@ExceptionMessage VARCHAR(500),
			@CreatedBy	VARCHAR(50),
			@ModifiedBy	VARCHAR(50),
			@CreatedDate	DATETIME,
			@ModifiedDate	DATETIME,
			@IsActive	BIT
			
	
			SELECT 
				@ExceptionStackTrace=(ERROR_PROCEDURE()+'_'+CONVERT(VARCHAR(50),ERROR_LINE())),
				@ExceptionMessage=CONVERT(VARCHAR(50),ERROR_NUMBER())+'_'+ERROR_MESSAGE(),
				@CreatedBy='usp_v4_IQAgent_MediaResults_Delete',
				@ModifiedBy='usp_v4_IQAgent_MediaResults_Delete',
				@CreatedDate=GETDATE(),
				@ModifiedDate=GETDATE(),
				@IsActive=1
	

				EXEC usp_IQMediaGroupExceptions_Insert @ExceptionStackTrace,@ExceptionMessage,@CreatedBy,@CreatedDate,NULL,@IQMediaGroupExceptionKey OUTPUT    
		END CATCH        
						
		DECLARE @MultiPlier FLOAT
		SELECT @MultiPlier = CONVERT(FLOAT,ISNULL((SELECT VALUE FROM IQClient_CustomSettings WHERE Field = 'Multiplier' AND _ClientGuid = '' + CAST(@clientGUID AS VARCHAR(40)) + ''),(SELECT VALUE FROM IQClient_CustomSettings WHERE Field = 'Multiplier' AND _ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER))))

		SELECT distinct 
			tmp.ID,
			ISNULL(tmp.PositiveSentiment,0) AS 'PositiveSentiment' ,
			ISNULL(tmp.NegativeSentiment,0) AS 'NegativeSentiment',
			tmp.Title AS 'Title120',
			tmp.MediaDate AS 'Date',
			CONVERT(DATETIME,CONVERT(VARCHAR(MAX),IQAgent_TVResults.RL_Date,101) + ' '+ REPLACE(CONVERT(VARCHAR(MAX),CONVERT(DECIMAL(4,2),(CONVERT(DECIMAL(6,2),IQAgent_TVResults.RL_Time)/CONVERT(DECIMAL(5,2),100)))),'.',':')+':00') AS 'RL_DateTime',
			--IQAgent_TVResults.RL_Date as ''Date'',					
			CONVERT(NVARCHAR(MAX),tmp.HighlightingText) AS 'HighlightingText',					
			IQAgent_TVResults.RL_Station,
			IQAgent_TVResults.RawMediaThumbUrl,
			IQAgent_TVResults.RL_VideoGUID,
			tmp.Category,
			Nielsen_Audience,
			IQAdShareValue,
			Nielsen_Result,
			RL_Market,
			IQ_Station.TimeZone AS 'TimeZone',
			IQ_Station.Dma_Num,
			(SELECT SUM(IQSSP_NationalNielsen.Audience) FROM IQSSP_NationalNielsen WHERE LocalDate = IQAgent_TVResults.RL_Date AND Title120 = tmp.Title AND Station_Affil = IQ_Station.Station_Affil) AS National_Nielsen_Audience,
			(SELECT (SUM(IQSSP_NationalNielsen.MediaValue) * @MultiPlier) FROM IQSSP_NationalNielsen WHERE LocalDate = IQAgent_TVResults.RL_Date AND Title120 = tmp.Title AND Station_Affil = IQ_Station.Station_Affil) AS National_IQAdShareValue,
			(SELECT CASE WHEN MIN(CONVERT(INT,IQSSP_NationalNielsen.IsActual)) = 1 THEN 'A' ELSE 'E' END FROM IQSSP_NationalNielsen WHERE LocalDate = IQAgent_TVResults.RL_Date AND Title120 = tmp.Title AND Station_Affil = IQ_Station.Station_Affil) AS National_Nielsen_Result
		FROM	@TblSelectMR AS TblSelectMR 
					INNER JOIN IQAgent_MediaResults AS tmp WITH(NOLOCK)
						ON TblSelectMR._ParentID=tmp.ID						
			INNER JOIN IQAgent_TVResults WITH(NOLOCK)
				ON tmp._MediaID =  IQAgent_TVResults.ID AND
				tmp.MediaType = 'TV'
			INNER JOIN IQ_Station WITH(NOLOCK)
				ON IQAgent_TVResults.RL_Station = IQ_Station.IQ_Station_ID
		WHERE 
			IQAgent_TVResults.IsActive = 1 
			AND tmp.IsActive = 1 
			AND IQ_Station.IsActive = 1
			AND tmp.ID NOT IN (SELECT ID from @IDListTbl)

		SELECT distinct 
			tmp._ParentID,
			tmp.ID,
			ISNULL(tmp.PositiveSentiment,0) AS 'PositiveSentiment' ,
			ISNULL(tmp.NegativeSentiment,0) AS 'NegativeSentiment',
			tmp.Title AS 'Title120',
			tmp.MediaDate AS 'Date',
			CONVERT(DATETIME,CONVERT(VARCHAR(MAX),IQAgent_TVResults.RL_Date,101) + ' '+ REPLACE(CONVERT(VARCHAR(MAX),CONVERT(DECIMAL(4,2),(CONVERT(DECIMAL(6,2),IQAgent_TVResults.RL_Time)/CONVERT(DECIMAL(5,2),100)))),'.',':')+':00') AS 'RL_DateTime',
			--IQAgent_TVResults.RL_Date as ''Date'',					
			CONVERT(NVARCHAR(MAX),tmp.HighlightingText) AS 'HighlightingText',					
			IQAgent_TVResults.RL_Station,
			IQAgent_TVResults.RawMediaThumbUrl,
			IQAgent_TVResults.RL_VideoGUID,
			tmp.Category,
			Nielsen_Audience,
			IQAdShareValue,
			Nielsen_Result,
			RL_Market,
			IQ_Station.TimeZone AS 'TimeZone',
			IQ_Station.Dma_Num
		FROM	@TblSelectMR AS TblSelectMR 
					INNER JOIN IQAgent_MediaResults AS tmp WITH(NOLOCK)
						ON TblSelectMR._ParentID=tmp._ParentID
			INNER JOIN IQAgent_TVResults WITH(NOLOCK)
				ON tmp._MediaID =  IQAgent_TVResults.ID AND
				tmp.MediaType = 'TV'
			INNER JOIN IQ_Station WITH(NOLOCK)
				ON IQAgent_TVResults.RL_Station = IQ_Station.IQ_Station_ID
		WHERE 
			IQAgent_TVResults.IsActive = 1 
			AND tmp.IsActive = 1 
			AND IQ_Station.IsActive = 1						
			AND tmp._ParentID NOT IN (SELECT ID from @IDListTbl)
END