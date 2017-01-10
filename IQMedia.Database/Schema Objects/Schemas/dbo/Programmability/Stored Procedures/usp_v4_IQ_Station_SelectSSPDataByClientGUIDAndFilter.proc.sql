CREATE PROCEDURE [dbo].[usp_v4_IQ_Station_SelectSSPDataByClientGUIDAndFilter]
(  
 @ClientGUID  uniqueidentifier,  
 @SelectedMarket xml,  
 @SelectedAffil xml ,
 @SelectedStation xml,
 @Region int,
 @Country int
)  
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

	declare @totalregion int
	select @totalregion = count(*) from @DistractRegions
  
 Declare @IsAllDmaAllowed bit,  
 @IsAllStationAllowed bit   
  
    SELECT   
  @IsAllDmaAllowed =  tbl.c.exist('IQ_Dma_Set[@IsAllowAll="true"]'),   
  @IsAllStationAllowed = tbl.c.exist('/SearchSettings/Station_Affiliate_Set[@IsAllowAll="true"]')  
 FROM   
  @SearchSettings.nodes('/SearchSettings') as tbl(c)  
   
    
  DECLARE @DMAtable TABLE(Dma_Num varchar(255), Dma_Name varchar(255))
  DECLARE @StationTable TABLE(Station_Affil varchar(30), Station_Call_Sign varchar(255),IQ_Station_ID varchar(255))
    
 IF (@IsAllDmaAllowed = 0)  
 BEGIN  
		IF(@SelectedMarket IS NOT null)  
		BEGIN  
			   insert into @DMAtable
			   SELECT DISTINCT  
						IQ_Station_Rajesh.Dma_Num,  
						IQ_Station_Rajesh.Dma_Name   
			   FROM   
						IQ_Station_Rajesh   
							INNER JOIN @SearchSettings.nodes('/SearchSettings/IQ_Dma_Set/IQ_Dma') as tbl(c)  
								ON		IQ_Station_Rajesh.Dma_Name=tbl.c.query('name').value('.','varchar(255)')     
									AND IsActive= 1 AND Format ='TV'   
							INNER JOIN @SelectedMarket.nodes('list/dma') as item(dma)  
								ON		IQ_Station_Rajesh.Dma_Name = item.dma.value('@name','varchar(255)')     
			   ORDER BY Dma_Name  
		END  
		ELSE   
		BEGIN  
				IF (@SelectedAffil IS NULL)
				Begin
					   IF(@SelectedStation IS NULL)
					   BEGIN
						   insert into @DMAtable
						   SELECT DISTINCT  
									IQ_Station_Rajesh.Dma_Num,  
									IQ_Station_Rajesh.Dma_Name   
						   FROM   
									IQ_Station_Rajesh   
										INNER JOIN @SearchSettings.nodes('/SearchSettings/IQ_Dma_Set/IQ_Dma') as tbl(c)  
											ON		IQ_Station_Rajesh.Dma_Name=tbl.c.query('name').value('.','varchar(255)')     
												AND IsActive= 1 AND Format ='TV' 
							WHERE
								(@Region is null or IQ_Station_Rajesh.Region_num = @Region)   
								and (@Country is null or Country_Num = @Country)  
							ORDER BY Dma_Name  
						END
						ELSE
						BEGIN
							insert into @DMAtable
							SELECT DISTINCT  
									IQ_Station_Rajesh.Dma_Num,  
									IQ_Station_Rajesh.Dma_Name   
						   FROM   
									IQ_Station_Rajesh   
										INNER JOIN @SearchSettings.nodes('/SearchSettings/IQ_Dma_Set/IQ_Dma') as tbl(c)  
											ON		IQ_Station_Rajesh.Dma_Name=tbl.c.query('name').value('.','varchar(255)')     
												AND IsActive= 1 AND Format ='TV'   
										INNER JOIN @SelectedStation.nodes('list/stationid') as item1(stationid)  
											ON		IQ_Station_Rajesh.IQ_Station_ID = item1.stationid.value('@id','varchar(255)')     
							WHERE
								(@Region is null or IQ_Station_Rajesh.Region_num = @Region)   
								and (@Country is null or Country_Num = @Country)  
							ORDER BY Dma_Name  
						END
				end
				else
				begin
						IF(@SelectedStation IS NULL)
					   BEGIN
							insert into @DMAtable
							SELECT DISTINCT  
									IQ_Station_Rajesh.Dma_Num,  
									IQ_Station_Rajesh.Dma_Name   
						   FROM   
									IQ_Station_Rajesh   
										INNER JOIN @SearchSettings.nodes('/SearchSettings/IQ_Dma_Set/IQ_Dma') as tbl(c)  
											ON		IQ_Station_Rajesh.Dma_Name=tbl.c.query('name').value('.','varchar(255)')     
												AND IsActive= 1 
												AND Format ='TV'
										INNER JOIN @SelectedAffil.nodes('list/station') as item(station)  
											ON		IQ_Station_Rajesh.Station_Affil = item.station.value('@name','varchar(255)')     
							WHERE
								(@Region is null or IQ_Station_Rajesh.Region_num = @Region)   
								and (@Country is null or Country_Num = @Country)  			
							ORDER BY Dma_Name  
						END
						ELSE
						BEGIN
							insert into @DMAtable
							SELECT DISTINCT  
									IQ_Station_Rajesh.Dma_Num,  
									IQ_Station_Rajesh.Dma_Name   
						   FROM   
									IQ_Station_Rajesh   
										INNER JOIN @SearchSettings.nodes('/SearchSettings/IQ_Dma_Set/IQ_Dma') as tbl(c)  
											ON		IQ_Station_Rajesh.Dma_Name=tbl.c.query('name').value('.','varchar(255)')     
												AND IsActive= 1 
												AND Format ='TV'
										INNER JOIN @SelectedAffil.nodes('list/station') as item(station)  
											ON		IQ_Station_Rajesh.Station_Affil = item.station.value('@name','varchar(255)') 
										INNER JOIN @SelectedStation.nodes('list/stationid') as item1(stationid)  
											ON		IQ_Station_Rajesh.IQ_Station_ID = item1.stationid.value('@id','varchar(255)')      
							WHERE
										(@Region is null or IQ_Station_Rajesh.Region_num = @Region)   
										and (@Country is null or Country_Num = @Country)  					 
							ORDER BY Dma_Name  
						END
				end
		END    
 END  
 ELSE  
 BEGIN  
		IF(@SelectedMarket IS NOT null)  
		BEGIN  
			   insert into @DMAtable
			   SELECT DISTINCT  
						Dma_Num,
						Dma_Name  
			   FROM  
					IQ_Station_Rajesh   
						INNER JOIN @SelectedMarket.nodes('list/dma') as item(dma)  
							ON		IQ_Station_Rajesh.Dma_Name = item.dma.value('@name','varchar(255)')     
			   WHERE  
						IsActive= 1 
					AND Format ='TV'  
					and (@Region is null or IQ_Station_Rajesh.Region_num = @Region)   
					and (@Country is null or Country_Num = @Country)  					  
			   ORDER BY Dma_Name  
		END  
	  ELSE  
	  BEGIN  
			if (@SelectedAffil is null)
			begin
				   IF(@SelectedStation IS NULL)
				   BEGIN
					   insert into @DMAtable
					   SELECT DISTINCT  
								Dma_Num,
								Dma_Name  
					   FROM  
								IQ_Station_Rajesh   
					   WHERE  
								IsActive= 1 
							AND Format ='TV'   
							and (@Region is null or IQ_Station_Rajesh.Region_num = @Region)   
							and (@Country is null or Country_Num = @Country)  					 
					   ORDER BY Dma_Name  
					END
					ELSE
					BEGIN
						insert into @DMAtable
						SELECT DISTINCT  
								Dma_Num,  
								Dma_Name  
					   FROM  
								IQ_Station_Rajesh   
									INNER JOIN @SelectedStation.nodes('list/stationid') as item1(stationid)  
											ON		IQ_Station_Rajesh.IQ_Station_ID = item1.stationid.value('@id','varchar(255)')      
					   WHERE  
								IsActive= 1 
							AND Format ='TV'   
							and (@Region is null or IQ_Station_Rajesh.Region_num = @Region)   
							and (@Country is null or Country_Num = @Country)  					 
					   ORDER BY Dma_Name  
					END
			end
			else
			begin
				IF(@SelectedStation IS NULL)
				BEGIN
					insert into @DMAtable
					SELECT DISTINCT  
							Dma_Num,
							Dma_Name  
				   FROM  
							IQ_Station_Rajesh  
								INNER JOIN @SelectedAffil.nodes('list/station') as item(station)  
									ON		IQ_Station_Rajesh.Station_Affil = item.station.value('@name','varchar(255)')      
				   WHERE  
							IsActive= 1 
						AND Format ='TV'   
						and (@Region is null or IQ_Station_Rajesh.Region_num = @Region)   
						and (@Country is null or Country_Num = @Country)  					 
				   ORDER BY Dma_Name
				 END
				 ELSE
				 BEGIN
						insert into @DMAtable
						SELECT DISTINCT  
								Dma_Num,
								Dma_Name  
					   FROM  
								IQ_Station_Rajesh  
									INNER JOIN @SelectedAffil.nodes('list/station') as item(station)  
										ON		IQ_Station_Rajesh.Station_Affil = item.station.value('@name','varchar(255)')     
									INNER JOIN @SelectedStation.nodes('list/stationid') as item1(stationid)  
										ON		IQ_Station_Rajesh.IQ_Station_ID = item1.stationid.value('@id','varchar(255)')       
					   WHERE  
								IsActive= 1 
							AND Format ='TV'  
							and (@Region is null or IQ_Station_Rajesh.Region_num = @Region)   
							and (@Country is null or Country_Num = @Country)  					 
				   ORDER BY Dma_Name
				 END
			end
	  END     
 END      
 IF (@IsAllStationAllowed = 0)   
 BEGIN  
	  IF(@SelectedAffil IS NOT null)  
	  BEGIN  
		   IF(@SelectedStation IS NULL)
		   BEGIN
			   insert into @StationTable
			   SELECT DISTINCT  
						IQ_Station_Rajesh.Station_Affil
						,IQ_Station_Rajesh.Station_Call_Sign,
						IQ_Station_Rajesh.IQ_Station_ID  
			   FROM   
						IQ_Station_Rajesh   
							INNER JOIN @SearchSettings.nodes('/SearchSettings/Station_Affiliate_Set/Station_Affiliate') as tbl(c)  
								ON		Station_Affil=tbl.c.query('name').value('.','varchar(255)')     
								AND IsActive= 1 AND Format ='TV'   
							INNER JOIN @SelectedAffil.nodes('list/station') as item(station)  
								ON		IQ_Station_Rajesh.Station_Affil = item.station.value('@name','varchar(255)')   
							Inner join @DistractRegions Reg
								ON IQ_Station_rajesh.Region_num=Reg.Region_Num 
				WHERE
					 (@Region is null or IQ_Station_Rajesh.Region_num = @Region)   
					  and (@Country is null or Country_Num = @Country)
				ORDER BY Station_Call_Sign  
			   --ORDER BY Station_Affil_Num  
			END
			ELSE
			BEGIN
				insert into @StationTable
				SELECT DISTINCT  
						IQ_Station_Rajesh.Station_Affil
						,IQ_Station_Rajesh.Station_Call_Sign,
						IQ_Station_Rajesh.IQ_Station_ID  
			   FROM   
						IQ_Station_Rajesh   
							INNER JOIN @SearchSettings.nodes('/SearchSettings/Station_Affiliate_Set/Station_Affiliate') as tbl(c)  
								ON		Station_Affil=tbl.c.query('name').value('.','varchar(255)')     
								AND IsActive= 1 AND Format ='TV'   
							INNER JOIN @SelectedAffil.nodes('list/station') as item(station)  
								ON		IQ_Station_Rajesh.Station_Affil = item.station.value('@name','varchar(255)')  
							INNER JOIN @SelectedStation.nodes('list/stationid') as item1(stationid)  
								ON		IQ_Station_Rajesh.IQ_Station_ID = item1.stationid.value('@id','varchar(255)')     
							Inner join @DistractRegions Reg
								ON IQ_Station_rajesh.Region_num=Reg.Region_Num 
				WHERE
					 (@Region is null or IQ_Station_Rajesh.Region_num = @Region)   
					  and (@Country is null or Country_Num = @Country)
				ORDER BY Station_Call_Sign  
			   --ORDER BY Station_Affil_Num  
			END
	  END  
	  ELSE   
	  BEGIN  
			if (@SelectedMarket is null)
			begin
					IF(@SelectedStation IS NULL)
					BEGIN
						insert into @StationTable
						SELECT DISTINCT 
							IQ_Station_Rajesh.Station_Affil
							,IQ_Station_Rajesh.Station_Call_Sign, 
							IQ_Station_Rajesh.IQ_Station_ID  
						FROM   
							IQ_Station_Rajesh   
								INNER JOIN @SearchSettings.nodes('/SearchSettings/Station_Affiliate_Set/Station_Affiliate') as tbl(c)  
									ON		Station_Affil=tbl.c.query('name').value('.','varchar(255)')     
										AND IsActive= 1 AND Format ='TV'   
								Inner join @DistractRegions Reg
									ON IQ_Station_rajesh.Region_num=Reg.Region_Num 
						WHERE
							(@Region is null or IQ_Station_Rajesh.Region_num = @Region)   
							and (@Country is null or Country_Num = @Country)
						ORDER BY Station_Call_Sign
					END
					ELSE
					BEGIN
						insert into @StationTable
						SELECT DISTINCT 
							IQ_Station_Rajesh.Station_Affil
							,IQ_Station_Rajesh.Station_Call_Sign, 
							IQ_Station_Rajesh.IQ_Station_ID  
						FROM   
							IQ_Station_Rajesh   
								INNER JOIN @SearchSettings.nodes('/SearchSettings/Station_Affiliate_Set/Station_Affiliate') as tbl(c)  
									ON		Station_Affil=tbl.c.query('name').value('.','varchar(255)')     
										AND IsActive= 1 AND Format ='TV'   
								Inner join @DistractRegions Reg
									ON IQ_Station_rajesh.Region_num=Reg.Region_Num 
								INNER JOIN @SelectedStation.nodes('list/stationid') as item1(stationid)  
									ON		IQ_Station_Rajesh.IQ_Station_ID = item1.stationid.value('@id','varchar(255)')   
						WHERE
							(@Region is null or IQ_Station_Rajesh.Region_num = @Region)   
							and (@Country is null or Country_Num = @Country)
						ORDER BY Station_Call_Sign
					END
			end
			else
			begin
					IF(@SelectedStation IS NULL)
					BEGIN
						insert into @StationTable
						SELECT DISTINCT  
							IQ_Station_Rajesh.Station_Affil
							,IQ_Station_Rajesh.Station_Call_Sign,
							IQ_Station_ID
						FROM   
							IQ_Station_Rajesh   
								INNER JOIN @SearchSettings.nodes('/SearchSettings/Station_Affiliate_Set/Station_Affiliate') as tbl(c)  
									ON		Station_Affil=tbl.c.query('name').value('.','varchar(255)')     
										AND IsActive= 1 AND Format ='TV'
								INNER JOIN @SelectedMarket.nodes('list/dma') as item(dma)  
									ON		IQ_Station_Rajesh.Dma_Name = item.dma.value('@name','varchar(255)')   
								Inner join @DistractRegions Reg
									ON IQ_Station_rajesh.Region_num=Reg.Region_Num 
						WHERE
							(@Region is null or IQ_Station_Rajesh.Region_num = @Region)   
							and (@Country is null or Country_Num = @Country)
						ORDER BY Station_Call_Sign
					END
					ELSE
					BEGIN
						insert into @StationTable
						SELECT DISTINCT  
							IQ_Station_Rajesh.Station_Affil
							,IQ_Station_Rajesh.Station_Call_Sign,
							IQ_Station_ID
						FROM   
							IQ_Station_Rajesh   
								INNER JOIN @SearchSettings.nodes('/SearchSettings/Station_Affiliate_Set/Station_Affiliate') as tbl(c)  
									ON		Station_Affil=tbl.c.query('name').value('.','varchar(255)')     
										AND IsActive= 1 AND Format ='TV'
								INNER JOIN @SelectedMarket.nodes('list/dma') as item(dma)  
									ON		IQ_Station_Rajesh.Dma_Name = item.dma.value('@name','varchar(255)')   
								Inner join @DistractRegions Reg
									ON IQ_Station_rajesh.Region_num=Reg.Region_Num 
								INNER JOIN @SelectedStation.nodes('list/stationid') as item1(stationid)  
									ON		IQ_Station_Rajesh.IQ_Station_ID = item1.stationid.value('@id','varchar(255)')   
						WHERE
							(@Region is null or IQ_Station_Rajesh.Region_num = @Region)   
							and (@Country is null or Country_Num = @Country)
						ORDER BY Station_Call_Sign
					END
					
			end
		END  
 END  
 ELSE  
 BEGIN  
	IF(@SelectedAffil IS NOT null)  
	BEGIN  
			IF(@SelectedStation IS NULL)
			BEGIN
				   insert into @StationTable
				   select DISTINCT
							IQ_Station_Rajesh.Station_Affil
							,IQ_Station_Rajesh.Station_Call_Sign,  
							IQ_Station_Rajesh.IQ_Station_ID  
				   from   
							IQ_Station_Rajesh  
								INNER JOIN @SelectedAffil.nodes('list/station') as item(station)  
									ON		IQ_Station_Rajesh.Station_Affil = item.station.value('@name','varchar(255)')   
								Inner join @DistractRegions Reg
									ON IQ_Station_rajesh.Region_num=Reg.Region_Num 
				   where   
							IsActive=1 
						AND Format ='TV'   
						and (@Region is null or IQ_Station_Rajesh.Region_num = @Region)   
						and (@Country is null or Country_Num = @Country)
				   ORDER BY Station_Call_Sign  
			END
			ELSE
			BEGIN
				insert into @StationTable
				select DISTINCT
							IQ_Station_Rajesh.Station_Affil
							,IQ_Station_Rajesh.Station_Call_Sign,  
							IQ_Station_Rajesh.IQ_Station_ID  
				   from   
							IQ_Station_Rajesh  
								INNER JOIN @SelectedAffil.nodes('list/station') as item(station)  
									ON		IQ_Station_Rajesh.Station_Affil = item.station.value('@name','varchar(255)')   
								INNER JOIN @SelectedStation.nodes('list/stationid') as item1(stationid)  
									ON		IQ_Station_Rajesh.IQ_Station_ID = item1.stationid.value('@id','varchar(255)')   
								Inner join @DistractRegions Reg
									ON IQ_Station_rajesh.Region_num=Reg.Region_Num 
				   where   
							IsActive=1 
						AND Format ='TV'   
						and (@Region is null or IQ_Station_Rajesh.Region_num = @Region)   
						and (@Country is null or Country_Num = @Country)
				   ORDER BY Station_Call_Sign  
			END
	END  
	ELSE  
	BEGIN
			if (@SelectedMarket is null)
			begin
					IF(@SelectedStation IS NULL)
					BEGIN
						insert into @StationTable
						select DISTINCT 
								IQ_Station_Rajesh.Station_Affil
								,IQ_Station_Rajesh.Station_Call_Sign, 
								IQ_Station_Rajesh.IQ_Station_ID  
						from   
								IQ_Station_Rajesh								
									Inner join @DistractRegions Reg
										ON IQ_Station_rajesh.Region_num=Reg.Region_Num 
						where   
								IsActive=1 
							AND Format ='TV'   
							and (@Region is null or IQ_Station_Rajesh.Region_num = @Region)   
							and (@Country is null or Country_Num = @Country)
						ORDER BY Station_Call_Sign  
					END
					ELSE
					BEGIN
						insert into @StationTable
						select DISTINCT 
								IQ_Station_Rajesh.Station_Affil
								,IQ_Station_Rajesh.Station_Call_Sign, 
								IQ_Station_Rajesh.IQ_Station_ID  
						from   
								IQ_Station_Rajesh								
									INNER JOIN @SelectedStation.nodes('list/stationid') as item1(stationid)  
									ON		IQ_Station_Rajesh.IQ_Station_ID = item1.stationid.value('@id','varchar(255)')   
									Inner join @DistractRegions Reg
										ON IQ_Station_rajesh.Region_num=Reg.Region_Num 
						where   
								IsActive=1 
							AND Format ='TV'   
							and (@Region is null or IQ_Station_Rajesh.Region_num = @Region)   
							and (@Country is null or Country_Num = @Country)
						ORDER BY Station_Call_Sign  
					END
			end
			else
			begin
					IF(@SelectedStation IS NULL)
					BEGIN
						insert into @StationTable
						select DISTINCT  
								IQ_Station_Rajesh.Station_Affil
								,IQ_Station_Rajesh.Station_Call_Sign,
								IQ_Station_ID
						from   
								IQ_Station_Rajesh
									INNER JOIN @SelectedMarket.nodes('list/dma') as item(dma)  
										ON		IQ_Station_Rajesh.Dma_Name = item.dma.value('@name','varchar(255)')   
									Inner join @DistractRegions Reg
										ON IQ_Station_rajesh.Region_num=Reg.Region_Num 
						where   
								IsActive=1 
							AND Format ='TV'   
							and (@Region is null or IQ_Station_Rajesh.Region_num = @Region)   
							and (@Country is null or Country_Num = @Country)
						ORDER BY Station_Call_Sign  
					END
					ELSE
					BEGIN
						insert into @StationTable
						select DISTINCT  
								IQ_Station_Rajesh.Station_Affil
								,IQ_Station_Rajesh.Station_Call_Sign,
								IQ_Station_ID
						from   
								IQ_Station_Rajesh
									INNER JOIN @SelectedMarket.nodes('list/dma') as item(dma)  
										ON		IQ_Station_Rajesh.Dma_Name = item.dma.value('@name','varchar(255)')  
									INNER JOIN @SelectedStation.nodes('list/stationid') as item1(stationid)  
										ON		IQ_Station_Rajesh.IQ_Station_ID = item1.stationid.value('@id','varchar(255)')    
									Inner join @DistractRegions Reg
										ON IQ_Station_rajesh.Region_num=Reg.Region_Num 
						where   
								IsActive=1 
							AND Format ='TV'   
							and (@Region is null or IQ_Station_Rajesh.Region_num = @Region)   
							and (@Country is null or Country_Num = @Country)
						ORDER BY Station_Call_Sign 
					END
			end
	END  
   --Station_Affil_Num  
 END  
   
   select *from @DMAtable
   select *from @StationTable

