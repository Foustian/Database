USE [IQMediaGroup]
GO

/****** Object:  StoredProcedure [dbo].[usp_v4_IQAgent_MediaResults_Dirtytbl_Process]    Script Date: 8/12/2015 10:50:16 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO



CREATE PROCEDURE [dbo].[usp_v4_IQAgent_MediaResults_Dirtytbl_Process]        
@NumberOfRecord int, @InsertStatus char(15) output,  @DeleteStatus char(15) output
AS        
BEGIN         
 SET NOCOUNT ON;        
 SET XACT_ABORT ON;
        
  
 BEGIN TRY        
   
   Create table #MediaResults
	(
		DirtyTableID bigint NOT NULL,
		MediaResultsID bigint  NOT NULL,
		MediaID bigint  NOT NULL,
		ClientGuid uniqueidentifier,
		_SearchRequestID BIGINT NOT NULL,
		MediaType VARCHAR(2)  NOT NULL, 
		Category VARCHAR(50)  NOT NULL,
        MediaDate DATETIME   NOT NULL, 
        LocalDate DATETIME NOT NULL,
        MediaDate_Hour DATETIME NOT NULL,
        PositiveSentiment tinyint NULL,
        NegativeSentiment tinyint NULL)
     
         
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
	
          CREATE TABLE #TmpDaySummaryResults_Archive 
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
	
	CREATE TABLE #TmpDaySummaryLDResults_Archive 
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
	
	CREATE TABLE #TmpHourSummaryResults_Archive 
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
	-- Temporary for the Media Delete
	
	Create table #MediaResults_Delete
	(
		DirtyTableID bigint NOT NULL,
		MediaResultsID bigint  NOT NULL,
		MediaID bigint  NOT NULL,
		ClientGuid uniqueidentifier,
		_SearchRequestID BIGINT NOT NULL,
		MediaType VARCHAR(2)  NOT NULL, 
		Category VARCHAR(50)  NOT NULL,
        MediaDate DATETIME   NOT NULL, 
        LocalDate DATETIME NOT NULL,
        MediaDate_Hour DATETIME NOT NULL,
        PositiveSentiment tinyint NULL,
        NegativeSentiment tinyint NULL)
     
         
           CREATE TABLE #TmpDaySummaryResults_Delete 
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
	
	CREATE TABLE #TmpDaySummaryLDResults_Delete 
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
	
	CREATE TABLE #TmpHourSummaryResults_Delete 
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

		     
           CREATE TABLE #TmpDaySummaryResults_Delete_Archive 
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
	
	CREATE TABLE #TmpDaySummaryLDResults_Delete_Archive  
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
	
	CREATE TABLE #TmpHourSummaryResults_Delete_Archive  
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

		
	DECLARE @StartID Bigint, @EndID bigint ,@status smallint    
   
 --   Select  @StartID = min(ID) from dbo.IQAgent_MediaResults_DirtyTable With (NoLock) where IsActive=1
 
 --   Set @EndID = @StartID + @NumberOfRecord

	/*
	    DECLARE @StopWatch DATETIME,@SPStartTime DATETIME,@SPTrackingID UNIQUEIDENTIFIER, @TimeDiff Float    ,@SPName VARCHAR(100),@QueryDetail VARCHAR(500)
    SET @SPStartTime=GETDATE()
	SET @Stopwatch=GETDATE()
	SET @SPTrackingID = NEWID()
	SET @SPName ='usp_v4_IQAgent_MediaResults_Dirtytbl_Process' */
   

 
Insert into  #MediaResults
	(
		DirtyTableID,
		MediaResultsID,
		MediaID,
		ClientGuid,
		_SearchRequestID,
		MediaType, 
		Category,
        MediaDate, 
        LocalDate,
        MediaDate_Hour,
        PositiveSentiment,
        NegativeSentiment
       )
 Select TblMR.ID,
        MediaResultsID,
		MediaID,
		ClientGuid,
		_SearchRequestID,
		MediaType, 
		Category,
        convert(date,MediaDate), 
        CONVERT(date,CASE WHEN dbo.fnIsDayLightSaving(MediaDate) = 1 THEN  DATEADD(HOUR,(SELECT gmt + dst From Client where ClientGuid = IQAgent_SearchRequest.ClientGuid),MediaDate) ELSE DATEADD(HOUR,(SELECT gmt From Client where ClientGuid = IQAgent_SearchRequest.ClientGuid),MediaDate) END),
        DATEADD (HOUR,DATEPART(HOUR,MediaDate), CONVERT(VARCHAR(10),MediaDate,101)),
        ISNULL(PositiveSentiment,0),
        ISNULL(NegativeSentiment,0)
         From dbo.IQAgent_MediaResults_DirtyTable TblMR 	WITH(NOLOCK)
        JOIN dbo.IQAgent_SearchRequest 	WITH(NOLOCK)
			 	 on TblMR._SearchRequestID	= IQAgent_SearchRequest.ID 
			 	 Where  TblMR.IsActive=1 -- TblMR.ID >= @StartID and  TblMR.ID < @EndID and
			 	 
