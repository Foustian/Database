CREATE PROCEDURE [dbo].[usp_Refresh_IQAgent_DayHourSummary_Subprocess_1]
AS
BEGIN
   
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

-- Created Date :	May 2015
-- Description   :  Called by the usp_Refresh_IQAgent_DayHourSummary, so it can use the MediaResults temp table index. 

BEGIN TRY  	

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
		[MediaValue] Float     NOT NULL,
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
		[MediaValue] Float     NOT NULL,
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
		[MediaValue] Float     NOT NULL,
		[PositiveSentiment] BIGINT NOT NULL,
		[NegativeSentiment] BIGINT NOT NULL
	)
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
			ClientGUID,
			MediaType,
			Category,
			_SearchRequestID,
			COUNT(IQAgent_TVResults.ID) AS NoOfDocs,
			SUM( ISNULL(convert(bigint,IQAgent_TVResults.Number_Hits),0)) AS NoOfHits,
			SUM( ISNULL(convert(bigint,Nielsen_Audience),0)) AS Audience,
			SUM( ISNULL(IQAdShareValue,0)) AS IQMediaValue,
			SUM( ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
			SUM( ISNULL(NegativeSentiment,0)) AS NegativeSentiment	
	FROM
			#TblMediaResults AS TblMR				
					INNER JOIN IQAgent_TVResults WITH(NOLOCK) 
						ON TblMR._MediaID = IQAgent_TVResults.ID
						AND TblMR.MediaType = 'TV'
						AND IQAgent_TVResults.IsActive = 1
	GROUP BY TblMR.MediaDate_Date,TblMR.ClientGUID,TblMR.MediaType,TblMR.Category,TblMR._SearchRequestID

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
			ClientGUID,
			MediaType,
			Category,
			_SearchRequestID,
			COUNT(IQAgent_TVResults_Archive.ID) AS NoOfDocs,
			SUM( ISNULL(convert(bigint,IQAgent_TVResults_Archive.Number_Hits),0)) AS NoOfHits,
			SUM( ISNULL(convert(bigint,Nielsen_Audience),0)) AS Audience,
			SUM( ISNULL(IQAdShareValue,0)) AS IQMediaValue,
			SUM( ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
			SUM( ISNULL(NegativeSentiment,0)) AS NegativeSentiment	
	FROM
			#TblMediaResults AS TblMR				
					INNER JOIN IQAgent_TVResults_Archive WITH(NOLOCK) 
						ON TblMR._MediaID = IQAgent_TVResults_Archive.ID
						AND TblMR.MediaType = 'TV'
						AND IQAgent_TVResults_Archive.IsActive = 1
	GROUP BY TblMR.MediaDate_Date,TblMR.ClientGUID,TblMR.MediaType,TblMR.Category,TblMR._SearchRequestID


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
			ClientGUID,
			MediaType,
			TblMR.Category,
			_SearchRequestID,
			COUNT(IQAgent_NMResults.ID) AS NoOfDocs,
			SUM( ISNULL(convert(bigint,IQAgent_NMResults.Number_Hits),0)) AS NoOfHits,
			SUM( ISNULL(convert(bigint,Compete_Audience),0)) AS Audience,
			SUM( ISNULL(IQAdShareValue,0)) AS IQMediaValue,
			SUM( ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
			SUM( ISNULL(NegativeSentiment,0)) AS NegativeSentiment	
	FROM
			#TblMediaResults AS TblMR				
					INNER JOIN IQAgent_NMResults WITH(NOLOCK) 
						ON TblMR._MediaID = IQAgent_NMResults.ID
						AND TblMR.MediaType = 'NM'
						AND IQAgent_NMResults.IsActive = 1
	GROUP BY TblMR.MediaDate_Date,TblMR.ClientGUID,TblMR.MediaType,TblMR.Category,TblMR._SearchRequestID

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
			ClientGUID,
			MediaType,
			TblMR.Category,
			_SearchRequestID,
			COUNT(IQAgent_NMResults_Archive.ID) AS NoOfDocs,
			SUM( ISNULL(convert(bigint,IQAgent_NMResults_Archive.Number_Hits),0)) AS NoOfHits,
			SUM( ISNULL(convert(bigint,Compete_Audience),0)) AS Audience,
			SUM( ISNULL(IQAdShareValue,0)) AS IQMediaValue,
			SUM( ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
			SUM( ISNULL(NegativeSentiment,0)) AS NegativeSentiment	
	FROM
			#TblMediaResults AS TblMR				
					INNER JOIN IQAgent_NMResults_Archive WITH(NOLOCK) 
						ON TblMR._MediaID = IQAgent_NMResults_Archive.ID
						AND TblMR.MediaType = 'NM'
						AND IQAgent_NMResults_Archive.IsActive = 1
	GROUP BY TblMR.MediaDate_Date,TblMR.ClientGUID,TblMR.MediaType,TblMR.Category,TblMR._SearchRequestID

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
			ClientGUID,
			MediaType,
			TblMR.Category,
			_SearchRequestID,
			COUNT(IQAgent_SMResults.ID) AS NoOfDocs,
			SUM( ISNULL(convert(bigint,IQAgent_SMResults.Number_Hits),0)) AS NoOfHits,
			SUM( ISNULL(convert(bigint,Compete_Audience),0)) AS Audience,
			SUM( ISNULL(IQAdShareValue,0)) AS IQMediaValue,
			SUM( ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
			SUM( ISNULL(NegativeSentiment,0)) AS NegativeSentiment	
	FROM
			#TblMediaResults AS TblMR				
					INNER JOIN IQAgent_SMResults WITH(NOLOCK)
						ON TblMR._MediaID = IQAgent_SMResults.ID
						AND TblMR.MediaType = 'SM'
						AND IQAgent_SMResults.IsActive = 1
	GROUP BY TblMR.MediaDate_Date,TblMR.ClientGUID,TblMR.MediaType,TblMR.Category,TblMR._SearchRequestID

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
			ClientGUID,
			MediaType,
			TblMR.Category,
			_SearchRequestID,
			COUNT(IQAgent_SMResults_Archive.ID) AS NoOfDocs,
			SUM( ISNULL(convert(bigint,IQAgent_SMResults_Archive.Number_Hits),0)) AS NoOfHits,
			SUM( ISNULL(convert(bigint,Compete_Audience),0)) AS Audience,
			SUM( ISNULL(IQAdShareValue,0)) AS IQMediaValue,
			SUM( ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
			SUM( ISNULL(NegativeSentiment,0)) AS NegativeSentiment	
	FROM
			#TblMediaResults AS TblMR				
					INNER JOIN IQAgent_SMResults_Archive WITH(NOLOCK)
						ON TblMR._MediaID = IQAgent_SMResults_Archive.ID
						AND TblMR.MediaType = 'SM'
						AND IQAgent_SMResults_Archive.IsActive = 1
	GROUP BY TblMR.MediaDate_Date,TblMR.ClientGUID,TblMR.MediaType,TblMR.Category,TblMR._SearchRequestID


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
			ClientGUID,
			MediaType,
			TblMR.Category,
			_SearchRequestID,
			COUNT(IQAgent_TwitterResults.ID) AS NoOfDocs,
			SUM( ISNULL(convert(bigint,IQAgent_TwitterResults.Number_Hits),0)) AS NoOfHits,
			SUM( ISNULL(convert(bigint,actor_followersCount),0)) AS Audience,
			SUM( ISNULL(convert(bigint,gnip_klout_score),0)) AS IQMediaValue,
			SUM( ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
			SUM( ISNULL(NegativeSentiment,0)) AS NegativeSentiment	
	FROM
			#TblMediaResults AS TblMR				
					INNER JOIN IQAgent_TwitterResults WITH(NOLOCK)
							ON TblMR._MediaID = IQAgent_TwitterResults.ID
							AND TblMR.MediaType = 'TW'
						AND IQAgent_TwitterResults.IsActive = 1
	GROUP BY TblMR.MediaDate_Date,TblMR.ClientGUID,TblMR.MediaType,TblMR.Category,TblMR._SearchRequestID

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
			ClientGUID,
			MediaType,
			TblMR.Category,
			_SearchRequestID,
			COUNT(IQAgent_TwitterResults_Archive.ID) AS NoOfDocs,
			SUM( ISNULL(convert(bigint,IQAgent_TwitterResults_Archive.Number_Hits),0)) AS NoOfHits,
			SUM( ISNULL(convert(bigint,actor_followersCount),0)) AS Audience,
			SUM( ISNULL(convert(bigint,gnip_klout_score),0)) AS IQMediaValue,
			SUM( ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
			SUM( ISNULL(NegativeSentiment,0)) AS NegativeSentiment	
	FROM
			#TblMediaResults AS TblMR				
					INNER JOIN IQAgent_TwitterResults_Archive WITH(NOLOCK)
							ON TblMR._MediaID = IQAgent_TwitterResults_Archive.ID
							AND TblMR.MediaType = 'TW'
						AND IQAgent_TwitterResults_Archive.IsActive = 1
	GROUP BY TblMR.MediaDate_Date,TblMR.ClientGUID,TblMR.MediaType,TblMR.Category,TblMR._SearchRequestID

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
			ClientGUID,
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
			#TblMediaResults AS TblMR				
					INNER JOIN IQAgent_TVEyesResults WITH(NOLOCK)
						ON TblMR._MediaID = IQAgent_TVEyesResults.ID
						AND TblMR.MediaType = 'TM'
						AND IQAgent_TVEyesResults.IsActive = 1
	GROUP BY TblMR.MediaDate_Date,TblMR.ClientGUID,TblMR.MediaType,TblMR.Category,TblMR._SearchRequestID

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
			ClientGUID,
			MediaType,
			TblMR.Category,
			_SearchRequestID,
			COUNT(IQAgent_TVEyesResults_Archive.ID) AS NoOfDocs,
			0 AS NoOfHits,
			0 AS Audience,
			0 AS IQMediaValue,
			SUM(ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
			SUM(ISNULL(NegativeSentiment,0)) AS NegativeSentiment	
	FROM
			#TblMediaResults AS TblMR				
					INNER JOIN IQAgent_TVEyesResults_Archive WITH(NOLOCK)
						ON TblMR._MediaID = IQAgent_TVEyesResults_Archive.ID
						AND TblMR.MediaType = 'TM'
						AND IQAgent_TVEyesResults_Archive.IsActive = 1
	GROUP BY TblMR.MediaDate_Date,TblMR.ClientGUID,TblMR.MediaType,TblMR.Category,TblMR._SearchRequestID




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
			ClientGUID,
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
			#TblMediaResults AS TblMR				
					INNER JOIN IQAgent_BLPMResults WITH(NOLOCK)
						ON TblMR._MediaID = IQAgent_BLPMResults.ID
						AND TblMR.MediaType = 'PM'
						AND IQAgent_BLPMResults.IsActive = 1
	GROUP BY TblMR.MediaDate_Date,TblMR.ClientGUID,TblMR.MediaType,TblMR.Category,TblMR._SearchRequestID

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
			ClientGUID,
			MediaType,
			TblMR.Category,
			_SearchRequestID,
			COUNT(IQAgent_BLPMResults_Archive.ID) AS NoOfDocs,
			0 AS NoOfHits,
			SUM( ISNULL(IQAgent_BLPMResults_Archive.Circulation,0)) AS Audience,
			0 AS IQMediaValue,
			SUM(ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
			SUM(ISNULL(NegativeSentiment,0)) AS NegativeSentiment	
	FROM
			#TblMediaResults AS TblMR				
					INNER JOIN IQAgent_BLPMResults_Archive WITH(NOLOCK)
						ON TblMR._MediaID = IQAgent_BLPMResults_Archive.ID
						AND TblMR.MediaType = 'PM'
						AND IQAgent_BLPMResults_Archive.IsActive = 1
	GROUP BY TblMR.MediaDate_Date,TblMR.ClientGUID,TblMR.MediaType,TblMR.Category,TblMR._SearchRequestID

-- For PQ

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
			ClientGUID,
			MediaType,
			TblMR.Category,
			_SearchRequestID,
			COUNT(IQAgent_PQResults.ID) AS NoOfDocs,
			SUM(ISNULL(IQAgent_PQResults.Number_Hits,0)) AS NoOfHits,  
			0 AS Audience,
			0 AS IQMediaValue,
		    SUM(ISNULL(PositiveSentiment,0)) AS PositiveSentiment,         
	        SUM(ISNULL(NegativeSentiment ,0)) AS NegativeSentiment
	FROM
			#TblMediaResults AS TblMR				
					INNER JOIN IQAgent_PQResults WITH(NOLOCK)
						ON TblMR._MediaID = IQAgent_PQResults.ID
						AND TblMR.MediaType = 'PQ'
						AND IQAgent_PQResults.IsActive = 1
	GROUP BY TblMR.MediaDate_Date,TblMR.ClientGUID,TblMR.MediaType,TblMR.Category,TblMR._SearchRequestID

		
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
			ClientGUID,
			MediaType,
			Category,
			_SearchRequestID,
			COUNT(IQAgent_TVResults.ID) AS NoOfDocs,
			SUM( ISNULL(convert(bigint,IQAgent_TVResults.Number_Hits),0)) AS NoOfHits,
			SUM( ISNULL(convert(bigint,Nielsen_Audience),0)) AS Audience,
			SUM( ISNULL(IQAdShareValue,0)) AS IQMediaValue,
			SUM( ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
			SUM( ISNULL(NegativeSentiment,0)) AS NegativeSentiment	
	FROM
			#TblMediaResults AS TblMR				
					INNER JOIN IQAgent_TVResults WITH(NOLOCK) 
						ON TblMR._MediaID = IQAgent_TVResults.ID
						AND TblMR.MediaType = 'TV'
						AND IQAgent_TVResults.IsActive = 1
	GROUP BY TblMR.LocalMediaDate,TblMR.ClientGUID,TblMR.MediaType,TblMR.Category,TblMR._SearchRequestID   
	
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
			ClientGUID,
			MediaType,
			Category,
			_SearchRequestID,
			COUNT(IQAgent_TVResults_Archive.ID) AS NoOfDocs,
			SUM( ISNULL(convert(bigint,IQAgent_TVResults_Archive.Number_Hits),0)) AS NoOfHits,
			SUM( ISNULL(convert(bigint,Nielsen_Audience),0)) AS Audience,
			SUM( ISNULL(IQAdShareValue,0)) AS IQMediaValue,
			SUM( ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
			SUM( ISNULL(NegativeSentiment,0)) AS NegativeSentiment	
	FROM
			#TblMediaResults AS TblMR				
					INNER JOIN IQAgent_TVResults_Archive WITH(NOLOCK) 
						ON TblMR._MediaID = IQAgent_TVResults_Archive.ID
						AND TblMR.MediaType = 'TV'
						AND IQAgent_TVResults_Archive.IsActive = 1
	GROUP BY TblMR.LocalMediaDate,TblMR.ClientGUID,TblMR.MediaType,TblMR.Category,TblMR._SearchRequestID 
	
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
			ClientGUID,
			MediaType,
			TblMR.Category,
			_SearchRequestID,
			COUNT(IQAgent_NMResults.ID) AS NoOfDocs,
			SUM( ISNULL(convert(bigint,IQAgent_NMResults.Number_Hits),0)) AS NoOfHits,
			SUM( ISNULL(convert(bigint,Compete_Audience),0)) AS Audience,
			SUM( ISNULL(IQAdShareValue,0)) AS IQMediaValue,
			SUM( ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
			SUM( ISNULL(NegativeSentiment,0)) AS NegativeSentiment	
	FROM
			#TblMediaResults AS TblMR				
					INNER JOIN IQAgent_NMResults WITH(NOLOCK) 
						ON TblMR._MediaID = IQAgent_NMResults.ID
						AND TblMR.MediaType = 'NM'
						AND IQAgent_NMResults.IsActive = 1
	GROUP BY TblMR.LocalMediaDate,TblMR.ClientGUID,TblMR.MediaType,TblMR.Category,TblMR._SearchRequestID  

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
			ClientGUID,
			MediaType,
			TblMR.Category,
			_SearchRequestID,
			COUNT(IQAgent_NMResults_Archive.ID) AS NoOfDocs,
			SUM( ISNULL(convert(bigint,IQAgent_NMResults_Archive.Number_Hits),0)) AS NoOfHits,
			SUM( ISNULL(convert(bigint,Compete_Audience),0)) AS Audience,
			SUM( ISNULL(IQAdShareValue,0)) AS IQMediaValue,
			SUM( ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
			SUM( ISNULL(NegativeSentiment,0)) AS NegativeSentiment	
	FROM
			#TblMediaResults AS TblMR				
					INNER JOIN IQAgent_NMResults_Archive WITH(NOLOCK) 
						ON TblMR._MediaID = IQAgent_NMResults_Archive.ID
						AND TblMR.MediaType = 'NM'
						AND IQAgent_NMResults_Archive.IsActive = 1
	GROUP BY TblMR.LocalMediaDate,TblMR.ClientGUID,TblMR.MediaType,TblMR.Category,TblMR._SearchRequestID  


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
			ClientGUID,
			MediaType,
			TblMR.Category,
			_SearchRequestID,
			COUNT(IQAgent_SMResults.ID) AS NoOfDocs,
			SUM( ISNULL(convert(bigint,IQAgent_SMResults.Number_Hits),0)) AS NoOfHits,
			SUM( ISNULL(convert(bigint,Compete_Audience),0)) AS Audience,
			SUM( ISNULL(IQAdShareValue,0)) AS IQMediaValue,
			SUM( ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
			SUM( ISNULL(NegativeSentiment,0)) AS NegativeSentiment	
	FROM
			#TblMediaResults AS TblMR				
					INNER JOIN IQAgent_SMResults WITH(NOLOCK)
						ON TblMR._MediaID = IQAgent_SMResults.ID
						AND TblMR.MediaType = 'SM'
						AND IQAgent_SMResults.IsActive = 1
	GROUP BY TblMR.LocalMediaDate,TblMR.ClientGUID,TblMR.MediaType,TblMR.Category,TblMR._SearchRequestID

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
			ClientGUID,
			MediaType,
			TblMR.Category,
			_SearchRequestID,
			COUNT(IQAgent_SMResults_Archive.ID) AS NoOfDocs,
			SUM( ISNULL(convert(bigint,IQAgent_SMResults_Archive.Number_Hits),0)) AS NoOfHits,
			SUM( ISNULL(convert(bigint,Compete_Audience),0)) AS Audience,
			SUM( ISNULL(IQAdShareValue,0)) AS IQMediaValue,
			SUM( ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
			SUM( ISNULL(NegativeSentiment,0)) AS NegativeSentiment	
	FROM
			#TblMediaResults AS TblMR				
					INNER JOIN IQAgent_SMResults_Archive WITH(NOLOCK)
						ON TblMR._MediaID = IQAgent_SMResults_Archive.ID
						AND TblMR.MediaType = 'SM'
						AND IQAgent_SMResults_Archive.IsActive = 1
	GROUP BY TblMR.LocalMediaDate,TblMR.ClientGUID,TblMR.MediaType,TblMR.Category,TblMR._SearchRequestID
	


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
			ClientGUID,
			MediaType,
			TblMR.Category,
			_SearchRequestID,
			COUNT(IQAgent_TwitterResults.ID) AS NoOfDocs,
			SUM( ISNULL(convert(bigint,IQAgent_TwitterResults.Number_Hits),0)) AS NoOfHits,
			SUM( ISNULL(convert(bigint,actor_followersCount),0)) AS Audience,
			SUM( ISNULL(convert(bigint,gnip_klout_score),0)) AS IQMediaValue,
			SUM( ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
			SUM( ISNULL(NegativeSentiment,0)) AS NegativeSentiment	
	FROM
			#TblMediaResults AS TblMR				
					INNER JOIN IQAgent_TwitterResults WITH(NOLOCK)
							ON TblMR._MediaID = IQAgent_TwitterResults.ID
							AND TblMR.MediaType = 'TW'
						AND IQAgent_TwitterResults.IsActive = 1
	GROUP BY TblMR.LocalMediaDate,TblMR.ClientGUID,TblMR.MediaType,TblMR.Category,TblMR._SearchRequestID	

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
			ClientGUID,
			MediaType,
			TblMR.Category,
			_SearchRequestID,
			COUNT(IQAgent_TwitterResults_Archive.ID) AS NoOfDocs,
			SUM( ISNULL(convert(bigint,IQAgent_TwitterResults_Archive.Number_Hits),0)) AS NoOfHits,
			SUM( ISNULL(convert(bigint,actor_followersCount),0)) AS Audience,
			SUM( ISNULL(convert(bigint,gnip_klout_score),0)) AS IQMediaValue,
			SUM( ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
			SUM( ISNULL(NegativeSentiment,0)) AS NegativeSentiment	
	FROM
			#TblMediaResults AS TblMR				
					INNER JOIN IQAgent_TwitterResults_Archive WITH(NOLOCK)
							ON TblMR._MediaID = IQAgent_TwitterResults_Archive.ID
							AND TblMR.MediaType = 'TW'
						AND IQAgent_TwitterResults_Archive.IsActive = 1
	GROUP BY TblMR.LocalMediaDate,TblMR.ClientGUID,TblMR.MediaType,TblMR.Category,TblMR._SearchRequestID	



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
			ClientGUID,
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
			#TblMediaResults AS TblMR				
					INNER JOIN IQAgent_TVEyesResults WITH(NOLOCK)
						ON TblMR._MediaID = IQAgent_TVEyesResults.ID
						AND TblMR.MediaType = 'TM'
						AND IQAgent_TVEyesResults.IsActive = 1
	GROUP BY TblMR.LocalMediaDate,TblMR.ClientGUID,TblMR.MediaType,TblMR.Category,TblMR._SearchRequestID	

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
			ClientGUID,
			MediaType,
			TblMR.Category,
			_SearchRequestID,
			COUNT(IQAgent_TVEyesResults_Archive.ID) AS NoOfDocs,
			0 AS NoOfHits,
			0 AS Audience,
			0 AS IQMediaValue,
			SUM(ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
			SUM(ISNULL(NegativeSentiment,0)) AS NegativeSentiment	
	FROM
			#TblMediaResults AS TblMR				
					INNER JOIN IQAgent_TVEyesResults_Archive WITH(NOLOCK)
						ON TblMR._MediaID = IQAgent_TVEyesResults_Archive.ID
						AND TblMR.MediaType = 'TM'
						AND IQAgent_TVEyesResults_Archive.IsActive = 1
	GROUP BY TblMR.LocalMediaDate,TblMR.ClientGUID,TblMR.MediaType,TblMR.Category,TblMR._SearchRequestID	



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
			ClientGUID,
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
			#TblMediaResults AS TblMR				
					INNER JOIN IQAgent_BLPMResults WITH(NOLOCK)
						ON TblMR._MediaID = IQAgent_BLPMResults.ID
						AND TblMR.MediaType = 'PM'
						AND IQAgent_BLPMResults.IsActive = 1
	GROUP BY TblMR.LocalMediaDate,TblMR.ClientGUID,TblMR.MediaType,TblMR.Category,TblMR._SearchRequestID

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
			ClientGUID,
			MediaType,
			TblMR.Category,
			_SearchRequestID,
			COUNT(IQAgent_BLPMResults_Archive.ID) AS NoOfDocs,
			0 AS NoOfHits,
			SUM( ISNULL(IQAgent_BLPMResults_Archive.Circulation,0)) AS Audience,
			0 AS IQMediaValue,
			SUM(ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
			SUM(ISNULL(NegativeSentiment,0)) AS NegativeSentiment	
	FROM
			#TblMediaResults AS TblMR				
					INNER JOIN IQAgent_BLPMResults_Archive WITH(NOLOCK)
						ON TblMR._MediaID = IQAgent_BLPMResults_Archive.ID
						AND TblMR.MediaType = 'PM'
						AND IQAgent_BLPMResults_Archive.IsActive = 1
	GROUP BY TblMR.LocalMediaDate,TblMR.ClientGUID,TblMR.MediaType,TblMR.Category,TblMR._SearchRequestID

	-- For PQ

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
			ClientGUID,
			MediaType,
			TblMR.Category,
			_SearchRequestID,
			COUNT(IQAgent_PQResults.ID) AS NoOfDocs,
			SUM(ISNULL(IQAgent_PQResults.Number_Hits,0)) AS NoOfHits,  
			0 AS Audience,
			0 AS IQMediaValue,
		    SUM(ISNULL(PositiveSentiment,0)) AS PositiveSentiment,         
	        SUM(ISNULL(NegativeSentiment ,0)) AS NegativeSentiment
	FROM
			#TblMediaResults AS TblMR				
					INNER JOIN IQAgent_PQResults WITH(NOLOCK)
						ON TblMR._MediaID = IQAgent_PQResults.ID
						AND TblMR.MediaType = 'PQ'
						AND IQAgent_PQResults.IsActive = 1
	GROUP BY TblMR.LocalMediaDate,TblMR.ClientGUID,TblMR.MediaType,TblMR.Category,TblMR._SearchRequestID

	

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
			ClientGUID,
			MediaType,
			Category,
			_SearchRequestID,
			COUNT(IQAgent_TVResults.ID) AS NoOfDocs,
			SUM( ISNULL(convert(bigint,IQAgent_TVResults.Number_Hits),0)) AS NoOfHits,
			SUM( ISNULL(convert(bigint,Nielsen_Audience),0)) AS Audience,
			SUM( ISNULL(IQAdShareValue,0)) AS IQMediaValue,
			SUM( ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
			SUM( ISNULL(NegativeSentiment,0)) AS NegativeSentiment	
	FROM
			#TblMediaResults AS TblMR
					INNER JOIN IQAgent_TVResults WITH(NOLOCK) 
						ON TblMR._MediaID = IQAgent_TVResults.ID
						AND TblMR.MediaType = 'TV'
						AND IQAgent_TVResults.IsActive = 1
	GROUP BY TblMR.MediaDate_Hour,TblMR.ClientGUID,TblMR.MediaType,TblMR.Category,TblMR._SearchRequestID 

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
			ClientGUID,
			MediaType,
			Category,
			_SearchRequestID,
			COUNT(IQAgent_TVResults_Archive.ID) AS NoOfDocs,
			SUM( ISNULL(convert(bigint,IQAgent_TVResults_Archive.Number_Hits),0)) AS NoOfHits,
			SUM( ISNULL(convert(bigint,Nielsen_Audience),0)) AS Audience,
			SUM( ISNULL(IQAdShareValue,0)) AS IQMediaValue,
			SUM( ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
			SUM( ISNULL(NegativeSentiment,0)) AS NegativeSentiment	
	FROM
			#TblMediaResults AS TblMR
					INNER JOIN IQAgent_TVResults_Archive WITH(NOLOCK) 
						ON TblMR._MediaID = IQAgent_TVResults_Archive.ID
						AND TblMR.MediaType = 'TV'
						AND IQAgent_TVResults_Archive.IsActive = 1
	GROUP BY TblMR.MediaDate_Hour,TblMR.ClientGUID,TblMR.MediaType,TblMR.Category,TblMR._SearchRequestID 

	
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
			ClientGUID,
			MediaType,
			TblMR.Category,
			_SearchRequestID,
			COUNT(IQAgent_NMResults.ID) AS NoOfDocs,
			SUM( ISNULL(convert(bigint,IQAgent_NMResults.Number_Hits),0)) AS NoOfHits,
			SUM( ISNULL(convert(bigint,Compete_Audience),0)) AS Audience,
			SUM( ISNULL(IQAdShareValue,0)) AS IQMediaValue,
			SUM( ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
			SUM( ISNULL(NegativeSentiment,0)) AS NegativeSentiment	
	FROM
			#TblMediaResults AS TblMR
					INNER JOIN IQAgent_NMResults WITH(NOLOCK) 
						ON TblMR._MediaID = IQAgent_NMResults.ID
						AND TblMR.MediaType = 'NM'
						AND IQAgent_NMResults.IsActive = 1
	GROUP BY TblMR.MediaDate_Hour,TblMR.ClientGUID,TblMR.MediaType,TblMR.Category,TblMR._SearchRequestID  

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
			ClientGUID,
			MediaType,
			TblMR.Category,
			_SearchRequestID,
			COUNT(IQAgent_NMResults_Archive.ID) AS NoOfDocs,
			SUM( ISNULL(convert(bigint,IQAgent_NMResults_Archive.Number_Hits),0)) AS NoOfHits,
			SUM( ISNULL(convert(bigint,Compete_Audience),0)) AS Audience,
			SUM( ISNULL(IQAdShareValue,0)) AS IQMediaValue,
			SUM( ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
			SUM( ISNULL(NegativeSentiment,0)) AS NegativeSentiment	
	FROM
			#TblMediaResults AS TblMR
					INNER JOIN IQAgent_NMResults_Archive WITH(NOLOCK) 
						ON TblMR._MediaID = IQAgent_NMResults_Archive.ID
						AND TblMR.MediaType = 'NM'
						AND IQAgent_NMResults_Archive.IsActive = 1
	GROUP BY TblMR.MediaDate_Hour,TblMR.ClientGUID,TblMR.MediaType,TblMR.Category,TblMR._SearchRequestID  

	
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
			ClientGUID,
			MediaType,
			TblMR.Category,
			_SearchRequestID,
			COUNT(IQAgent_SMResults.ID) AS NoOfDocs,
			SUM( ISNULL(convert(bigint,IQAgent_SMResults.Number_Hits),0)) AS NoOfHits,
			SUM( ISNULL(convert(bigint,Compete_Audience),0)) AS Audience,
			SUM( ISNULL(IQAdShareValue,0)) AS IQMediaValue,
			SUM( ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
			SUM( ISNULL(NegativeSentiment,0)) AS NegativeSentiment	
	FROM
			#TblMediaResults AS TblMR				
					INNER JOIN IQAgent_SMResults WITH(NOLOCK)
						ON TblMR._MediaID = IQAgent_SMResults.ID
						AND TblMR.MediaType = 'SM'
						AND IQAgent_SMResults.IsActive = 1
	GROUP BY TblMR.MediaDate_Hour,TblMR.ClientGUID,TblMR.MediaType,TblMR.Category,TblMR._SearchRequestID
	
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
			ClientGUID,
			MediaType,
			TblMR.Category,
			_SearchRequestID,
			COUNT(IQAgent_SMResults_Archive.ID) AS NoOfDocs,
			SUM( ISNULL(convert(bigint,IQAgent_SMResults_Archive.Number_Hits),0)) AS NoOfHits,
			SUM( ISNULL(convert(bigint,Compete_Audience),0)) AS Audience,
			SUM( ISNULL(IQAdShareValue,0)) AS IQMediaValue,
			SUM( ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
			SUM( ISNULL(NegativeSentiment,0)) AS NegativeSentiment	
	FROM
			#TblMediaResults AS TblMR				
					INNER JOIN IQAgent_SMResults_Archive WITH(NOLOCK)
						ON TblMR._MediaID = IQAgent_SMResults_Archive.ID
						AND TblMR.MediaType = 'SM'
						AND IQAgent_SMResults_Archive.IsActive = 1
	GROUP BY TblMR.MediaDate_Hour,TblMR.ClientGUID,TblMR.MediaType,TblMR.Category,TblMR._SearchRequestID


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
			ClientGUID,
			MediaType,
			TblMR.Category,
			_SearchRequestID,
			COUNT(IQAgent_TwitterResults.ID) AS NoOfDocs,
			SUM( ISNULL(convert(bigint,IQAgent_TwitterResults.Number_Hits),0)) AS NoOfHits,
			SUM( ISNULL(convert(bigint,actor_followersCount),0)) AS Audience,
			SUM( ISNULL(convert(bigint,gnip_klout_score),0)) AS IQMediaValue,
			SUM( ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
			SUM( ISNULL(NegativeSentiment,0)) AS NegativeSentiment	
	FROM
			#TblMediaResults AS TblMR				
					INNER JOIN IQAgent_TwitterResults WITH(NOLOCK)
							ON TblMR._MediaID = IQAgent_TwitterResults.ID
							AND TblMR.MediaType = 'TW'
						AND IQAgent_TwitterResults.IsActive = 1
	GROUP BY TblMR.MediaDate_Hour,TblMR.ClientGUID,TblMR.MediaType,TblMR.Category,TblMR._SearchRequestID

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
			ClientGUID,
			MediaType,
			TblMR.Category,
			_SearchRequestID,
			COUNT(IQAgent_TwitterResults_Archive.ID) AS NoOfDocs,
			SUM( ISNULL(convert(bigint,IQAgent_TwitterResults_Archive.Number_Hits),0)) AS NoOfHits,
			SUM( ISNULL(convert(bigint,actor_followersCount),0)) AS Audience,
			SUM( ISNULL(convert(bigint,gnip_klout_score),0)) AS IQMediaValue,
			SUM( ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
			SUM( ISNULL(NegativeSentiment,0)) AS NegativeSentiment	
	FROM
			#TblMediaResults AS TblMR				
					INNER JOIN IQAgent_TwitterResults_Archive WITH(NOLOCK)
							ON TblMR._MediaID = IQAgent_TwitterResults_Archive.ID
							AND TblMR.MediaType = 'TW'
						AND IQAgent_TwitterResults_Archive.IsActive = 1
	GROUP BY TblMR.MediaDate_Hour,TblMR.ClientGUID,TblMR.MediaType,TblMR.Category,TblMR._SearchRequestID


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
			ClientGUID,
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
			#TblMediaResults AS TblMR
					INNER JOIN IQAgent_TVEyesResults WITH(NOLOCK)
						ON TblMR._MediaID = IQAgent_TVEyesResults.ID
						AND TblMR.MediaType = 'TM'
						AND IQAgent_TVEyesResults.IsActive = 1
	GROUP BY TblMR.MediaDate_Hour,TblMR.ClientGUID,TblMR.MediaType,TblMR.Category,TblMR._SearchRequestID	

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
			ClientGUID,
			MediaType,
			TblMR.Category,
			_SearchRequestID,
			COUNT(IQAgent_TVEyesResults_Archive.ID) AS NoOfDocs,
			0 AS NoOfHits,
			0 AS Audience,
			0 AS IQMediaValue,
			SUM(ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
			SUM(ISNULL(NegativeSentiment,0)) AS NegativeSentiment	
	FROM
			#TblMediaResults AS TblMR
					INNER JOIN IQAgent_TVEyesResults_Archive WITH(NOLOCK)
						ON TblMR._MediaID = IQAgent_TVEyesResults_Archive.ID
						AND TblMR.MediaType = 'TM'
						AND IQAgent_TVEyesResults_Archive.IsActive = 1
	GROUP BY TblMR.MediaDate_Hour,TblMR.ClientGUID,TblMR.MediaType,TblMR.Category,TblMR._SearchRequestID	

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
			ClientGUID,
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
			#TblMediaResults AS TblMR
					INNER JOIN IQAgent_BLPMResults WITH(NOLOCK)
						ON TblMR._MediaID = IQAgent_BLPMResults.ID
						AND TblMR.MediaType = 'PM'
						AND IQAgent_BLPMResults.IsActive = 1
	GROUP BY TblMR.MediaDate_Hour,TblMR.ClientGUID,TblMR.MediaType,TblMR.Category,TblMR._SearchRequestID
	
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
			ClientGUID,
			MediaType,
			TblMR.Category,
			_SearchRequestID,
			COUNT(IQAgent_BLPMResults_Archive.ID) AS NoOfDocs,
			0 AS NoOfHits,
			SUM( ISNULL(IQAgent_BLPMResults_Archive.Circulation,0)) AS Audience,
			0 AS IQMediaValue,
			SUM(ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
			SUM(ISNULL(NegativeSentiment,0)) AS NegativeSentiment	
	FROM
			#TblMediaResults AS TblMR
					INNER JOIN IQAgent_BLPMResults_Archive WITH(NOLOCK)
						ON TblMR._MediaID = IQAgent_BLPMResults_Archive.ID
						AND TblMR.MediaType = 'PM'
						AND IQAgent_BLPMResults_Archive.IsActive = 1
	GROUP BY TblMR.MediaDate_Hour,TblMR.ClientGUID,TblMR.MediaType,TblMR.Category,TblMR._SearchRequestID


-- For PQ

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
			ClientGUID,
			MediaType,
			TblMR.Category,
			_SearchRequestID,
			COUNT(IQAgent_PQResults.ID) AS NoOfDocs,
			SUM(ISNULL(IQAgent_PQResults.Number_Hits,0)) AS NoOfHits,  
			0 AS Audience,
			0 AS IQMediaValue,
		    SUM(ISNULL(PositiveSentiment,0)) AS PositiveSentiment,         
	        SUM(ISNULL(NegativeSentiment ,0)) AS NegativeSentiment
		FROM
			#TblMediaResults AS TblMR
					INNER JOIN IQAgent_PQResults WITH(NOLOCK)
						ON TblMR._MediaID = IQAgent_PQResults.ID
						AND TblMR.MediaType = 'PQ'
						AND IQAgent_PQResults.IsActive = 1
	GROUP BY TblMR.MediaDate_Hour,TblMR.ClientGUID,TblMR.MediaType,TblMR.Category,TblMR._SearchRequestID

	Select MediaDateTime,
		ClientGUID,
		MediaType,
		SubMediaType,
		_SearchRequestID,
		SUM(ISNULL(NoOfDocs,0)) as NoOfDocs,
		SUM(ISNULL(NoOfHits,0)) as NoOfHits,
		SUM(ISNULL(Audience,0)) as Audience,
		SUM(ISNULL(MediaValue,0)) as MediaValue,
		SUM(ISNULL(PositiveSentiment,0)) as PositiveSentiment,
		SUM(ISNULL(NegativeSentiment,0)) as NegativeSentiment into #TmpHourSummaryResults_Final
		From #TmpHourSummaryResults
		Group by ClientGUID,_SearchRequestID,MediaDateTime,MediaType,SubMediaType

		Insert Into dbo.IQAgent_HourSummary_NEW
	(ClientGuid,HourDateTime,MediaType,_SearchRequestID,NoOfDocs,NoOfHits,Audience,IQMediaValue,PositiveSentiment,NegativeSentiment,SubMediaType)
	Select ClientGUID,MediaDateTime,MediaType,_SearchRequestID,
			NoOfDocs,NoOfHits,Audience,MediaValue,PositiveSentiment,NegativeSentiment,SubMediaType From #TmpHourSummaryResults_Final


	
	Select	MediaDate,
		ClientGUID,
		MediaType,
		SubMediaType,
		_SearchRequestID,
		SUM(ISNULL(NoOfDocs,0)) as NoOfDocs,
		SUM(ISNULL(NoOfHits,0)) as NoOfHits,
		SUM(ISNULL(Audience,0)) as Audience,
		SUM(ISNULL(MediaValue,0)) as MediaValue,
		SUM(ISNULL(PositiveSentiment,0)) as PositiveSentiment,
		SUM(ISNULL(NegativeSentiment,0)) as NegativeSentiment into #TmpDaySummaryResults_Final
		From #TmpDaySummaryResults
		Group by ClientGUID,_SearchRequestID,MediaDate,MediaType,SubMediaType

		Select	LocalMediaDate,
		ClientGUID,
		MediaType,
		SubMediaType,
		_SearchRequestID,
		SUM(ISNULL(NoOfDocs,0)) as NoOfDocs,
		SUM(ISNULL(NoOfHits,0)) as NoOfHits,
		SUM(ISNULL(Audience,0)) as Audience,
		SUM(ISNULL(MediaValue,0)) as MediaValue,
		SUM(ISNULL(PositiveSentiment,0)) as PositiveSentiment,
		SUM(ISNULL(NegativeSentiment,0)) as NegativeSentiment into  #TmpDaySummaryLDResults_Final
		From #TmpDaySummaryLDResults
		Group by ClientGUID,_SearchRequestID,LocalMediaDate,MediaType,SubMediaType
		
	Insert into dbo.IQAgent_DaySummary_NEW
	(ClientGuid,DayDate,MediaType,_SearchRequestID,NoOfDocs,NoOfHits,Audience,IQMediaValue,SubMediaType,PositiveSentiment,NegativeSentiment)
	Select ClientGUID,MediaDate,MediaType,_SearchRequestID,NoOfDocs,NoOfHits,Audience,MediaValue,SubMediaType,PositiveSentiment,NegativeSentiment from #TmpDaySummaryResults_Final

	Create index idx1_TmpDaySummaryLDResults_Final on #TmpDaySummaryLDResults_Final(ClientGUID,_SearchRequestID,LocalMediaDate,MediaType,SubMediaType)

	

	exec dbo.usp_Refresh_IQAgent_DayHourSummary_Subprocess_2 with recompile
		
		

		
--#endregion

	Return 0 
END TRY
		BEGIN CATCH
		
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
				@CreatedBy='usp_Refresh_IQAgent_DayHourSummary_Subprocess_1]',
				@ModifiedBy='usp_Refresh_IQAgent_DayHourSummary_Subprocess_1]',
				@CreatedDate=GETDATE(),
				@ModifiedDate=GETDATE(),
				@IsActive=1
	

				EXEC usp_IQMediaGroupExceptions_Insert @ExceptionStackTrace,@ExceptionMessage,@CreatedBy,@CreatedDate,NULL,@IQMediaGroupExceptionKey OUTPUT    
				Return -1
		END CATCH        

END