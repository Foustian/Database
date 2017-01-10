-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_IQAgentResults_SelectReportByDate]
	@ClientGuid uniqueidentifier,
	@IQAgentSearchRequestID bigint,
	@FromDate DateTime,
	@ToDate	  DateTime,
	@NoOfRecordsToDisplay int,
	@IsNielSenData bit,
	@Query_Name varchar(100) output,
	@SearchTerm varchar(max) output
AS
BEGIN

	DECLARE @MultiPlier float
	
	select @MultiPlier = CONVERT(float,ISNULL(Value,1)) from IQClient_CustomSettings where Field = 'Multiplier' and _ClientGuid = @ClientGUID
	IF(ISNULL(@MultiPlier,'') = '')
	BEGIN
		SET @MultiPlier = 1;
	END
	
	DECLARE @Query nvarchar(max)

	SET @Query = 'Select '+ CASE WHEN ISNULL(@NoOfRecordsToDisplay,0) != 0 THEN 'top '+ CONVERT(Varchar(10),@NoOfRecordsToDisplay)  ELSE '' END  
	IF(@IsNielSenData = 1)
	BEGIN
	 SET @Query  = @Query  + 'CASE
					WHEN  SQAD_SHAREVALUE = 0 OR SQAD_SHAREVALUE IS NULL THEN convert(bit,0) else convert(bit,1) end as IsActualNielsen,
					CASE WHEN  SQAD_SHAREVALUE = 0 OR SQAD_SHAREVALUE IS NULL THEN
						
						Convert(varchar,CONVERT(DECIMAL,Avg_Ratings_Pt * 100 * '+convert(varchar, @MultiPlier)+' * (SELECT CPPVALUE FROM IQ_SQAD WHERE IQ_SQAD.SQADMARKETID = IQ_Station.SQADMARKETID AND IQ_SQAD.DAYPARTID = IQ_Nielsen_Averages.DAYPARTID))) 
											ELSE
											
						Convert(varchar,CONVERT(DECIMAL, SQAD_SHAREVALUE * '+CONVERT(varchar, @MultiPlier)+' )) 
					END
					as SQAD_SHAREVALUE,
				CASE
					WHEN  AUDIENCE = 0 OR AUDIENCE IS NULL THEN
						Convert(varchar,CAST((Avg_Ratings_Pt) * (IQ_Station.UNIVERSE) AS DECIMAL))
					ELSE
						AUDIENCE
					END
				  as AUDIENCE ,'
	END
	 
		SET @Query  = @Query + ' IQAgent_TVResults.ID,
			Title120,
			RL_VideoGUID,
			Number_Hits,
			RL_Date,
			RL_Time,
			Rl_Market,
			Rl_Station,			
			IQAgentResultUrl,
			Dma_Num
			
				FROM
						IQAgent_TVResults
							INNER JOIN IQAgent_SearchRequest
								ON IQAgent_TVResults.SearchRequestID =  IQAgent_SearchRequest.ID
									AND IQAgent_TVResults.SearchRequestID =  ' + CONVERT(Varchar(10),@IQAgentSearchRequestID) + '
									AND IQAgent_TVResults.IsActive = 1
									AND IQAgent_SearchRequest.IsActive = 1
								INNER JOIN Client	
									ON IQAgent_SearchRequest.ClientGUID = Client.ClientGUID							
										AND Client.ClientGUID = ''' + CONVERT(Varchar(40),@ClientGuid) + '''		
							INNER JOIN IQ_Station 
								on RL_Station = IQ_Station.IQ_Station_ID'

				IF(@IsNielSenData = 1)
					BEGIN
							Set @Query = @Query  + ' LEFT OUTER JOIN [IQ_NIELSEN_SQAD]  
													ON	IQAgent_TVResults.IQ_CC_Key =  [IQ_NIELSEN_SQAD].IQ_CC_KEY 
														AND [IQ_NIELSEN_SQAD].IQ_Start_Point = 1
													LEFT OUTER JOIN IQ_Nielsen_Averages 
													ON	IQ_Nielsen_Averages.IQ_Start_Point = 1
														AND Affil_IQ_CC_Key =  CASE WHEN Dma_Num =''000'' THEN IQ_Station.IQ_Station_ID ELSE IQ_Station.Station_Affil + ''_'' + TimeZone END  + ''_'' + SUBSTRING(IQAgent_TVResults.IQ_CC_Key,CHARINDEX(''_'',IQAgent_TVResults.IQ_CC_Key) +1,13)'
						 	
					END
					
			Set @Query=@Query+' WHERE
						 
						CONVERT(datetime,CONVERT(varchar(Max),IQAgent_TVResults.Rl_Date,101) + '' ''+ REPLACE(convert(varchar(Max),convert(decimal(4,2),(convert(decimal(6,2),IQAgent_TVResults.RL_Time)/convert(decimal(5,2),100)))),''.'','':'')+'':00'') Between ''' + CONVERT(Varchar(20),@FromDate) + ''' AND ''' + CONVERT(Varchar(20),@ToDate) + '''												
				ORDER BY 
						CONVERT(datetime,CONVERT(varchar(Max),IQAgent_TVResults.Rl_Date,101) + '' ''+ 
								REPLACE(convert(varchar(Max),convert(decimal(4,2),(convert(decimal(6,2),IQAgent_TVResults.RL_Time)/convert(decimal(5,2),100)))),''.'','':'')+'':00'') desc '
	print @Query
	
	
	

	exec sp_executesql @Query 

	SELECT 
		@Query_Name = IQAgent_SearchRequest.Query_Name,
		@SearchTerm = CONVERT(Varchar(max),IQAgent_SearchRequest.SearchTerm.query('/SearchRequest/SearchTerm/text()'))
	From 
		IQAgent_SearchRequest
	Where 
		IQAgent_SearchRequest.ID = @IQAgentSearchRequestID;
	
END
