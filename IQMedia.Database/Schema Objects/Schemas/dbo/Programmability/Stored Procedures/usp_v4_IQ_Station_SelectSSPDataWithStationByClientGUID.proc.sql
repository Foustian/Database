CREATE PROCEDURE [dbo].[usp_v4_IQ_Station_SelectSSPDataWithStationByClientGUID]
	@ClientGUID		uniqueidentifier
AS
BEGIN
	SET NOCOUNT ON;
	
	Declare @SearchSettings xml
	
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
			
	declare @DistractCountries table(Country_Nm int)


	DECLARE @IQTVCountry varchar(max) 
	SELECT top 1
			@IQTVCountry = value 
	from 
			IQClient_CustomSettings 
	where 
			field ='IQTVCountry' and 
			(_ClientGuid = @ClientGUID or _ClientGuid =CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER)) order by _ClientGuid desc
			
	insert into @DistractCountries
	(
		Country_Nm
	)
	select
			*
	From
			Split(@IQTVCountry,',')

	Declare @IsAllDmaAllowed bit,
	@IsAllClassAllowed bit,
	@IsAllStationAllowed bit 

    SELECT 
		@IsAllDmaAllowed =  tbl.c.exist('IQ_Dma_Set[@IsAllowAll="true"]'), 
		@IsAllClassAllowed = tbl.c.exist('/SearchSettings/IQ_Class_Set[@IsAllowAll="true"]'),
		@IsAllStationAllowed = tbl.c.exist('/SearchSettings/Station_Affiliate_Set[@IsAllowAll="true"]')
	FROM 
		@SearchSettings.nodes('/SearchSettings') as tbl(c)
	
	DECLARE @DMAtable TABLE(Dma_Num varchar(255), Dma_Name varchar(255))
	DECLARE @StationTable TABLE(Station_Affil varchar(30), Station_Call_Sign varchar(255),IQ_Station_ID varchar(255))	
		
	IF (@IsAllDmaAllowed = 0)
	BEGIN
		insert into @DMAtable
		SELECT DISTINCT
			IQ_Station.Dma_Num,
			IQ_Station.Dma_Name 
		FROM 
			IQ_Station 
				INNER JOIN @SearchSettings.nodes('/SearchSettings/IQ_Dma_Set/IQ_Dma') as tbl(c)
					ON IQ_Station.Dma_Name=tbl.c.query('name').value('.','varchar(255)')			
						AND IsActive= 1 AND Format ='TV' 
				Inner join @DistractRegions Reg
					ON IQ_Station.Region_num=Reg.Region_Num
				Inner join @DistractCountries Country
					ON IQ_Station.Country_num=Country.Country_Nm
			ORDER BY Dma_Name
		--ORDER BY Dma_Num
	END
	ELSE
	BEGIN
		insert into @DMAtable
		SELECT DISTINCT
			Dma_Name,
			Dma_Num	
		FROM
			IQ_Station
				Inner join @DistractRegions Reg
						ON IQ_Station.Region_num=Reg.Region_Num
					Inner join @DistractCountries Country
						ON IQ_Station.Country_num=Country.Country_Nm
		WHERE
			IsActive= 1 AND Format ='TV' 
		ORDER BY Dma_Name
			--Dma_Num
	END
	
	select * from @DMAtable

	IF (@IsAllClassAllowed = 0)	
	BEGIN
		SELECT
			SSP_IQ_Class.IQ_Class,
			SSP_IQ_Class.IQ_Class_Num
		FROM 
			SSP_IQ_Class 
				INNER JOIN @SearchSettings.nodes('/SearchSettings/IQ_Class_Set/IQ_Class') as tbl(c)
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
		
	IF (@IsAllStationAllowed = 0)	
	BEGIN
		insert into @StationTable
		SELECT DISTINCT
			IQ_Station.IQ_Station_ID,
			IQ_Station.Station_Call_Sign,
			IQ_Station.Station_Affil
		FROM 
			IQ_Station 
				INNER JOIN @SearchSettings.nodes('/SearchSettings/Station_Affiliate_Set/Station_Affiliate') as tbl(c)
					ON Station_Affil=tbl.c.query('name').value('.','varchar(255)')			
						AND IsActive= 1 AND Format ='TV' 
						Inner join @DistractRegions Reg
					ON IQ_Station.Region_num=Reg.Region_Num
				Inner join @DistractCountries Country
					ON IQ_Station.Country_num=Country.Country_Nm
			ORDER BY Station_Call_Sign
		--ORDER BY Station_Affil_Num
	END
	ELSE
	BEGIN
		insert into @StationTable
		select DISTINCT
			IQ_Station_ID,
			IQ_Station.Station_Call_Sign,
			IQ_Station.Station_Affil		
		from 
			IQ_Station
			Inner join @DistractRegions Reg
					ON IQ_Station.Region_num=Reg.Region_Num
				Inner join @DistractCountries Country
					ON IQ_Station.Country_num=Country.Country_Nm
		where 
			IsActive=1 AND Format ='TV' 
			
		ORDER BY Station_Call_Sign
			--Station_Affil_Num
	END
	
	select *from @StationTable
	
	Select @IsAllDmaAllowed as IsAllDmaAllowed,
			@IsAllClassAllowed as IsAllClassAllowed,
			@IsAllStationAllowed as IsAllStationAllowed
			
	IF (@IsAllStationAllowed = 0 or @IsAllDmaAllowed = 0)
	BEGIN	
		SELECT DISTINCT
			IQ_Station.Region
			,IQ_Station.Region_Num
	from 
			IQ_Station
					inner join @DMAtable dmatbl
						on IQ_Station.Dma_Name = dmatbl.Dma_Name
					inner join @StationTable stationtbl
						on IQ_Station.IQ_Station_ID = stationtbl.IQ_Station_ID
					Inner join @DistractRegions Reg
						ON IQ_Station.Region_num=Reg.Region_Num
					Inner join @DistractCountries Country
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
					Inner join @DistractCountries Country
						ON IQ_Station.Country_num=Country.Country_Nm
		where 
			IsActive=1 AND Format ='TV' 
			--and Region != 'Global'			
		ORDER BY Country
    END
	ELSE
	BEGIN
		SELECT DISTINCT
			IQ_Station.Region
			,IQ_Station.Region_Num
		from 
				IQ_Station
					Inner join @DistractRegions Reg
						ON IQ_Station.Region_num=Reg.Region_Num
					Inner join @DistractCountries Country
						ON IQ_Station.Country_num=Country.Country_Nm
			where 
				IsActive=1 AND Format ='TV' 			
			ORDER BY Region

		SELECT DISTINCT
				IQ_Station.Country
				,IQ_Station.Country_Num
		from 
				IQ_Station
					Inner join @DistractRegions Reg
						ON IQ_Station.Region_num=Reg.Region_Num
					Inner join @DistractCountries Country
						ON IQ_Station.Country_num=Country.Country_Nm
		where 
				IsActive=1 AND Format ='TV' 
				--and Region != 'Global'			
		ORDER BY Country
	END
END