Insert into  #MediaResults_Delete
	(   DirtyTableID,
		MediaResultsID,
		MediaID,
		ClientGuid,
		_SearchRequestID,
		MediaType, 
		Category,
        MediaDate, 
        LocalDate,
        MediaDate_Hour,
        PositiveSentiment,
        NegativeSentiment
       )
 Select TblMR.ID,
        MediaResultsID,
		MediaID,
		ClientGuid,
		_SearchRequestID,
		MediaType, 
		Category,
        convert(date,MediaDate), 
        CONVERT(date,CASE WHEN dbo.fnIsDayLightSaving(MediaDate) = 1 THEN  DATEADD(HOUR,(SELECT gmt + dst From Client where ClientGuid = IQAgent_SearchRequest.ClientGuid),MediaDate) ELSE DATEADD(HOUR,(SELECT gmt From Client where ClientGuid = IQAgent_SearchRequest.ClientGuid),MediaDate) END),
        DATEADD (HOUR,DATEPART(HOUR,MediaDate), CONVERT(VARCHAR(10),MediaDate,101)),
        ISNULL(PositiveSentiment,0),
        ISNULL(NegativeSentiment,0)
         From dbo.IQAgent_MediaResults_DirtyTable TblMR 	WITH(NOLOCK)
        JOIN dbo.IQAgent_SearchRequest 	WITH(NOLOCK)
			 	 on TblMR._SearchRequestID	= IQAgent_SearchRequest.ID 
			 	 Where  TblMR.IsActive=0 -- TblMR.ID >= @StartID and  TblMR.ID < @EndID and
 /*
SET @QueryDetail ='Preparing MediaResults table'
SET @TimeDiff = DATEDIFF(ms, @Stopwatch, GETDATE())
INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) VALUES(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
SET @Stopwatch = GETDATE()
*/
 IF (select count(1) from #MediaResults) > 0
    Begin
	 
       Create index idx1_MediaResults on #MediaResults(MediaType,MediaID)
       Create index idx2_MediaResults on #MediaResults(DirtyTableID)
       Exec @status=dbo.usp_v4_IQAgent_MediaResults_Dirtytbl_process_build_DayHourSummary With Recompile
 
       IF @status=0 
          Begin
        
            Exec @status=dbo.usp_v4_IQAgent_MediaResults_Dirtytbl_process_update_DayHourSummary  With Recompile
            
            IF @status=0
			   Begin
			      set @InsertStatus = 'INSERT SUCCEED'
				  /*
				  SET @QueryDetail ='Adding Media.....'
	              SET @TimeDiff = DATEDIFF(ms, @Stopwatch, GETDATE())
	              INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) VALUES(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
	              SET @Stopwatch = GETDATE() */
			   End
            ELSE
              set @InsertStatus = 'INSERT FAIL'
            
          End
       ELSE
          set @InsertStatus = 'INSERT FAIL'
       
     End  
ELSE
    set @InsertStatus = 'INSERT IDLE'

 IF (select count(1) from #MediaResults_Delete) > 0
    Begin
   
       Create index idx1_MediaResults_Delete on #MediaResults(MediaType,MediaID)
        Create index idx2_MediaResults_Delete on #MediaResults(DirtyTableID)
       Exec @status=dbo.usp_v4_IQAgent_MediaResults_Dirtytbl_process_build_DayHourSummary_Delete With Recompile
 
       IF @status=0 
          Begin
        
            Exec @status=dbo.usp_v4_IQAgent_MediaResults_Dirtytbl_process_update_DayHourSummary_Delete  With Recompile
            
            IF @status=0
			   Begin
                 set @DeleteStatus = 'DELETE SUCCEED'
				 /*
			     SET @QueryDetail ='Deleting Media....'
	             SET @TimeDiff = DATEDIFF(ms, @Stopwatch, GETDATE())
	             INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) VALUES(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
				 */
	           End 
            ELSE
              set @DeleteStatus = 'DELETE FAIL'
            
          End
       ELSE
          set @DeleteStatus = 'DELETE FAIL'
       
     End  
ELSE
    set @DeleteStatus = 'DELETE IDLE'             
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
				@CreatedBy='usp_v4_IQAgent_MediaResults_Dirtytbl_Process',
				@ModifiedBy='usp_v4_IQAgent_MediaResults_Dirtytbl_Process',
				@CreatedDate=GETDATE(),
				@ModifiedDate=GETDATE(),
				@IsActive=1
				
		
		EXEC usp_IQMediaGroupExceptions_Insert @ExceptionStackTrace,@ExceptionMessage,@CreatedBy,@CreatedDate,NULL,@IQMediaGroupExceptionKey OUTPUT
		Return 1
  END CATCH      
  

    
END




















GO


