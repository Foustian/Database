CREATE PROCEDURE [dbo].[usp_v4_IQAgent_HourSummary_SelectProvinceSummaryByHour]  
 @ClientGUID  uniqueidentifier,  
 @FromDate   datetime,  
 @ToDate    datetime,  
 @Medium  varchar(20),  
 @SearchRequestIDXml xml,  
 @ProvinceXml xml   
AS  
BEGIN  
 Declare @FDate datetime=NULL,  
   @TDate datetime=NULL  
  
 IF(@FromDate is not null AND @ToDate is not null)  
 BEGIN  
  Declare @IsDST bit,  
    @gmt decimal(18,2),  
    @dst decimal(18,2)  
     
  Select  
    @gmt=Client.gmt,  
    @dst=Client.dst  
  From  
    Client  
  Where  
    ClientGUID=@ClientGUID  
   
  SET @FDate=@FromDate  
  SET @TDate=DATEADD(MINUTE,1439,Convert(datetime, @ToDate))  
     
  Select @IsDST=dbo.fnIsDayLightSaving(@FDate);  
   
  If(@IsDST=1)  
  BEGIN  
    Set @FDate=DATEADD(HOUR,-(@gmt),CONVERT(datetime,@FDate))  
    Set @FDate=DATEADD(HOUR,-@dst,CONVERT(datetime, @FDate))  
  END  
  ELSE  
  BEGIN  
    Set @FDate=DATEADD(HOUR,-(@gmt),CONVERT(datetime, @FDate))  
  END  
   
  Select @IsDST=dbo.fnIsDayLightSaving(@TDate);  
   
  If(@IsDST=1)  
  BEGIN  
    Set @TDate=DATEADD(HOUR,-(@gmt),@TDate)  
    Set @TDate=DATEADD(HOUR,-@dst,@TDate)  
  END  
  ELSE  
  BEGIN  
    Set @TDate=DATEADD(HOUR,-(@gmt),@TDate)  
  END  
 END  
  
 IF(@SearchRequestIDXml IS NOT NULL)  
 BEGIN  
  if(@Medium = 'TV')  
  begin  
   SELECT   
    IQ_DMAProvinceLookup.Province,  
    count(IQAGENT_TVResults.ID) as NoOfDocs,  
    ISNULL(sum(CONVERT(BIGINT,Number_Hits)),0) as NoOfHits,  
    ISNULL(sum(CASE WHEN Nielsen_Audience > 0 THEN CONVERT(BIGINT,Nielsen_Audience) ELSE 0 END),0) as Audience,  
    DateAdd (hour,DATEPART(hour,IQAGENT_TVResults.GMTDatetime), convert (varchar(10),IQAGENT_TVResults.GMTDatetime,101) ) as HourDateTime,        
    IQAgent_SearchRequest.ClientGUID  
   FROM   
    IQAGENT_TVResults WITH (NOLOCK)  
     INNER JOIN IQ_Station WITH (NOLOCK)  
      ON IQAGENT_TVResults.RL_STation = IQ_Station.IQ_STation_ID  
	  AND IQ_Station.Country_num = 2
	 INNER JOIN IQ_DMAProvinceLookup 
	  ON IQ_DMAProvinceLookup.DMA_Num = IQ_Station.Dma_Num
     INNER JOIN IQAgent_SearchRequest WITH (NOLOCK)  
      ON IQAGENT_TVResults.SearchRequestID = IQAgent_SearchRequest.ID  
      AND IQAgent_SearchRequest.ClientGUID = @ClientGUID  
      AND IQAgent_SearchRequest.IsActive > 0  
      AND IQAGENT_TVResults.IsActive = 1  
     INNER JOIN @SearchRequestIDXml.nodes('list/item') as Search(req)   
      ON IQAgent_SearchRequest.ID = Search.req.value('@id','bigint')  
     INNER JOIN @ProvinceXml.nodes('list/item') as a(province)   
       ON IQ_DMAProvinceLookup.Province = a.province.value('@province','varchar(500)')  
   WHERE  
    ((@FDate is null or @TDate is null) OR IQAGENT_TVResults.GMTDatetime  BETWEEN @FDate AND @TDate)  
   GROUP BY   
     IQ_DMAProvinceLookup.Province,DateAdd (hour,DATEPART(hour,IQAGENT_TVResults.GMTDatetime), convert (varchar(10),IQAGENT_TVResults.GMTDatetime,101) ),IQAgent_SearchRequest.ClientGUID  
  end  
  else if(@Medium = 'NM')  
  begin  
    SELECT   
      State as Province,  
      ISNULL(sum(CONVERT(BIGINT,Number_Hits)),0) as NoOfHits,  
      count(IQAgent_NMResults.ID) as NoOfDocs,  
      ISNULL(sum(CASE WHEN Compete_Audience > 0 THEN CONVERT(BIGINT,Compete_Audience) ELSE 0 END),0) as Audience,  
      DateAdd (hour,DATEPART(hour,IQAgent_NMResults.harvest_time), convert (varchar(10),IQAgent_NMResults.harvest_time,101) ) as HourDateTime,        
      IQAgent_SearchRequest.ClientGUID  
     FROM   
      IQAgent_NMResults WITH (NOLOCK)  
       INNER JOIN IQAgent_SearchRequest WITH (NOLOCK)  
        ON IQAgent_NMResults.IQAgentSearchRequestID = IQAgent_SearchRequest.ID  
        AND IQAgent_SearchRequest.ClientGUID = @ClientGUID  
        AND IQAgent_SearchRequest.IsActive > 0
        AND IQAgent_NMResults.IsActive = 1  
       INNER JOIN @SearchRequestIDXml.nodes('list/item') as Search(req)   
        ON IQAgent_SearchRequest.ID = Search.req.value('@id','bigint')  
       INNER JOIN @ProvinceXml.nodes('list/item') as a(province)   
        ON IQAgent_NMResults.State = a.province.value('@province','varchar(500)')  
     WHERE  
      ((@FDate is null or @TDate is null) OR IQAgent_NMResults.harvest_time  BETWEEN @FDate AND @TDate)  
        
     GROUP BY   
      IQAgent_NMResults.State,DateAdd (hour,DATEPART(hour,IQAgent_NMResults.harvest_time), convert (varchar(10),IQAgent_NMResults.harvest_time,101) ),IQAgent_SearchRequest.ClientGUID  
  end  