IF (@IsAllDmaAllowed = 0 OR @IsAllStationAllowed = 0 OR @SelectedMarket is not null OR @SelectedAffil is not null or @SelectedStation is not null)  
		BEGIN
			SELECT DISTINCT
				IQ_Station_Rajesh.Region
				,IQ_Station_Rajesh.Region_Num
			from 
				IQ_Station_Rajesh
					inner join @DMAtable dmatbl
						on IQ_Station_Rajesh.Dma_Name = dmatbl.Dma_Name
					inner join @StationTable stationtbl
						on IQ_Station_Rajesh.IQ_Station_ID = stationtbl.IQ_Station_ID
					Inner join @DistractRegions Reg
										ON IQ_Station_rajesh.Region_num=Reg.Region_Num 
			where 
				IsActive=1 AND Format ='TV' 
				--and Region != 'Global'
				and (@Country is null or Country_Num = @Country)
			ORDER BY Region
 
			SELECT DISTINCT
				IQ_Station_Rajesh.Country
				,IQ_Station_Rajesh.Country_Num
			from 
				IQ_Station_Rajesh
					inner join @DMAtable dmatbl
						on IQ_Station_Rajesh.Dma_Name = dmatbl.Dma_Name
					inner join @StationTable stationtbl
						on IQ_Station_Rajesh.IQ_Station_ID = stationtbl.IQ_Station_ID
					Inner join @DistractRegions Reg
										ON IQ_Station_rajesh.Region_num=Reg.Region_Num 
			where 
				IsActive=1 AND Format ='TV' 
				--and Region != 'Global'
				and (@Region is null or IQ_Station_Rajesh.Region_num = @Region)
			ORDER BY Country
		END
		ELSE
		BEGIN
				SELECT DISTINCT
					IQ_Station_Rajesh.Region
					,IQ_Station_Rajesh.Region_Num
				from 
					IQ_Station_Rajesh
					Inner join @DistractRegions Reg
										ON IQ_Station_rajesh.Region_num=Reg.Region_Num 
				where 
					IsActive=1 AND Format ='TV' 
					--and Region != 'Global'
					and (@Country is null or Country_Num = @Country)
				ORDER BY Region
 
				SELECT DISTINCT
					IQ_Station_Rajesh.Country
					,IQ_Station_Rajesh.Country_Num
				from 
					IQ_Station_Rajesh
					Inner join @DistractRegions Reg
										ON IQ_Station_rajesh.Region_num=Reg.Region_Num 
				where 
					IsActive=1 AND Format ='TV' 
					--and Region != 'Global'
					and (@Region is null or IQ_Station_Rajesh.Region_num = @Region)
				ORDER BY Country
		END
END  
  