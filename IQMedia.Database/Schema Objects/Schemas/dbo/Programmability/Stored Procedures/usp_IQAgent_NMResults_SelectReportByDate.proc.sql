-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_IQAgent_NMResults_SelectReportByDate]
	
	@ClientGuid uniqueidentifier,
	@IQAgentSearchRequestID bigint,
	@FromDate DateTime,
	@ToDate	  DateTime,
	@NoOfRecordsToDisplay int,
	@IsCompeteData bit,
	@Query_Name varchar(100) OUTPUT
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @Query nvarchar(max)
	Set @Query = ''
	
	If(@IsCompeteData = 1)
	BEGIN
	SET @Query = 'DECLARE @OtherOnlineAdRate decimal(18,2)
									DECLARE @CompeteMultiplier decimal(18,2)
									DECLARE @OnlineNewsAdRate decimal(18,2)
									DECLARE @URLPercentRead decimal(18,2)

									SET @OtherOnlineAdRate = 1 
									SET @CompeteMultiplier = 1 
									SET @OnlineNewsAdRate= 1
									Set @URLPercentRead = 1 

									;WITH TEMP_ClientSettings AS
									(
										SELECT
												ROW_NUMBER() OVER (PARTITION BY Field ORDER BY IQClient_CustomSettings._ClientGuid desc) as RowNum,
												Field,
												Value
										FROM
												IQClient_CustomSettings
										Where
												(IQClient_CustomSettings._ClientGuid='''+CONVERT(varchar(40),@ClientGUID)+''' OR IQClient_CustomSettings._ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER))
												AND IQClient_CustomSettings.Field IN (''OtherOnlineAdRate'',''CompeteMultiplier'',''OnlineNewsAdRate'',''URLPercentRead'')
									)
								 
									SELECT 
										@OtherOnlineAdRate = [OtherOnlineAdRate],
										@CompeteMultiplier = [CompeteMultiplier],
										@OnlineNewsAdRate= [OnlineNewsAdRate],
										@URLPercentRead = [URLPercentRead]
										 
									FROM
										(
										  SELECT
												
													[Field],
													[Value]
										  FROM
													TEMP_ClientSettings
										  WHERE	
													RowNum =1
										) AS SourceTable
										PIVOT
										(
											Max(Value)
											FOR Field IN ([OtherOnlineAdRate],[CompeteMultiplier],[OnlineNewsAdRate],[URLPercentRead])
										) AS PivotTable'
	END
	
    SET @Query = @Query + ' SELECT ' + CASE WHEN ISNULL(@NoOfRecordsToDisplay,0) != 0 THEN 'top '+ CONVERT(Varchar(10),@NoOfRecordsToDisplay) ELSE '' END  + '
			IQAgent_NMResults.ID,
			IQAgent_NMResults.ArticleID,
			IQAgent_NMResults.URL,
			IQAgent_NMResults.Publication,
			IQAgent_NMResults.Title,
			IQAgent_NMResults.harvest_Time,
			IQAgent_NMResults.Category,
			IQAgent_NMResults.Genre,
			Client.ClientGUID'
			
			IF(@IsCompeteData = 1)
			BEGIN
			
			SET @Query = @Query +	',CASE WHEN (c_uniq_visitor IS NULL OR @CompeteMultiplier > 1)THEN
										CAST(0 AS BIT)
									ELSE
										CAST(1 AS BIT)
									END as IsCompeteAll,
									
									CASE 
										WHEN 
											(
											(Replace(Replace(IQAgent_NMResults.Publication,''http://'',''''),''www.'','''') = ''facebook.com'' OR Replace(Replace(IQAgent_NMResults.Publication,''http://'',''''),''www.'','''') = ''twitter.com'' OR Replace(Replace(IQAgent_NMResults.Publication,''http://'',''''),''www.'','''') = ''friendfeed.com'') 											
											)
												THEN -1			 
										WHEN c_uniq_visitor IS NULL THEN
										((((SELECT convert(float,c_uniq_visitor) FROM IQ_Compete_Averages WHERE CompeteURL = Replace(Replace(IQAgent_NMResults.Publication,''http://'',''''),''www.'',''''))/30)*@CompeteMultiplier * (@URLPercentRead/100))/1000)* @OnlineNewsAdRate
									ELSE
										(((convert(float,c_uniq_visitor)/30)*@CompeteMultiplier * (@URLPercentRead/100))/1000)* @OnlineNewsAdRate
									END as IQ_AdShare_Value,
									
									
									CASE 
										WHEN 
											(
											(Replace(Replace(IQAgent_NMResults.Publication,''http://'',''''),''www.'','''') = ''facebook.com'' OR Replace(Replace(IQAgent_NMResults.Publication,''http://'',''''),''www.'','''') = ''twitter.com'' OR Replace(Replace(IQAgent_NMResults.Publication,''http://'',''''),''www.'','''') = ''friendfeed.com'') 											
											)
												THEN -1
										WHEN c_uniq_visitor IS NULL THEN
											(SELECT c_uniq_visitor FROM IQ_Compete_Averages WHERE CompeteURL = Replace(Replace(IQAgent_NMResults.Publication,''http://'',''''),''www.'',''''))
										ELSE
											c_uniq_visitor
										END AS c_uniq_visitor,
									
									Case 
										WHEN
											(IQ_CompeteAll.WebSiteUrl Is Null 
												AND 
												(
													(Select WebSiteUrl from IQ_Compete_Averages Where CompeteURL = Replace(Replace(IQAgent_NMResults.Publication,''http://'',''''),''www.'','''')) is null
													)
											)
											Then
											CAST(0 AS BIT)
										ELSE
											CAST(1 AS BIT)
									END as IsUrlFound'
			END
	
		SET @Query = @Query + ' FROM
								IQAgent_NMResults
									INNER JOIN IQAgent_SearchRequest
										ON IQAgent_NMResults.IQAgentSearchRequestID =  IQAgent_SearchRequest.ID
										INNER JOIN Client	
								
											ON IQAgent_SearchRequest.ClientGuid = Client.ClientGUID'
			IF(@IsCompeteData = 1)
			BEGIN	
				SET @Query = @Query + ' LEFT OUTER JOIN IQ_CompeteAll						
						ON Replace(Replace(IQAgent_NMResults.Publication,''http://'',''''),''www.'','''') = IQ_CompeteAll.CompeteURL'
			END
	SET @Query = @Query + ' WHERE
			 
			IQAgent_NMResults.harvest_time Between ''' + CONVERT(Varchar(20),@FromDate) + ''' AND '''  + CONVERT(Varchar(20),@ToDate)  + '''
			AND IQAgent_NMResults.IQAgentSearchRequestID = ' +  CONVERT(Varchar(10),@IQAgentSearchRequestID) + '
			AND Client.ClientGUID  = ''' + CONVERT(Varchar(40),@ClientGuid) + '''
			AND IQAgent_NMResults.IsActive = 1
			AND IQAgent_SearchRequest.IsActive = 1
	ORDER BY 
			IQAgent_NMResults.harvest_Time desc'				

	print @Query

    exec sp_executesql @Query 
 
	SELECT @Query_Name = IQAgent_SearchRequest.Query_Name From IQAgent_SearchRequest Where IQAgent_SearchRequest.ID = @IQAgentSearchRequestID;
    
END
