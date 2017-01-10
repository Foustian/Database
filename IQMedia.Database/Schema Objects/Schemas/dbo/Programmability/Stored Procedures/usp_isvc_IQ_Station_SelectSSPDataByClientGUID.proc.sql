CREATE PROCEDURE [dbo].[usp_isvc_IQ_Station_SelectSSPDataByClientGUID]  
(  
 @ClientGUID  UNIQUEIDENTIFIER  
)   
AS  
BEGIN   
 SET NOCOUNT ON;  
   
 DECLARE @SearchSettings XML  
   
 ;WITH TEMP_ClientSettings AS  
 (  
  SELECT  
    ROW_NUMBER() OVER (PARTITION BY Field ORDER BY IQClient_CustomSettings._ClientGuid DESC) AS RowNum,  
    Field,  
    VALUE  
  FROM  
    IQClient_CustomSettings  
  WHERE  
    (IQClient_CustomSettings._ClientGuid=@ClientGuid OR IQClient_CustomSettings._ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER))  
    AND IQClient_CustomSettings.Field IN ('SearchSettings')  
 )  
   
 SELECT   
  @SearchSettings=SearchSettings  
 FROM  
  (  
    SELECT  
      
     [Field],  
     [VALUE]  
    FROM  
     TEMP_ClientSettings  
    WHERE   
     RowNum =1  
  ) AS SourceTable  
  PIVOT  
  (  
   MAX(VALUE)  
   FOR Field IN ([SearchSettings])  
  ) AS PivotTable  
   
   
 DECLARE @DistractRegions TABLE(Region_Num INT)  
   
 DECLARE @IQTVREgion VARCHAR(MAX)   
 SELECT TOP 1  
   @IQTVREgion = VALUE   
 FROM   
   IQClient_CustomSettings   
 WHERE   
   field ='IQTVREgion' AND   
   (_ClientGuid = @ClientGUID OR _ClientGuid =CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER)) ORDER BY _ClientGuid DESC  
   
 INSERT INTO @DistractRegions  
 (  
  Region_Num  
 )  
 SELECT  
   *  
 FROM  
   Split(@IQTVREgion,',')  
     
 DECLARE @DistractCountries TABLE(Country_Num INT)  
   
 DECLARE @IQTVCountry VARCHAR(MAX)   
 SELECT TOP 1  
   @IQTVCountry = VALUE   
 FROM   
   IQClient_CustomSettings   
 WHERE   
   field ='IQTVCountry' AND   
   (_ClientGuid = @ClientGUID OR _ClientGuid =CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER)) ORDER BY _ClientGuid DESC  
   
 INSERT INTO @DistractCountries  
 (  
  Country_Num  
 )  
 SELECT  
   *  
 FROM  
   Split(@IQTVCountry,',')  
  
 DECLARE @IsAllDmaAllowed BIT,  
 @IsAllClassAllowed BIT,  
 @IsAllStationAllowed BIT   
  
    SELECT   
  @IsAllDmaAllowed =  tbl.c.exist('IQ_Dma_Set[@IsAllowAll="true"]'),   
  @IsAllClassAllowed = tbl.c.exist('/SearchSettings/IQ_Class_Set[@IsAllowAll="true"]'),  
  @IsAllStationAllowed = tbl.c.exist('/SearchSettings/Station_Affiliate_Set[@IsAllowAll="true"]')  
 FROM   
  @SearchSettings.nodes('/SearchSettings') AS tbl(c)  
   
 DECLARE @DMAtable TABLE(Dma_Name VARCHAR(255), Dma_Num VARCHAR(255))  
 DECLARE @StationTable TABLE(Station_Affil VARCHAR(30), Station_Call_Sign VARCHAR(255),IQ_Station_ID VARCHAR(255),Dma_Name VARCHAR(255),Country VARCHAR(255), Region VARCHAR(255))  
 DECLARE @RegionTable TABLE(Region VARCHAR(255), Region_Num VARCHAR(30))  
 DECLARE @CountryTable TABLE(Country VARCHAR(255), Country_Num VARCHAR(30))    
    
 IF (@IsAllDmaAllowed = 0)  
 BEGIN  
  INSERT INTO @DMAtable  
  (  
   Dma_Name,  
   Dma_Num  
  )  
  SELECT DISTINCT  
   IQ_Station.Dma_Name,  
   IQ_Station.Dma_Num  
  FROM   
   IQ_Station   
    INNER JOIN @SearchSettings.nodes('/SearchSettings/IQ_Dma_Set/IQ_Dma') AS tbl(c)  
     ON IQ_Station.Dma_Name=tbl.c.query('name').value('.','varchar(255)')     
      AND IsActive= 1 AND Format ='TV'   
    INNER JOIN @DistractRegions Reg  
     ON IQ_Station.Region_num=Reg.Region_Num  
    INNER JOIN @DistractCountries Country  
     ON IQ_Station.Country_num=Country.Country_Num  
  ORDER BY Dma_Num  
 END  
 ELSE  
 BEGIN  
  INSERT INTO @DMAtable  
  (  
   Dma_Name,  
   Dma_Num  
  )  
  SELECT DISTINCT  
   Dma_Name,  
   Dma_Num  
  FROM  
   IQ_Station  
   INNER JOIN @DistractRegions Reg  
     ON IQ_Station.Region_num=Reg.Region_Num  
   INNER JOIN @DistractCountries Country  
     ON IQ_Station.Country_num=Country.Country_Num  
  WHERE  
   IsActive= 1 AND Format ='TV'   
  ORDER BY  
   Dma_Num  
 END  
  
 SELECT *FROM @DMAtable  
   
 IF (@IsAllClassAllowed = 0)   
 BEGIN  
  SELECT  
   SSP_IQ_Class.IQ_Class,  
   SSP_IQ_Class.IQ_Class_Num  
  FROM   
   SSP_IQ_Class   
    INNER JOIN @SearchSettings.nodes('/SearchSettings/IQ_Class_Set/IQ_Class') AS tbl(c)  
     ON IQ_Class_Num=tbl.c.query('num').value('.','varchar(255)')     
      AND IsActive= 1   
  ORDER BY IQ_Class  
 END  
 ELSE  
 BEGIN  
  SELECT  
   IQ_Class,  
   IQ_Class_Num  
  FROM  
   SSP_IQ_Class  
  WHERE  
   IsActive= 1  
  ORDER BY  
   IQ_Class_Num  
 END  
    
 IF (@IsAllStationAllowed = 0)   
 BEGIN  
  INSERT INTO @StationTable  
  (  
   Station_Affil,  
   Station_Call_Sign,  
   IQ_Station_ID,
   Dma_Name,
   Country,
   Region  
  )  
  SELECT DISTINCT  
   IQ_Station.Station_Affil  
   ,IQ_Station.Station_Call_Sign,  
   IQ_Station_ID,
   Dma_Name,
   Country,
   Region
  FROM   
   IQ_Station   
    INNER JOIN @SearchSettings.nodes('/SearchSettings/Station_Affiliate_Set/Station_Affiliate') AS tbl(c)  
     ON Station_Affil=tbl.c.query('name').value('.','varchar(255)')     
      AND IsActive= 1 AND Format ='TV'   
     INNER JOIN @DistractRegions Reg  
      ON IQ_Station.Region_num=Reg.Region_Num  
     INNER JOIN @DistractCountries Country  
      ON IQ_Station.Country_num=Country.Country_Num  
  ORDER BY Station_Affil  
 END  
 ELSE  
 BEGIN  
  INSERT INTO @StationTable  
  (  
   Station_Affil,  
   Station_Call_Sign,  
   IQ_Station_ID,
   Dma_Name,
   Country,
   Region
  )  
  SELECT DISTINCT  
   Station_Affil  
   ,Station_Call_Sign,  
   IQ_Station_ID,
   Dma_Name,
   Country,
   Region
  FROM   
   IQ_Station  
   INNER JOIN @DistractRegions Reg  
      ON IQ_Station.Region_num=Reg.Region_Num  
     INNER JOIN @DistractCountries Country  
      ON IQ_Station.Country_num=Country.Country_Num  
  WHERE   
   IsActive=1 AND Format ='TV'   
  ORDER BY  
   Station_Affil  
 END  
   
 SELECT DISTINCT Station_Affil FROM @StationTable  
     
 IF (@IsAllStationAllowed = 0 OR @IsAllDmaAllowed = 0)  
 BEGIN   
  INSERT INTO @RegionTable  
  (  
   Region,  
   Region_Num  
  )  
  SELECT DISTINCT  
   IQ_Station.Region  
   ,IQ_Station.Region_Num  
 FROM   
   IQ_Station  
     INNER JOIN @DMAtable dmatbl  
      ON IQ_Station.Dma_Name = dmatbl.Dma_Name  
     INNER JOIN @StationTable stationtbl  
      ON IQ_Station.IQ_Station_ID = stationtbl.IQ_Station_ID  
     INNER JOIN @DistractRegions Reg  
      ON IQ_Station.Region_num=Reg.Region_Num  
     INNER JOIN @DistractCountries Country  
      ON IQ_Station.Country_num=Country.Country_Num  
  WHERE   
   IsActive=1 AND Format ='TV'      
  ORDER BY Region  
  
  INSERT INTO @CountryTable  
  (  
   Country,  
   Country_Num  
  )  
  SELECT DISTINCT  
   IQ_Station.Country  
   ,IQ_Station.Country_Num  
  FROM   
   IQ_Station  
     INNER JOIN @DMAtable dmatbl  
      ON IQ_Station.Dma_Name = dmatbl.Dma_Name  
     INNER JOIN @StationTable stationtbl  
      ON IQ_Station.IQ_Station_ID = stationtbl.IQ_Station_ID  
     INNER JOIN @DistractRegions Reg  
      ON IQ_Station.Region_num=Reg.Region_Num  
     INNER JOIN @DistractCountries Country  
      ON IQ_Station.Country_num=Country.Country_Num  
  WHERE   
   IsActive=1 AND Format ='TV'   
   --and Region != 'Global'     
  ORDER BY Country  
    END  
 ELSE  
 BEGIN  
  INSERT INTO @RegionTable  
  (  
   Region,  
   Region_Num  
  )  
  SELECT DISTINCT  
   IQ_Station.Region  
   ,IQ_Station.Region_Num  
  FROM   
    IQ_Station  
     INNER JOIN @DistractRegions Reg  
      ON IQ_Station.Region_num=Reg.Region_Num  
     INNER JOIN @DistractCountries Country  
      ON IQ_Station.Country_num=Country.Country_Num  
   WHERE   
    IsActive=1 AND Format ='TV'      
   ORDER BY Region  
  
  INSERT INTO @CountryTable  
  (  
   Country,  
   Country_Num  
  )  
  SELECT DISTINCT  
    IQ_Station.Country  
    ,IQ_Station.Country_Num  
  FROM   
    IQ_Station  
     INNER JOIN @DistractRegions Reg  
      ON IQ_Station.Region_num=Reg.Region_Num  
     INNER JOIN @DistractCountries Country  
      ON IQ_Station.Country_num=Country.Country_Num  
  WHERE   
    IsActive=1 AND Format ='TV'   
    --and Region != 'Global'     
  ORDER BY Country  
 END  
   
 SELECT * FROM @RegionTable  
 SELECT * FROM @CountryTable  
 SELECT DISTINCT IQ_Station_ID,Station_Call_Sign,Dma_Name,Station_Affil,Country,Region FROM @StationTable  
   
 SELECT @IsAllDmaAllowed AS IsAllDmaAllowed,  
   @IsAllClassAllowed AS IsAllClassAllowed,  
   @IsAllStationAllowed AS IsAllStationAllowed  
      
END