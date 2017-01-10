USE [IQMediaGroup]
GO

/****** Object:  StoredProcedure [dbo].[usp_pshell_IQAgent_QHLRResults_Insert]    Script Date: 3/16/2016 2:16:09 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_pshell_IQAgent_QHLRResults_Insert] 
	@SearchRequestID BIGINT,
	@NumberOfRecord INT OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET XACT_ABORT ON;
	
	DECLARE @StopWatch DATETIME,@SPStartTime DATETIME,@SPTrackingID UNIQUEIDENTIFIER, @TimeDiff DECIMAL(18,2),@SPName VARCHAR(100),@QueryDetail VARCHAR(500)    
	
	SET @SPStartTime=GETDATE()
	SET @Stopwatch=GETDATE()
	SET @SPTrackingID = NEWID()
	SET @SPName ='usp_pshell_IQAgent_LRResults_Insert'
	
     
BEGIN TRY 
  
 
  DECLARE @lrid TABLE (lrid BIGINT)
  DECLARE @NumCount INT
  DECLARE @LastIQSeqID BIGINT = 0, @ProcessLastIQSeqID BIGINT

  INSERT INTO @lrid(lrid)
  SELECT   Tbl.SearchRequestList.value('.', 'varchar(20)') FROM IQAgent_SearchRequest WITH (NOLOCK)
  CROSS APPLY SearchTerm.nodes('/SearchRequest/LR/SearchIDs/LRSRID') AS Tbl(SearchRequestList) 
  WHERE ID = @SearchRequestID

  SELECT @NumCount = count(1) FROM @lrid

  IF (@NumCount = 0 )
     BEGIN
	   SET @NumberOfRecord = 0
	   RETURN 0
	 END
	
CREATE TABLE #IQAgent_LRResults_1
	(
	IQ_CC_KEY varchar(28) NOT NULL,
	StartingPoint smallint NULL,
	Stationid varchar(20) NULL,
	_SearchLogoid bigint NOT NULL,
	Hits xml NULL,
	Hit_Count SMALLINT NULL
	)

CREATE TABLE #IQAgent_LRResults
  (
  IQ_CC_KEY varchar(28) NOT NULL,
  StartingPoint smallint NULL,
  Stationid varchar(20) NULL,
  _SearchLogoid bigint NOT NULL,
  Hits xml NULL,
  NumOfHits int NULL,
  Hit_Count SMALLINT NULL,
  Earned int NULL,
  Paid int NULL
  )


SELECT @LastIQSeqID =  LastIQSeqID FROM IQAgent_LastIQSeqID WITH (NOLOCK) WHERE _SearchRequestID = @SearchRequestID AND MediaType='LR'

INSERT INTO #IQAgent_LRResults_1(
			IQ_CC_KEY,
			StartingPoint,
			Stationid,
			_SearchLogoid,
			Hits,
			Hit_Count 
			)
SELECT 		R.IQ_CC_KEY,
			CASE WHEN Tbl.HitList.value('.', 'SMALLINT') BETWEEN 0 AND 900 THEN 1
			     WHEN Tbl.HitList.value('.', 'SMALLINT')  BETWEEN 900 AND 1800 THEN 2
				 WHEN Tbl.HitList.value('.', 'SMALLINT') BETWEEN 1800 AND 2700 THEN 3
				 WHEN Tbl.HitList.value('.', 'SMALLINT') BETWEEN 2700 AND 3600  THEN 4
			END AS StartPoint,
			R.StationID,
			R._SearchLogoID,
			R.Hits,
			R.Hit_Count
	FROM IQ_LR_Results R WITH (NOLOCK)
	CROSS APPLY Hits.nodes('/LROffsets/Hits/Offset') AS Tbl(HitList)
	JOIN @lrid ON lrid = R._SearchLogoID
	WHERE  R.ID > @LastIQSeqID 
	       AND  R.IsActive = 1 
		   AND R.Hit_Count > 0

	INSERT INTO #IQAgent_LRResults(
		IQ_CC_KEY,
		StartingPoint,
		Stationid,
		_SearchLogoid,
		NumOfHits)
	SELECT 
			R.IQ_CC_KEY,
			R.StartingPoint,
			R.StationID,
			R._SearchLogoID,
			COUNT(1)
	FROM #IQAgent_LRResults_1 R
			WHERE R.StartingPoint IS NOT NULL
			GROUP BY R.IQ_CC_KEY,R.StartingPoint,R.StationID,R._SearchLogoID

	CREATE INDEX idx1 ON #IQAgent_LRResults_1 (iq_cc_key,StartingPoint,_SearchLogoID)
	CREATE INDEX idx2 ON #IQAgent_LRResults (iq_cc_key,StartingPoint,_SearchLogoID)

    EXEC usp_pshell_IQAgent_QHLRResults_Insert_sub_process WITH RECOMPILE

BEGIN TRANSACTION
 
	 INSERT INTO IQAgent_LRResults(
			IQAgentSearchRequestID,
			IQ_CC_KEY,
			StartingPoint,
			Stationid,
			_SearchLogoid,
			Hits,
			NumOfHits,
			Earned,
			Paid)
	SELECT @SearchRequestID,
			tmp.IQ_CC_KEY,
			tmp.StartingPoint,
			tmp.Stationid,
			tmp._SearchLogoid,
			tmp.Hits,
			tmp.NumOfHits,
			ISNULL((tmp.NumOfHits - ISNULL(tmp.Paid,0)),0),
			ISNULL(tmp.Paid,0)  
			FROM #IQAgent_LRResults tmp
			LEFT OUTER JOIN IQAgent_LRResults WITH(NOLOCK)        
			ON IQAgent_LRResults.IQAgentSearchRequestID = @SearchRequestID 
				AND IQAgent_LRResults.IQ_CC_Key = Tmp.IQ_CC_Key 
				AND IQAgent_LRResults.StartingPoint = Tmp.StartingPoint
				AND IQAgent_LRResults._SearchLogoid = tmp._SearchLogoid
				AND IQAgent_LRResults.IsActive = 1

		WHERE   IQAgent_LRResults.IQAgentSearchRequestID IS NULL
			

	SET @NumberOfRecord = @@ROWCOUNT

	SELECT @ProcessLastIQSeqID = MAX(ID)
		FROM IQ_LR_Results R WITH (NOLOCK), @lrid
			WHERE lrid = R._SearchLogoID
				  AND    R.ID > @LastIQSeqID 
			      AND    R.IsActive = 1

	IF EXISTS (SELECT ID FROM IQAgent_LastIQSeqID WITH (NOLOCK) WHERE _SearchRequestID = @SearchRequestID AND MediaType='LR')
	   UPDATE IQAgent_LastIQSeqID SET LastIQSeqID = @ProcessLastIQSeqID, ModifiedDate = GETDATE() WHERE _SearchRequestID = @SearchRequestID AND MediaType='LR'
	ELSE
	   INSERT INTO IQAgent_LastIQSeqID (_SearchRequestID,MediaType,LastIQSeqID,CreatedDate,ModifiedDate,IsActive) 
	   VALUES(@SearchRequestID,'LR',@ProcessLastIQSeqID,GETDATE(),GETDATE(),1)

 COMMIT TRANSACTION

	SET @QueryDetail ='usp_pshell_IQAgent_LRResults_Insert.'
	SET @TimeDiff = DATEDIFF(ms, @Stopwatch, GETDATE())
	INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) VALUES(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
			-- SET @Stopwatch = GETDATE()
	RETURN 0
END TRY
BEGIN CATCH        
   
   IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION;  
   
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
				@CreatedBy='usp_pshell_IQAgent_LRResults_Insert',
				@ModifiedBy='usp_pshell_IQAgent_LRResults_Insert',
				@CreatedDate=GETDATE(),
				@ModifiedDate=GETDATE()
			--	@IsActive=1
				
        EXEC usp_IQMediaGroupExceptions_Insert @ExceptionStackTrace,@ExceptionMessage,@CreatedBy,@CreatedDate,NULL,@IQMediaGroupExceptionKey OUTPUT
        SET @NumberOfRecord = 0
		RETURN -1
END CATCH     
      
END






GO


