USE [IQMediaGroup]
GO

/****** Object:  StoredProcedure [dbo].[usp_Refresh_IQAgent_DayHourSummary]    Script Date: 8/12/2015 10:00:33 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_Refresh_IQAgent_DayHourSummary]
@Max_MediaResultID Bigint output
AS
BEGIN
   
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

-- Created Date :	May 2015
-- Description   :  To refresh IQAgent_DaySummary and IQAgent_HourSummar tables. 

BEGIN TRY  	
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
	--	[LocalMediaDate] DATE NOT NULL,
	    [LocalMediaDate] DATETIME NULL,
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
	--	LocalMediaDate,
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
	--	convert(date,CASE WHEN dbo.fnIsDayLightSaving(IQAgent_MediaResults.MediaDate) = 1 THEN  DATEADD(HOUR,(SELECT gmt + dst From Client where ClientGuid = IQAgent_SearchRequest.ClientGUID),IQAgent_MediaResults.MediaDate) ELSE DATEADD(HOUR,(SELECT gmt From Client where ClientGuid = IQAgent_SearchRequest.ClientGUID),IQAgent_MediaResults.MediaDate) END),
		ISNULL(PositiveSentiment,0),
		ISNULL(NegativeSentiment,0),
		IQAgent_SearchRequest.ClientGUID
	FROM
		IQAgent_MediaResults WITH (nolock) --(index(IX_IQAgent_MediaResults_SearchRequestID),NOLOCK,forceseek)
			 JOIN IQAgent_SearchRequest WITH(NOLOCK)
				ON		IQAgent_MediaResults._SearchRequestID=IQAgent_SearchRequest.ID AND	IQAgent_SearchRequest.IsActive>0
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
	--	LocalMediaDate,
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
	--	convert(date,CASE WHEN dbo.fnIsDayLightSaving(mr.MediaDate) = 1 THEN  DATEADD(HOUR,(SELECT gmt + dst From Client where ClientGuid = IQAgent_SearchRequest.ClientGUID),mr.MediaDate) ELSE DATEADD(HOUR,(SELECT gmt From Client where ClientGuid = IQAgent_SearchRequest.ClientGUID),mr.MediaDate) END),
		ISNULL(PositiveSentiment,0),
		ISNULL(NegativeSentiment,0),
		IQAgent_SearchRequest.ClientGUID
	FROM
		IQAgent_MediaResults_Archive_2013 mr WITH (nolock) --(index(IX_IQAgent_MediaResults_Archive_2013_SearchRequestID),NOLOCK,forceseek)
			 JOIN IQAgent_SearchRequest WITH(NOLOCK)
				ON		mr._SearchRequestID=IQAgent_SearchRequest.ID AND	IQAgent_SearchRequest.IsActive>0
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
	--	LocalMediaDate,
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
	--	convert(date,CASE WHEN dbo.fnIsDayLightSaving(mr.MediaDate) = 1 THEN  DATEADD(HOUR,(SELECT gmt + dst From Client where ClientGuid = IQAgent_SearchRequest.ClientGUID),mr.MediaDate) ELSE DATEADD(HOUR,(SELECT gmt From Client where ClientGuid = IQAgent_SearchRequest.ClientGUID),mr.MediaDate) END),
		ISNULL(PositiveSentiment,0),
		ISNULL(NegativeSentiment,0),
		IQAgent_SearchRequest.ClientGUID
	FROM
		IQAgent_MediaResults_Archive_2014 mr WITH (nolock)  --(index(IX_IQAgent_MediaResults_Archive_2014_SearchRequestID),NOLOCK,forceseek)
			 JOIN IQAgent_SearchRequest WITH(NOLOCK)
				ON		mr._SearchRequestID=IQAgent_SearchRequest.ID AND	IQAgent_SearchRequest.IsActive>0
		WHERE	mr.IsActive=1

		update #TblMediaResults
	set [LocalMediaDate]=convert(date,CASE WHEN dbo.fnIsDayLightSaving(mr1.MediaDate) = 1 
	THEN  DATEADD(HOUR,(SELECT gmt + dst From Client where ClientGuid = mr1.ClientGUID),mr1.MediaDate) ELSE DATEADD(HOUR,(SELECT gmt From Client where ClientGuid = mr1.ClientGUID),
	mr1.MediaDate) END)
	from #TblMediaResults mr1 

	select @Max_MediaResultID = max (ID) from #TblMediaResults

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
				@CreatedBy='usp_Refresh_IQAgent_DayHourSummary]',
				@ModifiedBy='usp_Refresh_IQAgent_DayHourSummary]',
				@CreatedDate=GETDATE(),
				@ModifiedDate=GETDATE(),
				@IsActive=1
	

				EXEC usp_IQMediaGroupExceptions_Insert @ExceptionStackTrace,@ExceptionMessage,@CreatedBy,@CreatedDate,NULL,@IQMediaGroupExceptionKey OUTPUT    
				Return -1
		END CATCH        

END








GO


