USE [IQMediaGroup]
GO

/****** Object:  StoredProcedure [dbo].[usp_Refresh_IQAgent_DayHourSummary_ByClientGUID]    Script Date: 8/12/2015 10:01:44 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].[usp_Refresh_IQAgent_DayHourSummary_ByClientGUID]
@ClientGUID uniqueidentifier
AS
BEGIN
   
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

-- Created Date :	May 2015
-- Description   :  Called by the usp_v4_IQAgent_SearchRequest_Delete, so it can use the MediaResults temp table index. 

BEGIN TRY  	

declare @GMT int,
		@DST int
		
SELECT @GMT = gmt , @DST = dst from client where ClientGuid =@ClientGUID

DELETE FROM IQAGent_DaySummary_NEW Where ClientGuid = @ClientGUID
DELETE FROM IQAGent_HourSummary_NEW Where ClientGuid = @ClientGUID

Create table #TblMediaResults 
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
		[LocalMediaDate] DATETIME NOT NULL,
		[PositiveSentiment] INT NULL,
		[NegativeSentiment] INT NULL,
		[ClientGUID] uniqueidentifier not null
	)
	
	INSERT INTO #TblMediaResults
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
		NegativeSentiment,
		ClientGUID
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
		convert(date,CASE WHEN dbo.fnIsDayLightSaving(IQAgent_MediaResults.MediaDate) = 1 THEN  DATEADD(HOUR,(@gmt + @dst),MediaDate) ELSE DATEADD(HOUR,(@gmt),MediaDate) END),
		ISNULL(PositiveSentiment,0),
		ISNULL(NegativeSentiment,0),
		IQAgent_SearchRequest.ClientGUID
	FROM
		IQAgent_MediaResults  WITH(index(IX_IQAgent_MediaResults_SearchRequestID),NOLOCK,forceseek)
			 JOIN IQAgent_SearchRequest WITH(NOLOCK)
				ON		IQAgent_MediaResults._SearchRequestID=IQAgent_SearchRequest.ID AND	IQAgent_SearchRequest.IsActive>0 AND IQAgent_SearchRequest.ClientGUID = @CLientGUID
		WHERE	IQAgent_MediaResults.IsActive=1

INSERT INTO #TblMediaResults
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
		NegativeSentiment,
		ClientGUID
	)
	SELECT
		mr.ID,
		_MediaID,
		MediaType,
		Category,
		MediaDate,
		_SearchRequestID,
		_ParentID,
		CONVERT(DATE,MediaDate),
		DATEADD (HOUR,DATEPART(HOUR,MediaDate), CONVERT(VARCHAR(10),MediaDate,101)),
		convert(date,CASE WHEN dbo.fnIsDayLightSaving(mr.MediaDate) = 1 THEN  DATEADD(HOUR,(@gmt + @dst),MediaDate) ELSE DATEADD(HOUR,(@gmt),MediaDate) END),
		ISNULL(PositiveSentiment,0),
		ISNULL(NegativeSentiment,0),
		IQAgent_SearchRequest.ClientGUID
	FROM 
		IQAgent_MediaResults_Archive_2013 mr  WITH(index(IX_IQAgent_MediaResults_Archive_2013_SearchRequestID),NOLOCK,forceseek)
			 JOIN IQAgent_SearchRequest WITH(NOLOCK)
				ON		mr._SearchRequestID=IQAgent_SearchRequest.ID AND	IQAgent_SearchRequest.IsActive>0 AND IQAgent_SearchRequest.ClientGUID = @CLientGUID
		WHERE	mr.IsActive=1
		
 INSERT INTO #TblMediaResults
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
		NegativeSentiment,
		ClientGUID
	)
	SELECT
		mr.ID,
		_MediaID,
		MediaType,
		Category,
		MediaDate,
		_SearchRequestID,
		_ParentID,
		CONVERT(DATE,MediaDate),
		DATEADD (HOUR,DATEPART(HOUR,MediaDate), CONVERT(VARCHAR(10),MediaDate,101)),
		convert(date,CASE WHEN dbo.fnIsDayLightSaving(mr.MediaDate) = 1 THEN  DATEADD(HOUR,(@gmt + @dst),MediaDate) ELSE DATEADD(HOUR,(@gmt),MediaDate) END),
		ISNULL(PositiveSentiment,0),
		ISNULL(NegativeSentiment,0),
		IQAgent_SearchRequest.ClientGUID
	FROM
		IQAgent_MediaResults_Archive_2014 mr  WITH(index(IX_IQAgent_MediaResults_Archive_2014_SearchRequestID),NOLOCK,forceseek)
			 JOIN IQAgent_SearchRequest WITH(NOLOCK)
				ON		mr._SearchRequestID=IQAgent_SearchRequest.ID AND	IQAgent_SearchRequest.IsActive>0 AND IQAgent_SearchRequest.ClientGUID = @CLientGUID
		WHERE	mr.IsActive=1
	

		Create index idx1_TblMediaResults on #TblMediaResults(MediaType,_MediaID)
		exec dbo.usp_Refresh_IQAgent_DayHourSummary_Subprocess_1 with recompile

		
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
				@CreatedBy='usp_Refresh_IQAgent_DayHourSummary_ByClientGUID',
				@ModifiedBy='usp_Refresh_IQAgent_DayHourSummary_ByClientGUID',
				@CreatedDate=GETDATE(),
				@ModifiedDate=GETDATE(),
				@IsActive=1
	

				EXEC usp_IQMediaGroupExceptions_Insert @ExceptionStackTrace,@ExceptionMessage,@CreatedBy,@CreatedDate,NULL,@IQMediaGroupExceptionKey OUTPUT    
				Return -1
		END CATCH        

END







GO


