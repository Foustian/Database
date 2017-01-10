CREATE PROCEDURE [dbo].[usp_v4_IQAgent_MediaResults_Dirtytbl_process_build_DayHourSummary_Delete]        
AS        
BEGIN         
 SET NOCOUNT ON;        
 SET XACT_ABORT ON;

BEGIN TRY        
      
       
 -- For TV
 If exists(select COUNT(1) from #MediaResults_Delete where  MediaType='TV' )
    Begin
      INSERT INTO #TmpDaySummaryResults_Delete
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
			MediaDate,
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
			#MediaResults_Delete  TblMR		
			 		 JOIN IQAgent_TVResults  WITH(NOLOCK) 
						ON TblMR.MediaID = IQAgent_TVResults.ID
						AND TblMR.MediaType = 'TV'
				--		AND IQAgent_TVResults.IsActive = 0
	GROUP BY TblMR.MediaDate,ClientGUID,TblMR.MediaType,TblMR.Category,TblMR._SearchRequestID
	
	INSERT INTO #TmpDaySummaryResults_Delete_Archive
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
			MediaDate,
			ClientGUID,
			MediaType,
			Category,
			_SearchRequestID,
			COUNT(archive.ID) AS NoOfDocs,
			SUM( ISNULL(convert(bigint,archive.Number_Hits),0)) AS NoOfHits,
			SUM( ISNULL(convert(bigint,Nielsen_Audience),0)) AS Audience,
			SUM( ISNULL(IQAdShareValue,0)) AS IQMediaValue,
			SUM( ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
			SUM( ISNULL(NegativeSentiment,0)) AS NegativeSentiment	
	    FROM
			#MediaResults_Delete  TblMR		
			 		 JOIN IQAgent_TVResults_Archive archive  WITH(NOLOCK) 
						ON TblMR.MediaID = archive.ID
						AND TblMR.MediaType = 'TV'
					--	AND archive.IsActive = 0
	GROUP BY TblMR.MediaDate,ClientGUID,TblMR.MediaType,TblMR.Category,TblMR._SearchRequestID
	
	INSERT INTO #TmpDaySummaryLDResults_Delete
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
			LocalDate,
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
		#MediaResults_Delete   TblMR	
			 		 JOIN IQAgent_TVResults  WITH(NOLOCK) 
						ON TblMR.MediaID = IQAgent_TVResults.ID
						AND TblMR.MediaType = 'TV'
				--		AND IQAgent_TVResults.IsActive = 0
	GROUP BY LocalDate,ClientGUID,TblMR.MediaType,TblMR.Category,TblMR._SearchRequestID   
	
	INSERT INTO #TmpDaySummaryLDResults_Delete_Archive
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
			LocalDate,
			ClientGUID,
			MediaType,
			Category,
			_SearchRequestID,
			COUNT(archive.ID) AS NoOfDocs,
			SUM( ISNULL(convert(bigint,archive.Number_Hits),0)) AS NoOfHits,
			SUM( ISNULL(convert(bigint,Nielsen_Audience),0)) AS Audience,
			SUM( ISNULL(IQAdShareValue,0)) AS IQMediaValue,
			SUM( ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
			SUM( ISNULL(NegativeSentiment,0)) AS NegativeSentiment	
	FROM
		#MediaResults_Delete   TblMR	
			 		 JOIN IQAgent_TVResults_Archive  archive WITH(NOLOCK) 
						ON TblMR.MediaID = archive.ID
						AND TblMR.MediaType = 'TV'
					--	AND archive.IsActive = 0
	GROUP BY LocalDate,ClientGUID,TblMR.MediaType,TblMR.Category,TblMR._SearchRequestID   
	
	
	Insert into #TmpHourSummaryResults_Delete
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
		COUNT(IQAgent_TVResults.ID) AS NoOfDocs,
			SUM( ISNULL(convert(bigint,IQAgent_TVResults.Number_Hits),0)) AS NoOfHits,
			SUM( ISNULL(convert(bigint,Nielsen_Audience),0)) AS Audience,
			SUM( ISNULL(IQAdShareValue,0)) AS IQMediaValue,
			SUM( ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
			SUM( ISNULL(NegativeSentiment,0)) AS NegativeSentiment	
	FROM
			#MediaResults_Delete AS TblMR
					INNER JOIN IQAgent_TVResults WITH(NOLOCK) 
						ON TblMR.MediaID = IQAgent_TVResults.ID
						AND TblMR.MediaType = 'TV'
				--		AND IQAgent_TVResults.IsActive = 0
	GROUP BY TblMR.MediaDate_Hour,ClientGUID,TblMR.MediaType,TblMR.Category,TblMR._SearchRequestID 
	
		Insert into #TmpHourSummaryResults_Delete_Archive
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
		COUNT(archive.ID) AS NoOfDocs,
			SUM( ISNULL(convert(bigint,archive.Number_Hits),0)) AS NoOfHits,
			SUM( ISNULL(convert(bigint,Nielsen_Audience),0)) AS Audience,
			SUM( ISNULL(IQAdShareValue,0)) AS IQMediaValue,
			SUM( ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
			SUM( ISNULL(NegativeSentiment,0)) AS NegativeSentiment	
	FROM
			#MediaResults_Delete AS TblMR
					INNER JOIN IQAgent_TVResults_Archive archive WITH(NOLOCK) 
						ON TblMR.MediaID = archive.ID
						AND TblMR.MediaType = 'TV'
				--		AND archive.IsActive = 0
	GROUP BY TblMR.MediaDate_Hour,ClientGUID,TblMR.MediaType,TblMR.Category,TblMR._SearchRequestID 
	
	
    End

-- For NM
 If exists(select COUNT(1) from #MediaResults_Delete where  MediaType='NM' )
    Begin
      INSERT INTO #TmpDaySummaryResults_Delete
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
			MediaDate,
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
			#MediaResults_Delete  TblMR		
			 		 JOIN IQAgent_NMResults  WITH(NOLOCK) 
						ON TblMR.MediaID = IQAgent_NMResults.ID
						AND TblMR.MediaType = 'NM'
					--	AND IQAgent_NMResults.IsActive = 0
	GROUP BY TblMR.MediaDate,ClientGUID,TblMR.MediaType,TblMR.Category,TblMR._SearchRequestID
	
	INSERT INTO #TmpDaySummaryResults_Delete_Archive
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
			MediaDate,
			ClientGUID,
			MediaType,
			TblMR.Category,
			_SearchRequestID,
			COUNT(archive.ID) AS NoOfDocs,
			SUM( ISNULL(convert(bigint,archive.Number_Hits),0)) AS NoOfHits,
			SUM( ISNULL(convert(bigint,Compete_Audience),0)) AS Audience,
			SUM( ISNULL(IQAdShareValue,0)) AS IQMediaValue,
			SUM( ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
			SUM( ISNULL(NegativeSentiment,0)) AS NegativeSentiment	
	    FROM
			#MediaResults_Delete  TblMR		
			 		 JOIN IQAgent_NMResults_Archive archive WITH(NOLOCK) 
						ON TblMR.MediaID = archive.ID
						AND TblMR.MediaType = 'NM'
				--		AND archive.IsActive = 0
	GROUP BY TblMR.MediaDate,ClientGUID,TblMR.MediaType,TblMR.Category,TblMR._SearchRequestID
	
	
	INSERT INTO #TmpDaySummaryLDResults_Delete
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
			LocalDate,
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
		#MediaResults_Delete   TblMR	
			 		 JOIN IQAgent_NMResults  WITH(NOLOCK) 
						ON TblMR.MediaID = IQAgent_NMResults.ID
						AND TblMR.MediaType = 'NM'
				--		AND IQAgent_NMResults.IsActive = 0
	GROUP BY LocalDate,ClientGUID,TblMR.MediaType,TblMR.Category,TblMR._SearchRequestID   
	
	INSERT INTO #TmpDaySummaryLDResults_Delete_Archive
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
			LocalDate,
			ClientGUID,
			MediaType,
			TblMR.Category,
			_SearchRequestID,
			COUNT(archive.ID) AS NoOfDocs,
			SUM( ISNULL(convert(bigint,archive.Number_Hits),0)) AS NoOfHits,
			SUM( ISNULL(convert(bigint,Compete_Audience),0)) AS Audience,
			SUM( ISNULL(IQAdShareValue,0)) AS IQMediaValue,
			SUM( ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
			SUM( ISNULL(NegativeSentiment,0)) AS NegativeSentiment	
	FROM
		#MediaResults_Delete   TblMR	
			 		 JOIN IQAgent_NMResults_Archive archive WITH(NOLOCK) 
						ON TblMR.MediaID = archive.ID
						AND TblMR.MediaType = 'NM'
					--	AND archive.IsActive = 0
	GROUP BY LocalDate,ClientGUID,TblMR.MediaType,TblMR.Category,TblMR._SearchRequestID  
	
	
	Insert into #TmpHourSummaryResults_Delete
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
			#MediaResults_Delete AS TblMR
					INNER JOIN IQAgent_NMResults WITH(NOLOCK) 
						ON TblMR.MediaID = IQAgent_NMResults.ID
						AND TblMR.MediaType = 'NM'
					--	AND IQAgent_NMResults.IsActive = 0
	GROUP BY TblMR.MediaDate_Hour,ClientGUID,TblMR.MediaType,TblMR.Category,TblMR._SearchRequestID 
	
		Insert into #TmpHourSummaryResults_Delete_Archive
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
		COUNT(archive.ID) AS NoOfDocs,
			SUM( ISNULL(convert(bigint,archive.Number_Hits),0)) AS NoOfHits,
			SUM( ISNULL(convert(bigint,Compete_Audience),0)) AS Audience,
			SUM( ISNULL(IQAdShareValue,0)) AS IQMediaValue,
			SUM( ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
			SUM( ISNULL(NegativeSentiment,0)) AS NegativeSentiment	
	FROM
			#MediaResults_Delete AS TblMR
					INNER JOIN IQAgent_NMResults_Archive archive WITH(NOLOCK) 
						ON TblMR.MediaID = archive.ID
						AND TblMR.MediaType = 'NM'
					--	AND archive.IsActive = 0
	GROUP BY TblMR.MediaDate_Hour,ClientGUID,TblMR.MediaType,TblMR.Category,TblMR._SearchRequestID 
	
	
    End

 
 If exists(select COUNT(1) from #MediaResults_Delete where  MediaType='SM' )
    Begin
      INSERT INTO #TmpDaySummaryResults_Delete
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
			MediaDate,
			ClientGUID,
			MediaType,
			Category,
			_SearchRequestID,
			COUNT(IQAgent_SMResults.ID) AS NoOfDocs,
			SUM( ISNULL(convert(bigint,IQAgent_SMResults.Number_Hits),0)) AS NoOfHits,
			SUM( ISNULL(convert(bigint,Compete_Audience),0)) AS Audience,
			SUM( ISNULL(IQAdShareValue,0)) AS IQMediaValue,
			SUM( ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
			SUM( ISNULL(NegativeSentiment,0)) AS NegativeSentiment	
	    FROM
			#MediaResults_Delete  TblMR		
			 		 JOIN IQAgent_SMResults  WITH(NOLOCK) 
						ON TblMR.MediaID = IQAgent_SMResults.ID
						AND TblMR.MediaType = 'SM'
					--	AND IQAgent_SMResults.IsActive = 0
	GROUP BY TblMR.MediaDate,ClientGUID,TblMR.MediaType,TblMR.Category,TblMR._SearchRequestID
	
	  INSERT INTO #TmpDaySummaryResults_Delete_Archive
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
			MediaDate,
			ClientGUID,
			MediaType,
			Category,
			_SearchRequestID,
			COUNT(archive.ID) AS NoOfDocs,
			SUM( ISNULL(convert(bigint,archive.Number_Hits),0)) AS NoOfHits,
			SUM( ISNULL(convert(bigint,Compete_Audience),0)) AS Audience,
			SUM( ISNULL(IQAdShareValue,0)) AS IQMediaValue,
			SUM( ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
			SUM( ISNULL(NegativeSentiment,0)) AS NegativeSentiment	
	    FROM
			#MediaResults_Delete  TblMR		
			 		 JOIN IQAgent_SMResults_Archive archive  WITH(NOLOCK) 
						ON TblMR.MediaID = archive.ID
						AND TblMR.MediaType = 'SM'
					--	AND archive.IsActive = 0
	GROUP BY TblMR.MediaDate,ClientGUID,TblMR.MediaType,TblMR.Category,TblMR._SearchRequestID
	
	
	INSERT INTO #TmpDaySummaryLDResults_Delete
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
			LocalDate,
			ClientGUID,
			MediaType,
			Category,
			_SearchRequestID,
			COUNT(IQAgent_SMResults.ID) AS NoOfDocs,
			SUM( ISNULL(convert(bigint,IQAgent_SMResults.Number_Hits),0)) AS NoOfHits,
			SUM( ISNULL(convert(bigint,Compete_Audience),0)) AS Audience,
			SUM( ISNULL(IQAdShareValue,0)) AS IQMediaValue,
			SUM( ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
			SUM( ISNULL(NegativeSentiment,0)) AS NegativeSentiment	
	FROM
		#MediaResults_Delete   TblMR	
			 		 JOIN IQAgent_SMResults  WITH(NOLOCK) 
						ON TblMR.MediaID = IQAgent_SMResults.ID
						AND TblMR.MediaType = 'SM'
					--	AND IQAgent_SMResults.IsActive = 0
	GROUP BY LocalDate,ClientGUID,TblMR.MediaType,TblMR.Category,TblMR._SearchRequestID   
	
	INSERT INTO #TmpDaySummaryLDResults_Delete_Archive
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
			LocalDate,
			ClientGUID,
			MediaType,
			Category,
			_SearchRequestID,
			COUNT(archive.ID) AS NoOfDocs,
			SUM( ISNULL(convert(bigint,archive.Number_Hits),0)) AS NoOfHits,
			SUM( ISNULL(convert(bigint,Compete_Audience),0)) AS Audience,
			SUM( ISNULL(IQAdShareValue,0)) AS IQMediaValue,
			SUM( ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
			SUM( ISNULL(NegativeSentiment,0)) AS NegativeSentiment	
	FROM
		#MediaResults_Delete   TblMR	
			 		 JOIN IQAgent_SMResults_Archive archive WITH(NOLOCK) 
						ON TblMR.MediaID = archive.ID
						AND TblMR.MediaType = 'SM'
					--	AND archive.IsActive = 0
	GROUP BY LocalDate,ClientGUID,TblMR.MediaType,TblMR.Category,TblMR._SearchRequestID   
	
	Insert into #TmpHourSummaryResults_Delete
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
		COUNT(IQAgent_SMResults.ID) AS NoOfDocs,
			SUM( ISNULL(convert(bigint,IQAgent_SMResults.Number_Hits),0)) AS NoOfHits,
			SUM( ISNULL(convert(bigint,Compete_Audience),0)) AS Audience,
			SUM( ISNULL(IQAdShareValue,0)) AS IQMediaValue,
			SUM( ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
			SUM( ISNULL(NegativeSentiment,0)) AS NegativeSentiment	
	FROM
			#MediaResults_Delete AS TblMR
					INNER JOIN IQAgent_SMResults WITH(NOLOCK) 
						ON TblMR.MediaID = IQAgent_SMResults.ID
						AND TblMR.MediaType = 'SM'
				--		AND IQAgent_SMResults.IsActive = 0
	GROUP BY TblMR.MediaDate_Hour,ClientGUID,TblMR.MediaType,TblMR.Category,TblMR._SearchRequestID 
	
		Insert into #TmpHourSummaryResults_Delete_Archive
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
		COUNT(archive.ID) AS NoOfDocs,
			SUM( ISNULL(convert(bigint,archive.Number_Hits),0)) AS NoOfHits,
			SUM( ISNULL(convert(bigint,Compete_Audience),0)) AS Audience,
			SUM( ISNULL(IQAdShareValue,0)) AS IQMediaValue,
			SUM( ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
			SUM( ISNULL(NegativeSentiment,0)) AS NegativeSentiment	
	FROM
			#MediaResults_Delete AS TblMR
					INNER JOIN IQAgent_SMResults_Archive archive WITH(NOLOCK) 
						ON TblMR.MediaID = archive.ID
						AND TblMR.MediaType = 'SM'
					--	AND archive.IsActive = 0
	GROUP BY TblMR.MediaDate_Hour,ClientGUID,TblMR.MediaType,TblMR.Category,TblMR._SearchRequestID 
    End
    

       -- For Twitter
 If exists(select COUNT(1) from #MediaResults_Delete where  MediaType='TW' )
    Begin
      INSERT INTO #TmpDaySummaryResults_Delete
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
			MediaDate,
			ClientGUID,
			MediaType,
			Category,
			_SearchRequestID,
			COUNT(IQAgent_TwitterResults.ID) AS NoOfDocs,
			SUM( ISNULL(convert(bigint,IQAgent_TwitterResults.Number_Hits),0)) AS NoOfHits,
			SUM( ISNULL(convert(bigint,actor_followersCount),0)) AS Audience,
			SUM( ISNULL(gnip_klout_score,0)) AS IQMediaValue,
			SUM( ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
			SUM( ISNULL(NegativeSentiment,0)) AS NegativeSentiment
	    FROM
			#MediaResults_Delete  TblMR		
			 		 JOIN IQAgent_TwitterResults  WITH(NOLOCK) 
						ON TblMR.MediaID = IQAgent_TwitterResults.ID
						AND TblMR.MediaType = 'TW'
					--	AND IQAgent_TwitterResults.IsActive = 0
	GROUP BY TblMR.MediaDate,ClientGUID,TblMR.MediaType,TblMR.Category,TblMR._SearchRequestID
	
	      INSERT INTO #TmpDaySummaryResults_Delete_Archive
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
			MediaDate,
			ClientGUID,
			MediaType,
			Category,
			_SearchRequestID,
			COUNT(archive.ID) AS NoOfDocs,
			SUM( ISNULL(convert(bigint,archive.Number_Hits),0)) AS NoOfHits,
			SUM( ISNULL(convert(bigint,actor_followersCount),0)) AS Audience,
			SUM( ISNULL(gnip_klout_score,0)) AS IQMediaValue,
			SUM( ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
			SUM( ISNULL(NegativeSentiment,0)) AS NegativeSentiment
	    FROM
			#MediaResults_Delete  TblMR		
			 		 JOIN IQAgent_TwitterResults_Archive  archive WITH(NOLOCK) 
						ON TblMR.MediaID = archive.ID
						AND TblMR.MediaType = 'TW'
					--	AND archive.IsActive = 0
	GROUP BY TblMR.MediaDate,ClientGUID,TblMR.MediaType,TblMR.Category,TblMR._SearchRequestID
	
	INSERT INTO #TmpDaySummaryLDResults_Delete
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
			LocalDate,
			ClientGUID,
			MediaType,
			Category,
			_SearchRequestID,
			COUNT(IQAgent_TwitterResults.ID) AS NoOfDocs,
			SUM( ISNULL(convert(bigint,IQAgent_TwitterResults.Number_Hits),0)) AS NoOfHits,
			SUM( ISNULL(convert(bigint,actor_followersCount),0)) AS Audience,
			SUM( ISNULL(gnip_klout_score,0)) AS IQMediaValue,
			SUM( ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
			SUM( ISNULL(NegativeSentiment,0)) AS NegativeSentiment	
	FROM
		#MediaResults_Delete   TblMR	
			 		 JOIN IQAgent_TwitterResults  WITH(NOLOCK) 
						ON TblMR.MediaID = IQAgent_TwitterResults.ID
						AND TblMR.MediaType = 'TW'
					--	AND IQAgent_TwitterResults.IsActive = 0 
	GROUP BY LocalDate,ClientGUID,TblMR.MediaType,TblMR.Category,TblMR._SearchRequestID   
	
	INSERT INTO #TmpDaySummaryLDResults_Delete_Archive
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
			LocalDate,
			ClientGUID,
			MediaType,
			Category,
			_SearchRequestID,
			COUNT(archive.ID) AS NoOfDocs,
			SUM( ISNULL(convert(bigint,archive.Number_Hits),0)) AS NoOfHits,
			SUM( ISNULL(convert(bigint,actor_followersCount),0)) AS Audience,
			SUM( ISNULL(gnip_klout_score,0)) AS IQMediaValue,
			SUM( ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
			SUM( ISNULL(NegativeSentiment,0)) AS NegativeSentiment	
	FROM
		#MediaResults_Delete   TblMR	
			 		 JOIN IQAgent_TwitterResults_Archive archive  WITH(NOLOCK) 
						ON TblMR.MediaID = archive.ID
						AND TblMR.MediaType = 'TW'
					--	AND archive.IsActive = 0 
	GROUP BY LocalDate,ClientGUID,TblMR.MediaType,TblMR.Category,TblMR._SearchRequestID   
	
	Insert into #TmpHourSummaryResults_Delete
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
		COUNT(IQAgent_TwitterResults.ID) AS NoOfDocs,
			SUM( ISNULL(convert(bigint,IQAgent_TwitterResults.Number_Hits),0)) AS NoOfHits,
			SUM( ISNULL(convert(bigint,actor_followersCount),0)) AS Audience,
			SUM( ISNULL(gnip_klout_score,0)) AS IQMediaValue,
			SUM( ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
			SUM( ISNULL(NegativeSentiment,0)) AS NegativeSentiment
	FROM
			#MediaResults_Delete AS TblMR
					INNER JOIN IQAgent_TwitterResults WITH(NOLOCK) 
						ON TblMR.MediaID = IQAgent_TwitterResults.ID
						AND TblMR.MediaType = 'TW'
					--	AND IQAgent_TwitterResults.IsActive = 0
	GROUP BY TblMR.MediaDate_Hour,ClientGUID,TblMR.MediaType,TblMR.Category,TblMR._SearchRequestID 
	
		Insert into #TmpHourSummaryResults_Delete_Archive
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
		COUNT(archive.ID) AS NoOfDocs,
			SUM( ISNULL(convert(bigint,archive.Number_Hits),0)) AS NoOfHits,
			SUM( ISNULL(convert(bigint,actor_followersCount),0)) AS Audience,
			SUM( ISNULL(gnip_klout_score,0)) AS IQMediaValue,
			SUM( ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
			SUM( ISNULL(NegativeSentiment,0)) AS NegativeSentiment
	FROM
			#MediaResults_Delete AS TblMR
					INNER JOIN IQAgent_TwitterResults_Archive archive WITH(NOLOCK) 
						ON TblMR.MediaID = archive.ID
						AND TblMR.MediaType = 'TW'
					--	AND archive.IsActive = 0
	GROUP BY TblMR.MediaDate_Hour,ClientGUID,TblMR.MediaType,TblMR.Category,TblMR._SearchRequestID 
	
	
    End
    
        -- For TM
 If exists(select COUNT(1) from #MediaResults_Delete where  MediaType='TM' )
    Begin
      INSERT INTO #TmpDaySummaryResults_Delete
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
			MediaDate,
			ClientGUID,
			MediaType,
			Category,
			_SearchRequestID,
			COUNT(IQAgent_TVEyesResults.ID) AS NoOfDocs,
			0 AS NoOfHits,
			0 AS Audience,
			0 AS IQMediaValue,
			SUM(ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
			SUM(ISNULL(NegativeSentiment,0)) AS NegativeSentiment	
	    FROM
			#MediaResults_Delete  TblMR		
			 		 JOIN IQAgent_TVEyesResults  WITH(NOLOCK) 
						ON TblMR.MediaID = IQAgent_TVEyesResults.ID
						AND TblMR.MediaType = 'TM'
				--		AND IQAgent_TVEyesResults.IsActive = 0
	GROUP BY TblMR.MediaDate,ClientGUID,TblMR.MediaType,TblMR.Category,TblMR._SearchRequestID
	
	    INSERT INTO #TmpDaySummaryResults_Delete_Archive
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
			MediaDate,
			ClientGUID,
			MediaType,
			Category,
			_SearchRequestID,
			COUNT(archive.ID) AS NoOfDocs,
			0 AS NoOfHits,
			0 AS Audience,
			0 AS IQMediaValue,
			SUM(ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
			SUM(ISNULL(NegativeSentiment,0)) AS NegativeSentiment	
	    FROM
			#MediaResults_Delete  TblMR		
			 		 JOIN IQAgent_TVEyesResults_Archive archive  WITH(NOLOCK) 
						ON TblMR.MediaID = archive.ID
						AND TblMR.MediaType = 'TM'
					--	AND archive.IsActive = 0
	GROUP BY TblMR.MediaDate,ClientGUID,TblMR.MediaType,TblMR.Category,TblMR._SearchRequestID
	
	
	INSERT INTO #TmpDaySummaryLDResults_Delete
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
			LocalDate,
			ClientGUID,
			MediaType,
			Category,
			_SearchRequestID,
		COUNT(IQAgent_TVEyesResults.ID) AS NoOfDocs,
			0 AS NoOfHits,
			0 AS Audience,
			0 AS IQMediaValue,
			SUM(ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
			SUM(ISNULL(NegativeSentiment,0)) AS NegativeSentiment	
	FROM
		#MediaResults_Delete   TblMR	
			 		 JOIN IQAgent_TVEyesResults  WITH(NOLOCK) 
						ON TblMR.MediaID = IQAgent_TVEyesResults.ID
						AND TblMR.MediaType = 'TM'
				--		AND IQAgent_TVEyesResults.IsActive = 0
	GROUP BY LocalDate,ClientGUID,TblMR.MediaType,TblMR.Category,TblMR._SearchRequestID   
	
	INSERT INTO #TmpDaySummaryLDResults_Delete_Archive
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
			LocalDate,
			ClientGUID,
			MediaType,
			Category,
			_SearchRequestID,
		COUNT(archive.ID) AS NoOfDocs,
			0 AS NoOfHits,
			0 AS Audience,
			0 AS IQMediaValue,
			SUM(ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
			SUM(ISNULL(NegativeSentiment,0)) AS NegativeSentiment	
	FROM
		#MediaResults_Delete   TblMR	
			 		 JOIN IQAgent_TVEyesResults_Archive archive  WITH(NOLOCK) 
						ON TblMR.MediaID = archive.ID
						AND TblMR.MediaType = 'TM'
					--	AND archive.IsActive = 0
	GROUP BY LocalDate,ClientGUID,TblMR.MediaType,TblMR.Category,TblMR._SearchRequestID   
		
	Insert into #TmpHourSummaryResults_Delete
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
		COUNT(IQAgent_TVEyesResults.ID) AS NoOfDocs,
			0 AS NoOfHits,
			0 AS Audience,
			0 AS IQMediaValue,
			SUM(ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
			SUM(ISNULL(NegativeSentiment,0)) AS NegativeSentiment	
	FROM
			#MediaResults_Delete AS TblMR
					INNER JOIN IQAgent_TVEyesResults WITH(NOLOCK) 
						ON TblMR.MediaID = IQAgent_TVEyesResults.ID
						AND TblMR.MediaType = 'TM'
					--	AND IQAgent_TVEyesResults.IsActive = 0
	GROUP BY TblMR.MediaDate_Hour,ClientGUID,TblMR.MediaType,TblMR.Category,TblMR._SearchRequestID 
	
	Insert into #TmpHourSummaryResults_Delete_Archive
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
		COUNT(archive.ID) AS NoOfDocs,
			0 AS NoOfHits,
			0 AS Audience,
			0 AS IQMediaValue,
			SUM(ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
			SUM(ISNULL(NegativeSentiment,0)) AS NegativeSentiment	
	FROM
			#MediaResults_Delete AS TblMR
					INNER JOIN IQAgent_TVEyesResults_Archive archive WITH(NOLOCK) 
						ON TblMR.MediaID = archive.ID
						AND TblMR.MediaType = 'TM'
				--		AND archive.IsActive = 0
	GROUP BY TblMR.MediaDate_Hour,ClientGUID,TblMR.MediaType,TblMR.Category,TblMR._SearchRequestID 
	
	
    End
    
         -- For PM
 If exists(select COUNT(1) from #MediaResults_Delete where  MediaType='PM' )
    Begin
      INSERT INTO #TmpDaySummaryResults_Delete
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
			MediaDate,
			ClientGUID,
			MediaType,
			Category,
			_SearchRequestID,
				COUNT(IQAgent_BLPMResults.ID) AS NoOfDocs,
			0 AS NoOfHits,
			SUM( ISNULL(convert(bigint,IQAgent_BLPMResults.Circulation),0)) AS Audience,
			0 AS IQMediaValue,
			SUM(ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
			SUM(ISNULL(NegativeSentiment,0)) AS NegativeSentiment	
	    FROM
			#MediaResults_Delete  TblMR		
			 		 JOIN IQAgent_BLPMResults  WITH(NOLOCK) 
						ON TblMR.MediaID = IQAgent_BLPMResults.ID
						AND TblMR.MediaType = 'PM'
					--	AND IQAgent_BLPMResults.IsActive = 0
	GROUP BY TblMR.MediaDate,ClientGUID,TblMR.MediaType,TblMR.Category,TblMR._SearchRequestID
	
	  INSERT INTO #TmpDaySummaryResults_Delete_Archive
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
			MediaDate,
			ClientGUID,
			MediaType,
			Category,
			_SearchRequestID,
				COUNT(archive.ID) AS NoOfDocs,
			0 AS NoOfHits,
			SUM( ISNULL(convert(bigint,archive.Circulation),0)) AS Audience,
			0 AS IQMediaValue,
			SUM(ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
			SUM(ISNULL(NegativeSentiment,0)) AS NegativeSentiment	
	    FROM
			#MediaResults_Delete  TblMR		
			 		 JOIN IQAgent_BLPMResults_Archive archive  WITH(NOLOCK) 
						ON TblMR.MediaID = archive.ID
						AND TblMR.MediaType = 'PM'
				--		AND archive.IsActive = 0
	GROUP BY TblMR.MediaDate,ClientGUID,TblMR.MediaType,TblMR.Category,TblMR._SearchRequestID
	
	
	INSERT INTO #TmpDaySummaryLDResults_Delete
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
			LocalDate,
			ClientGUID,
			MediaType,
			Category,
			_SearchRequestID,
			COUNT(IQAgent_BLPMResults.ID) AS NoOfDocs,
			0 AS NoOfHits,
			SUM( ISNULL(convert(bigint,IQAgent_BLPMResults.Circulation),0)) AS Audience,
			0 AS IQMediaValue,
			SUM(ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
			SUM(ISNULL(NegativeSentiment,0)) AS NegativeSentiment	
	FROM
		#MediaResults_Delete   TblMR	
			 		 JOIN IQAgent_BLPMResults  WITH(NOLOCK) 
						ON TblMR.MediaID = IQAgent_BLPMResults.ID
						AND TblMR.MediaType = 'PM'
					--	AND IQAgent_BLPMResults.IsActive = 0
	GROUP BY LocalDate,ClientGUID,TblMR.MediaType,TblMR.Category,TblMR._SearchRequestID   
	
	INSERT INTO #TmpDaySummaryLDResults_Delete_Archive
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
			LocalDate,
			ClientGUID,
			MediaType,
			Category,
			_SearchRequestID,
			COUNT(archive.ID) AS NoOfDocs,
			0 AS NoOfHits,
			SUM( ISNULL(convert(bigint,archive.Circulation),0)) AS Audience,
			0 AS IQMediaValue,
			SUM(ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
			SUM(ISNULL(NegativeSentiment,0)) AS NegativeSentiment	
	FROM
		#MediaResults_Delete   TblMR	
			 		 JOIN IQAgent_BLPMResults_Archive archive  WITH(NOLOCK) 
						ON TblMR.MediaID = archive.ID
						AND TblMR.MediaType = 'PM'
					--	AND archive.IsActive = 0
	GROUP BY LocalDate,ClientGUID,TblMR.MediaType,TblMR.Category,TblMR._SearchRequestID 
	
	Insert into #TmpHourSummaryResults_Delete
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
			COUNT(IQAgent_BLPMResults.ID) AS NoOfDocs,
			0 AS NoOfHits,
			SUM( ISNULL(convert(bigint,IQAgent_BLPMResults.Circulation),0)) AS Audience,
			0 AS IQMediaValue,
			SUM(ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
			SUM(ISNULL(NegativeSentiment,0)) AS NegativeSentiment	
	FROM
			#MediaResults_Delete AS TblMR
					INNER JOIN IQAgent_BLPMResults WITH(NOLOCK) 
						ON TblMR.MediaID = IQAgent_BLPMResults.ID
						AND TblMR.MediaType = 'PM'
					--	AND IQAgent_BLPMResults.IsActive = 0
	GROUP BY TblMR.MediaDate_Hour,ClientGUID,TblMR.MediaType,TblMR.Category,TblMR._SearchRequestID 
	
	Insert into #TmpHourSummaryResults_Delete_Archive
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
			COUNT(archive.ID) AS NoOfDocs,
			0 AS NoOfHits,
			SUM( ISNULL(convert(bigint,archive.Circulation),0)) AS Audience,
			0 AS IQMediaValue,
			SUM(ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
			SUM(ISNULL(NegativeSentiment,0)) AS NegativeSentiment	
	FROM
			#MediaResults_Delete AS TblMR
					INNER JOIN IQAgent_BLPMResults_Archive archive WITH(NOLOCK) 
						ON TblMR.MediaID = archive.ID
						AND TblMR.MediaType = 'PM'
					--	AND archive.IsActive = 0
	GROUP BY TblMR.MediaDate_Hour,ClientGUID,TblMR.MediaType,TblMR.Category,TblMR._SearchRequestID 
	
	
    End

	        -- For PQ
 If exists(select COUNT(1) from #MediaResults_Delete where  MediaType='PQ' )
    Begin
      INSERT INTO #TmpDaySummaryResults_Delete
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
			TblMR.MediaDate,
			ClientGUID,
			MediaType,
			Category,
			_SearchRequestID,
		    COUNT(IQAgent_PQResults.ID) AS NoOfDocs,
			SUM(ISNULL(convert(bigint,IQAgent_PQResults.Number_Hits),0)) AS NoOfHits,  
			0 AS Audience,
			0 AS IQMediaValue,
		    SUM(ISNULL(PositiveSentiment,0)) AS PositiveSentiment,         
	        SUM(ISNULL(NegativeSentiment ,0)) AS NegativeSentiment	
	    FROM
			#MediaResults_Delete  TblMR		
			 		 JOIN IQAgent_PQResults  WITH(NOLOCK) 
						ON TblMR.MediaID = IQAgent_PQResults.ID
						AND TblMR.MediaType = 'PQ'
					--	AND IQAgent_PQResults.IsActive = 0
	GROUP BY TblMR.MediaDate,ClientGUID,TblMR.MediaType,TblMR.Category,TblMR._SearchRequestID
	
	INSERT INTO #TmpDaySummaryLDResults_Delete
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
			TblMR.MediaDate,
			ClientGUID,
			MediaType,
			Category,
			_SearchRequestID,
			COUNT(IQAgent_PQResults.ID) AS NoOfDocs,
			SUM(ISNULL(convert(bigint,IQAgent_PQResults.Number_Hits),0)) AS NoOfHits,  
			0 AS Audience,
			0 AS IQMediaValue,
		    SUM(ISNULL(PositiveSentiment,0)) AS PositiveSentiment,         
	        SUM(ISNULL(NegativeSentiment ,0)) AS NegativeSentiment	
	FROM
		#MediaResults_Delete   TblMR	
			 		 JOIN IQAgent_PQResults  WITH(NOLOCK) 
						ON TblMR.MediaID = IQAgent_PQResults.ID
						AND TblMR.MediaType = 'PQ'
					--	AND IQAgent_PQResults.IsActive = 0
	GROUP BY TblMR.MediaDate,ClientGUID,TblMR.MediaType,TblMR.Category,TblMR._SearchRequestID   
	
	Insert into #TmpHourSummaryResults_Delete
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
			COUNT(IQAgent_PQResults.ID) AS NoOfDocs,
			SUM(ISNULL(convert(bigint,IQAgent_PQResults.Number_Hits),0)) AS NoOfHits,  
			0 AS Audience,
			0 AS IQMediaValue,
		    SUM(ISNULL(PositiveSentiment,0)) AS PositiveSentiment,         
	        SUM(ISNULL(NegativeSentiment ,0)) AS NegativeSentiment	
	FROM
			#MediaResults_Delete AS TblMR
					INNER JOIN IQAgent_PQResults WITH(NOLOCK) 
						ON TblMR.MediaID = IQAgent_PQResults.ID
						AND TblMR.MediaType = 'PQ'
					--	AND IQAgent_PQResults.IsActive = 0
	GROUP BY TblMR.MediaDate_Hour,ClientGUID,TblMR.MediaType,TblMR.Category,TblMR._SearchRequestID 
	
	End
		
 Create index idx1_TmpDaySummaryResults_Delete on #TmpDaySummaryResults_Delete(ClientGUID,_SearchRequestID,MediaDate,MediaType,SubMediaType)
 Create index idx1_TmpDaySummaryLDResults_Delete on #TmpDaySummaryLDResults_Delete(ClientGUID,_SearchRequestID,LocalMediaDate,MediaType,SubMediaType)
 Create index idx1_TmpHourSummaryResults_Delete on #TmpHourSummaryResults_Delete(ClientGUID,_SearchRequestID,MediaDateTime,MediaType,SubMediaType)
 
  Create index idx1_TmpDaySummaryResults_Delete_Archive on #TmpDaySummaryResults_Delete_Archive(ClientGUID,_SearchRequestID,MediaDate,MediaType,SubMediaType)
 Create index idx1_TmpDaySummaryLDResults_Delete_Archive on #TmpDaySummaryLDResults_Delete_Archive(ClientGUID,_SearchRequestID,LocalMediaDate,MediaType,SubMediaType)
 Create index idx1_TmpHourSummaryResults_Delete_Archive on #TmpHourSummaryResults_Delete_Archive(ClientGUID,_SearchRequestID,MediaDateTime,MediaType,SubMediaType)

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
				@CreatedBy='usp_v4_IQAgent_MediaResults_Dirtytbl_process_build_DayHourSummary_Delete',
				@ModifiedBy='usp_v4_IQAgent_MediaResults_Dirtytbl_process_build_DayHourSummary_Delete',
				@CreatedDate=GETDATE(),
				@ModifiedDate=GETDATE(),
				@IsActive=1
				
		
		EXEC usp_IQMediaGroupExceptions_Insert @ExceptionStackTrace,@ExceptionMessage,@CreatedBy,@CreatedDate,NULL,@IQMediaGroupExceptionKey OUTPUT
		Return 1
  END CATCH      
  

    
END