END  
 ELSE  
 BEGIN  
  if(@Medium = 'TV')  
  begin  
   SELECT   
    IQ_DMAProvinceLookup.Province,  
    count(IQAGENT_TVResults.ID) as NoOfDocs,  
    ISNULL(sum(CONVERT(BIGINT,Number_Hits)),0) as NoOfHits,  
    ISNULL(sum(CASE WHEN Nielsen_Audience > 0 THEN CONVERT(BIGINT,Nielsen_Audience) ELSE 0 END),0) as Audience,  
    DateAdd (hour,DATEPART(hour,IQAGENT_TVResults.GMTDatetime), convert (varchar(10),IQAGENT_TVResults.GMTDatetime,101) ) as HourDateTime,        
    IQAgent_SearchRequest.ClientGUID  
   FROM   
    IQAGENT_TVResults WITH (NOLOCK)  
     INNER JOIN IQ_Station WITH (NOLOCK)  
      ON IQAGENT_TVResults.RL_STation = IQ_Station.IQ_STation_ID  
	  AND IQ_Station.Country_num = 2
	 INNER JOIN IQ_DMAProvinceLookup 
	  ON IQ_DMAProvinceLookup.DMA_Num = IQ_Station.Dma_Num
     INNER JOIN IQAgent_SearchRequest WITH (NOLOCK)  
      ON IQAGENT_TVResults.SearchRequestID = IQAgent_SearchRequest.ID  
      AND IQAgent_SearchRequest.ClientGUID = @ClientGUID  
      AND IQAgent_SearchRequest.IsActive > 0  
      AND IQAGENT_TVResults.IsActive = 1   
     INNER JOIN @ProvinceXml.nodes('list/item') as a(province)   
       ON IQ_DMAProvinceLookup.Province = a.province.value('@province','varchar(500)')  
   WHERE  
    ((@FDate is null or @TDate is null) OR IQAGENT_TVResults.GMTDatetime  BETWEEN @FDate AND @TDate)  
   GROUP BY   
     IQ_DMAProvinceLookup.Province,DateAdd (hour,DATEPART(hour,IQAGENT_TVResults.GMTDatetime), convert (varchar(10),IQAGENT_TVResults.GMTDatetime,101) ),IQAgent_SearchRequest.ClientGUID  
  end   
  else if(@Medium = 'NM')  
  begin  
   SELECT   
      State as Province,  
      ISNULL(sum(CONVERT(BIGINT,Number_Hits)),0) as NoOfHits,  
      count(IQAgent_NMResults.ID) as NoOfDocs,  
      ISNULL(sum(CASE WHEN Compete_Audience > 0 THEN CONVERT(BIGINT,Compete_Audience) ELSE 0 END),0) as Audience,  
      DateAdd (hour,DATEPART(hour,IQAgent_NMResults.harvest_time), convert (varchar(10),IQAgent_NMResults.harvest_time,101) ) as HourDateTime,        
      IQAgent_SearchRequest.ClientGUID  
     FROM   
      IQAgent_NMResults WITH (NOLOCK)  
       INNER JOIN IQAgent_SearchRequest WITH (NOLOCK)  
        ON IQAgent_NMResults.IQAgentSearchRequestID = IQAgent_SearchRequest.ID  
        AND IQAgent_SearchRequest.ClientGUID = @ClientGUID  
        AND IQAgent_SearchRequest.IsActive > 0
        AND IQAgent_NMResults.IsActive = 1  
       INNER JOIN @ProvinceXml.nodes('list/item') as a(province)   
        ON IQAgent_NMResults.State = a.province.value('@province','varchar(500)')  
     WHERE  
      ((@FDate is null or @TDate is null) OR IQAgent_NMResults.harvest_time  BETWEEN @FDate AND @TDate)  
        
     GROUP BY   
      IQAgent_NMResults.State,DateAdd (hour,DATEPART(hour,IQAgent_NMResults.harvest_time), convert (varchar(10),IQAgent_NMResults.harvest_time,101) ),IQAgent_SearchRequest.ClientGUID   
  end  
 END  
END