USE [IQMediaGroup]
GO

/****** Object:  StoredProcedure [dbo].[usp_pshell_IQAgentQHResult_TVInsertList]    Script Date: 3/16/2016 2:16:55 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[usp_pshell_IQAgentQHResult_TVInsertList]                             
(        
 @XmlData   XML        
)          
AS        
BEGIN         
 SET NOCOUNT OFF;    
 SET XACT_ABORT ON;  

 BEGIN TRY  
 /* 
  DECLARE @IQ_ADS_Results TABLE 
  (
    IQ_CC_KEY VARCHAR(128),
	StartOffset SMALLINT,
	EndOffset SMALLINT
  )
  */
  DECLARE @IQAgent_QHTVResults TABLE (
		[SearchRequestID] BIGINT,        
     	[_QueryVersion] INT,        
     	[Title120] VARCHAR(128),        
     	[iq_cc_key] VARCHAR(28),   
		[StartPoint] SMALLINT,     
     	[RL_VideoGUID] uniqueidentifier,        
     	[GMTDatetime] DATETIME,        
     	[Rl_Station] VARCHAR(150),        
     	[Rl_Market] VARCHAR(150),        
     	[RL_Date] DATE,        
     	[RL_Time] INT,        
     	[Number_Hits] INT,    
     	[AM18_20] INT,
		[AM21_24] INT,
		[AM25_34] INT,
		[AM35_49] INT,
		[AM50_54] INT,
		[AM55_64] INT,
		[AM65_Plus] INT,
		[AF18_20] INT,
		[AF21_24] INT,
		[AF25_34] INT,
		[AF35_49] INT,
		[AF50_54] INT,
		[AF55_64] INT,
		[AF65_Plus] INT,
		[Nielsen_Result] CHAR(1),
		[IQAdShareValue] float null,
		[_IQDmaID] INT,
		[RawMediaThumbUrl] VARCHAR(255),
		[IQProminence] DECIMAL(18,6),
		[IQProminenceMultiplier] DECIMAL(18,6), 
		[ProgramCategory] VARCHAR(13) ,
		[Sentiment] XML,        
		[CC_Highlight] XML,
		[Earned] INT,
		[Paid] INT )

	INSERT INTO @IQAgent_QHTVResults(
		[SearchRequestID],        
     	[_QueryVersion],        
     	[Title120],        
     	[iq_cc_key],
		[StartPoint],
		[RL_VideoGUID],        
     	[GMTDatetime],        
     	[Rl_Station],        
     	[Rl_Market],        
     	[RL_Date],        
     	[RL_Time],        
     	[Number_Hits],    
     	[AM18_20],
		[AM21_24],
		[AM25_34],
		[AM35_49],
		[AM50_54],
		[AM55_64],
		[AM65_Plus],
		[AF18_20],
		[AF21_24],
		[AF25_34],
		[AF35_49],
		[AF50_54],
		[AF55_64],
		[AF65_Plus],
		[Nielsen_Result],
		[IQAdShareValue],
		[_IQDmaID],
		[RawMediaThumbUrl],
		[IQProminence],
		[IQProminenceMultiplier], 
		[ProgramCategory] ,
		[Sentiment],        
		[CC_Highlight]
)
  SELECT         
     	tblXml.c.value('@SearchRequestID','bigint') AS [SearchRequestID],        
     	tblXml.c.value('@QueryVersion','int') AS [QueryVersion],        
     	tblXml.c.value('@Title120','nvarchar(128)') AS [Title120],        
     	tblXml.c.value('@iq_cc_key','varchar(28)') AS [iq_cc_key],    
		tblXml.c.value('@iqsp','SMALLINT') AS [StartPoint],    
		tblXml.c.value('@RL_VideoGUID','uniqueidentifier') AS [RL_VideoGUID],        
     	tblXml.c.value('@GMTDatetime','datetime') AS [GMTDatetime],        
     	tblXml.c.value('@Rl_Station','varchar(150)') AS [Rl_Station],        
     	tblXml.c.value('@Rl_Market','varchar(150)') AS [Rl_Market],        
     	tblXml.c.value('@RL_Date','date') AS [RL_Date],        
     	tblXml.c.value('@RL_Time','int') AS [RL_Time],        
     	tblXml.c.value('@Number_Hits','int') AS [Number_Hits],    
     	tblXml.c.value('@AM18_20','int') AS [AM18_20],
		tblXml.c.value('@AM21_24','int') AS [AM21_24],
		tblXml.c.value('@AM25_34','int') AS [AM25_34],
		tblXml.c.value('@AM35_49','int') AS [AM35_49],
		tblXml.c.value('@AM50_54','int') AS [AM50_54],
		tblXml.c.value('@AM55_64','int') AS [AM55_64],
		tblXml.c.value('@AM65','int')    AS [AM65],
		tblXml.c.value('@AF18_20','int') AS [AF18_20],
		tblXml.c.value('@AF21_24','int') AS [AF21_24],
		tblXml.c.value('@AF25_34','int') AS [AF25_34],
		tblXml.c.value('@AF35_49','int') AS [AF35_49],
		tblXml.c.value('@AF50_54','int') AS [AF50_54],
		tblXml.c.value('@AF55_64','int') AS [AF55_64],
		tblXml.c.value('@AF65','int')    AS [AF65],
		tblXml.c.value('@Nielsen_Result','char(1)')    AS [Nielsen_Result],
		tblXml.c.value('@IQAdShareValue','float') AS [IQAdShareValue],  
		tblXml.c.value('@_IQDmaID','int') AS [_IQDmaID],
		CASE WHEN tblXml.c.value('@RawMediaThumbUrl','varchar(255)') = '' THEN NULL ELSE tblXml.c.value('@RawMediaThumbUrl','varchar(255)') END AS	[RawMediaThumbUrl],
		tblXml.c.value('@IQProminence','DECIMAL(18,6)') AS [IQProminence],
		tblXml.c.value('@IQProminenceMultiplier','DECIMAL(18,6)') AS [IQProminenceMultiplier], 
		CASE WHEN tblXml.c.value('@ProgramCategory','varchar(13)') = '' THEN NULL ELSE tblXml.c.value('@ProgramCategory','varchar(13)') END AS [ProgramCategory] ,
		tblXml.c.query('Sentiment') AS [Sentiment],        
		tblXml.c.query('HighlightedCCOutput') AS [CC_Highlight]
	FROM          
		@XmlData.nodes('/IQAgentResultsList/IQAgentResult') AS tblXml(c)  
	/*
	INSERT INTO @IQ_ADS_Results(
	    IQ_CC_KEY,
		StartOffset,
		EndOffset)
	SELECT DISTINCT tv.IQ_CC_KEY,
	       CONVERT(SMALLINT, CEILING(LEFT(Tbla.HitsList.value('./Begin[1]', 'varchar(10)'),LEN(Tbla.HitsList.value('./Begin[1]',	'varchar(10)'))-1)) ),
		   CONVERT(SMALLINT, CEILING(LEFT(Tbla.HitsList.value('./End[1]', 'varchar(10)'),LEN(Tbla.HitsList.value('./End[1]', 'varchar(10)'))-1)))
	FROM @IQAgent_QHTVResults tv 
		 JOIN IQ_ADS_Results ads  ON tv.iq_cc_key = ads.iq_cc_key AND ads.Hit_Count > 1
		   CROSS APPLY Hits.nodes('/ADSOffsets/Hits') AS Tbla(HitsList) 
	 
	UPDATE @IQAgent_QHTVResults
		SET	  Paid = (SELECT ISNULL(COUNT(DISTINCT(Tblc.HitList.value('.', 'SMALLINT') )),0) FROM @IQAgent_QHTVResults itv
			            CROSS APPLY CC_Highlight.nodes('/HighlightedCCOutput/CC/ClosedCaption/Offset') AS Tblc(HitList)
			             JOIN  @IQ_ADS_Results ads  
						 ON ads.IQ_CC_KEY = itv.IQ_CC_KEY  
						 AND tv.IQ_CC_KEY=itv.iq_cc_key 
						 AND Tblc.HitList.value('.', 'SMALLINT') BETWEEN StartOffset AND EndOffset)
		FROM @IQAgent_QHTVResults tv
             
		*/
		      
   BEGIN TRANSACTION
      INSERT INTO IQAgent_QHTVResults(
		SearchRequestID,        
     	_QueryVersion,        
     	Title120,        
     	iq_cc_key,  
		StartPoint,      
     	RL_VideoGUID,        
     	GMTDatetime,        
     	Rl_Station,        
     	Rl_Market,        
     	RL_Date,        
     	RL_Time,        
     	Number_Hits,    
     	AM18_20,
		AM21_24,
		AM25_34,
		AM35_49,
		AM50_54,
		AM55_64,
		AM65_Plus,
		AF18_20,
		AF21_24,
		AF25_34,
		AF35_49,
		AF50_54,
		AF55_64,
		AF65_Plus,
		Nielsen_Result,
		IQAdShareValue,
		_IQDmaID,
		RawMediaThumbUrl,
		IQProminence,
		IQProminenceMultiplier, 
		ProgramCategory,
		Sentiment,        
		CC_Highlight
		-- Earned,
		-- Paid
		)
	 SELECT
	    tvTmp.SearchRequestID,        
     	tvTmp._QueryVersion,        
     	tvTmp.Title120,        
     	tvTmp.iq_cc_key,       
		tvTmp.StartPoint,  
     	tvTmp.RL_VideoGUID,        
     	tvTmp.GMTDatetime,        
     	tvTmp.Rl_Station,        
     	tvTmp.Rl_Market,        
     	tvTmp.RL_Date,        
     	tvTmp.RL_Time,        
     	tvTmp.Number_Hits,    
     	tvTmp.AM18_20,
		tvTmp.AM21_24,
		tvTmp.AM25_34,
		tvTmp.AM35_49,
		tvTmp.AM50_54,
		tvTmp.AM55_64,
		tvTmp.AM65_Plus,
		tvTmp.AF18_20,
		tvTmp.AF21_24,
		tvTmp.AF25_34,
		tvTmp.AF35_49,
		tvTmp.AF50_54,
		tvTmp.AF55_64,
		tvTmp.AF65_Plus,
		tvTmp.Nielsen_Result,
		tvTmp.IQAdShareValue,
		tvTmp._IQDmaID,
		tvTmp.RawMediaThumbUrl,
		tvTmp.IQProminence,
		tvTmp.IQProminenceMultiplier, 
		tvTmp.ProgramCategory,
		tvTmp.Sentiment,        
		tvTmp.CC_Highlight
	--	(tvTmp.Number_Hits - tvTmp.Paid),
	--	tvTmp.Paid 
	    FROM @IQAgent_QHTVResults tvTmp
		LEFT OUTER JOIN IQAgent_QHTVResults WITH(NOLOCK)        
			ON IQAgent_QHTVResults.SearchRequestID = tvTmp.SearchRequestID 
				AND IQAgent_QHTVResults.RL_VideoGUID = tvTmp.RL_VideoGUID 
				AND IQAgent_QHTVResults.IsActive = 1
		WHERE   IQAgent_QHTVResults.SearchRequestID IS NULL
	
   COMMIT TRANSACTION
    
 END TRY        
 BEGIN CATCH          
   
  IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION
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
				@CreatedBy='usp_pshell_IQAgentQHResult_TVInsertList',
				@ModifiedBy='usp_pshell_IQAgentQHResult_TVInsertList',
				@CreatedDate=GETDATE(),
				@ModifiedDate=GETDATE(),
				@IsActive=1
				
		
		EXEC usp_IQMediaGroupExceptions_Insert @ExceptionStackTrace,@ExceptionMessage,@CreatedBy,@CreatedDate,NULL,@IQMediaGroupExceptionKey OUTPUT

	
		Return 1

 END CATCH        
END     






GO


