CREATE PROCEDURE [dbo].[usp_v4_IQAgent_DaySummary_SelectDmaSummaryByDay]
 @ClientGUID  uniqueidentifier,  
 @FromDate   date,  
 @ToDate    date,  
 @Medium  varchar(20),  
 @SearchRequestIDXml xml,  
 @DmaXml xml  
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
    DMA_Name,  
    count(IQAGENT_TVResults.ID) as NoOfDocs,  
    ISNULL(sum(CONVERT(BIGINT,Number_Hits)),0) as NoOfHits,  
    ISNULL(sum(CASE WHEN Nielsen_Audience > 0 THEN CONVERT(BIGINT,Nielsen_Audience) ELSE 0 END),0) as Audience,  
    CONVERT(date,IQAGENT_TVResults.GMTDatetime) as DayDate,  
    IQAgent_SearchRequest.ClientGUID  
   FROM   
    IQAGENT_TVResults WITH (NOLOCK)  
     INNER JOIN IQ_Station WITH (NOLOCK)  
      ON IQAGENT_TVResults.RL_STation = IQ_Station.IQ_STation_ID  
	  AND IQ_Station.Country_num = 1 -- Limit results to US
     INNER JOIN IQAgent_SearchRequest WITH (NOLOCK)  
      ON IQAGENT_TVResults.SearchRequestID = IQAgent_SearchRequest.ID  
      AND IQAgent_SearchRequest.ClientGUID = @ClientGUID  
      AND IQAgent_SearchRequest.IsActive > 0
      AND IQAGENT_TVResults.IsActive = 1  
     INNER JOIN @SearchRequestIDXml.nodes('list/item') as Search(req)   
      ON IQAgent_SearchRequest.ID = Search.req.value('@id','bigint')  
     INNER JOIN @DmaXml.nodes('list/item') as a(dma)   
      ON IQ_Station.Dma_Name = a.dma.value('@dma','varchar(500)')  
   WHERE  
    ((@FDate is null or @TDate is null) OR IQAGENT_TVResults.GMTDatetime  BETWEEN @FDate AND @TDate)  
   GROUP BY   
    IQ_Station.DMA_Name,CONVERT(date,IQAGENT_TVResults.GMTDatetime),IQAgent_SearchRequest.ClientGUID  
  end  
  else IF(@Medium = 'NM')  
  begin  
    SELECT   
     CASE WHEN (IQ_DMA_Name IS NULL OR IQ_DMA_Name = 'Unknown') THEN 'Global' ELSE IQ_DMA_Name END as DMA_Name,  
      ISNULL(sum(CONVERT(BIGINT,Number_Hits)),0) as NoOfHits,  
      count(IQAgent_NMResults.ID) as NoOfDocs,  
      ISNULL(sum(CASE WHEN Compete_Audience > 0 THEN CONVERT(BIGINT,Compete_Audience) ELSE 0 END),0) as Audience,  
      CONVERT(date,IQAgent_NMResults.harvest_time) as DayDate,  
      IQAgent_SearchRequest.ClientGUID  
     FROM   
      IQAgent_NMResults WITH (NOLOCK)  
       LEFT OUTER JOIN IQDMA WITH (NOLOCK)  
        ON IQAgent_NMResults._IQDmaID = IQDMA.ID  
       INNER JOIN IQAgent_SearchRequest WITH (NOLOCK)  
        ON IQAgent_NMResults.IQAgentSearchRequestID = IQAgent_SearchRequest.ID  
        AND IQAgent_SearchRequest.ClientGUID = @ClientGUID  
        AND IQAgent_SearchRequest.IsActive > 0
        AND IQAgent_NMResults.IsActive = 1  
       INNER JOIN @SearchRequestIDXml.nodes('list/item') as Search(req)   
        ON IQAgent_SearchRequest.ID = Search.req.value('@id','bigint')  
       INNER JOIN @DmaXml.nodes('list/item') as a(dma)   
        ON IQDMA.IQ_DMA_Name = a.dma.value('@dma','varchar(500)')  
     WHERE  
      ((@FDate is null or @TDate is null) OR IQAgent_NMResults.harvest_time  BETWEEN @FDate AND @TDate)  
        
     GROUP BY   
      IQ_Dma_Num,IQ_DMA_Name,CONVERT(date,IQAgent_NMResults.harvest_time),IQAgent_SearchRequest.ClientGUID  
  end  
 END  
 ELSE  
 BEGIN  
  if(@Medium = 'TV')  
  begin  
   SELECT   
    DMA_Name,  
    count(IQAGENT_TVResults.ID) as NoOfDocs,  
    ISNULL(sum(CONVERT(BIGINT,Number_Hits)),0) as NoOfHits,  
    ISNULL(sum(CASE WHEN Nielsen_Audience > 0 THEN CONVERT(BIGINT,Nielsen_Audience) ELSE 0 END),0) as Audience,  
    CONVERT(date,IQAGENT_TVResults.GMTDatetime) as DayDate,  
    IQAgent_SearchRequest.ClientGUID  
   FROM   
    IQAGENT_TVResults WITH (NOLOCK)  
     INNER JOIN IQ_Station WITH (NOLOCK)  
      ON IQAGENT_TVResults.RL_STation = IQ_Station.IQ_STation_ID  
	  AND IQ_Station.Country_num = 1 -- Limit results to US
     INNER JOIN IQAgent_SearchRequest WITH (NOLOCK)  
      ON IQAGENT_TVResults.SearchRequestID = IQAgent_SearchRequest.ID  
      AND IQAgent_SearchRequest.ClientGUID = @ClientGUID  
      AND IQAgent_SearchRequest.IsActive > 0
      AND IQAGENT_TVResults.IsActive = 1  
     INNER JOIN @DmaXml.nodes('list/item') as a(dma)   
      ON IQ_Station.Dma_Name = a.dma.value('@dma','varchar(500)')  
   WHERE  
    ((@FDate is null or @TDate is null) OR IQAGENT_TVResults.GMTDatetime  BETWEEN @FDate AND @TDate)  
   GROUP BY   
    IQ_Station.DMA_Name,CONVERT(date,IQAGENT_TVResults.GMTDatetime),IQAgent_SearchRequest.ClientGUID  
  end  
  else IF(@Medium = 'NM')  
  begin  
   SELECT   
    CASE WHEN (IQ_DMA_Name IS NULL OR IQ_DMA_Name = 'Unknown') THEN 'Global' ELSE IQ_DMA_Name END as DMA_Name,  
    ISNULL(sum(CONVERT(BIGINT,Number_Hits)),0) as NoOfHits,  
    count(IQAgent_NMResults.ID) as NoOfDocs,  
    ISNULL(sum(CASE WHEN Compete_Audience > 0 THEN CONVERT(BIGINT,Compete_Audience) ELSE 0 END),0) as Audience,  
    CONVERT(date,IQAgent_NMResults.harvest_time) as DayDate,  
    IQAgent_SearchRequest.ClientGUID  
   FROM   
    IQAgent_NMResults WITH (NOLOCK)  
     LEFT OUTER JOIN IQDMA WITH (NOLOCK)  
      ON IQAgent_NMResults._IQDmaID = IQDMA.ID  
     INNER JOIN IQAgent_SearchRequest WITH (NOLOCK)  
      ON IQAgent_NMResults.IQAgentSearchRequestID = IQAgent_SearchRequest.ID  
      AND IQAgent_SearchRequest.ClientGUID = @ClientGUID  
      AND IQAgent_SearchRequest.IsActive > 0
      AND IQAgent_NMResults.IsActive = 1  
     INNER JOIN @DmaXml.nodes('list/item') as a(dma)   
      ON IQDMA.IQ_DMA_Name = a.dma.value('@dma','varchar(500)')  
   WHERE  
    ((@FDate is null or @TDate is null) OR IQAgent_NMResults.harvest_time  BETWEEN @FDate AND @TDate)  
        
   GROUP BY   
    IQ_Dma_Num,IQ_DMA_Name,CONVERT(date,IQAgent_NMResults.harvest_time),IQAgent_SearchRequest.ClientGUID  
  end  
 END  
END