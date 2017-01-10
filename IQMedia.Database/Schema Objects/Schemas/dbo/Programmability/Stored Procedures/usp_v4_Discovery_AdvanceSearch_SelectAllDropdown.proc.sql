CREATE PROCEDURE [dbo].[usp_v4_Discovery_AdvanceSearch_SelectAllDropdown]
	@ClientGuid		UNIQUEIDENTIFIER
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	Declare @SearchSettings xml

	DECLARE @DMATable TABLE(Dma_Num varchar(255),Dma_Name varchar(255))
	DECLARE @StationTable TABLE(IQ_Station_ID varchar(255),Station_Call_Sign varchar(255),Station_Affil varchar(255))

	declare @DistractRegions table(Region_Num int)


	DECLARE @IQTVREgion varchar(max) 
	SELECT top 1
			@IQTVREgion = value 
	from 
			IQClient_CustomSettings 
	where 
			field ='IQTVREgion' and 
			(_ClientGuid = @ClientGUID or _ClientGuid =CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER)) order by _ClientGuid desc
	
	insert into @DistractRegions
	(
		Region_Num
	)
	select
			*
	From
			Split(@IQTVREgion,',')
			
	declare @DistractCountry table(Country_Nm int)
	
			
	DECLARE @IQTVCountry varchar(max) 
	SELECT top 1
			@IQTVCountry = value 
	from 
			IQClient_CustomSettings 
	where 
			field ='IQTVCountry' and 
			(_ClientGuid = @ClientGUID or _ClientGuid =CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER)) order by _ClientGuid desc
	
	insert into @DistractCountry
	(
		Country_Nm
	)
	select
			*
	From
			Split(@IQTVCountry,',')
	
	;WITH TEMP_ClientSettings AS
	(
		SELECT
				ROW_NUMBER() OVER (PARTITION BY Field ORDER BY IQClient_CustomSettings._ClientGuid desc) as RowNum,
				Field,
				Value
		FROM
				IQClient_CustomSettings
		Where
				(IQClient_CustomSettings._ClientGuid=@ClientGuid OR IQClient_CustomSettings._ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER))
				AND IQClient_CustomSettings.Field IN ('SearchSettings')
	)
 
	SELECT 
		@SearchSettings=SearchSettings
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
			FOR Field IN ([SearchSettings])
		) AS PivotTable
	
	Declare @IsAllDmaAllowed bit,
	@IsAllClassAllowed bit,
	@IsAllStationAllowed bit 

    SELECT 
		@IsAllDmaAllowed =  tbl.c.exist('IQ_Dma_Set[@IsAllowAll="true"]'), 
		@IsAllClassAllowed = tbl.c.exist('/SearchSettings/IQ_Class_Set[@IsAllowAll="true"]'),
		@IsAllStationAllowed = tbl.c.exist('/SearchSettings/Station_Affiliate_Set[@IsAllowAll="true"]')
	FROM 
		@SearchSettings.nodes('/SearchSettings') as tbl(c)
	
		
	-- SELECT DMA

	IF (@IsAllDmaAllowed = 0)
		BEGIN
			insert into @DMATable
			(
				Dma_Num,
				Dma_Name
			)
			SELECT 
					DISTINCT
						IQ_Station.Dma_Num,
						IQ_Station.Dma_Name 
			FROM	IQ_Station  
			INNER JOIN @SearchSettings.nodes('/SearchSettings/IQ_Dma_Set/IQ_Dma') as tbl(c)
			ON IQ_Station.Dma_Name=tbl.c.query('name').value('.','varchar(255)')			
			AND IsActive= 1 AND Format ='TV' 
				Inner join @DistractRegions Reg
						ON IQ_Station.Region_num=Reg.Region_Num
				Inner join @DistractCountry Country
						ON IQ_Station.Country_num=Country.Country_Nm
			
			ORDER BY Dma_Name
			
		END
	ELSE
		BEGIN
			insert into @DMATable
			(
				Dma_Num,
				Dma_Name
			)
			SELECT 
					DISTINCT
						Dma_Num,
						Dma_Name
			FROM	IQ_Station
						Inner join @DistractRegions Reg
						ON IQ_Station.Region_num=Reg.Region_Num
						Inner join @DistractCountry Country
						ON IQ_Station.Country_num=Country.Country_Nm
			WHERE	IsActive= 1 AND Format ='TV' 
				
			ORDER BY Dma_Name
		END
	
	-- SELECT Station
	
	IF (@IsAllStationAllowed = 0)	
		BEGIN
			insert into @StationTable
			(
				IQ_Station_ID,
				Station_Call_Sign,
				Station_Affil
			)
			SELECT DISTINCT
				IQ_Station_ID,
				Station_Call_Sign,
				Station_Affil
			FROM IQ_Station
			
			INNER JOIN @SearchSettings.nodes('/SearchSettings/Station_Affiliate_Set/Station_Affiliate') as tbl(c)
			ON Station_Affil=tbl.c.query('name').value('.','varchar(255)')			
			AND IsActive= 1 AND Format ='TV' 
				Inner join @DistractRegions Reg
						ON IQ_Station.Region_num=Reg.Region_Num
						Inner join @DistractCountry Country
						ON IQ_Station.Country_num=Country.Country_Nm
			
			ORDER BY Station_Call_Sign
			
		END
	ELSE
		BEGIN
			insert into @StationTable
			(
				IQ_Station_ID,
				Station_Call_Sign,
				Station_Affil
			)
			SELECT 
					DISTINCT IQ_Station_ID,
					Station_Call_Sign,
					Station_Affil
			FROM  IQ_Station
					Inner join @DistractRegions Reg
						ON IQ_Station.Region_num=Reg.Region_Num
						Inner join @DistractCountry Country
						ON IQ_Station.Country_num=Country.Country_Nm
			WHERE IsActive=1 AND Format ='TV' 
			
			ORDER BY Station_Call_Sign
		
		END
	
	 select *from @DMATable

	 select *from @StationTable
	
	 SELECT ID,Label AS Label FROM NM_Region WHERE IsActive = 1 ORDER BY Order_Number  
   
	 SELECT ID,Lable AS Label FROM SM_SourceType WHERE IsActive = 1 ORDER BY Order_Number  
   
	 SELECT Name, Code FROM IQMO_Country WHERE IsActive=1 ORDER BY name  
   
	 SELECT name FROM IQMO_Language WHERE IsActive=1 ORDER BY name  

	 SELECT DISTINCT
			IQ_Station.Region
			,IQ_Station.Region_Num
		from 
			IQ_Station
					inner join @DMATable dmatbl
						on IQ_Station.Dma_Name = dmatbl.Dma_Name
					inner join @StationTable stationtbl
						on IQ_Station.IQ_Station_ID = stationtbl.IQ_Station_ID
					Inner join @DistractRegions Reg
						ON IQ_Station.Region_num=Reg.Region_Num
						Inner join @DistractCountry Country
						ON IQ_Station.Country_num=Country.Country_Nm
		where 
			IsActive=1 AND Format ='TV' 			
		ORDER BY Region

	SELECT DISTINCT
			IQ_Station.Country
			,IQ_Station.Country_Num
		from 
			IQ_Station
					inner join @DMAtable dmatbl
						on IQ_Station.Dma_Name = dmatbl.Dma_Name
					inner join @StationTable stationtbl
						on IQ_Station.IQ_Station_ID = stationtbl.IQ_Station_ID
					Inner join @DistractRegions Reg
						ON IQ_Station.Region_num=Reg.Region_Num
						Inner join @DistractCountry Country
						ON IQ_Station.Country_num=Country.Country_Nm
		where 
			IsActive=1 AND Format ='TV' 
			--and Region != 'Global'			
		ORDER BY Country  
		
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
				IQ_Class
		END
		
		SELECT ID,Label AS Label FROM NM_Genre WHERE IsActive = 1 ORDER BY Order_Number
	
		SELECT ID,Label AS Label FROM NM_NewsCategory WHERE IsActive = 1 ORDER BY Order_Number
	
		SELECT ID,Name AS Label FROM NM_PublicationCategory WHERE IsActive = 1 ORDER BY Order_Number

		SELECT @IsAllDmaAllowed AS IsAllDmaAllowed,
			@IsAllClassAllowed AS IsAllClassAllowed,
			@IsAllStationAllowed AS IsAllStationAllowed

		SELECT IQ_Dma_Num as ID, IQ_Dma_Name AS Label FROM IQDMA WHERE CAST(IQ_Dma_Num as int)>=1 AND CAST(IQ_Dma_Num as int)<=210 ORDER BY IQ_Dma_Name
END