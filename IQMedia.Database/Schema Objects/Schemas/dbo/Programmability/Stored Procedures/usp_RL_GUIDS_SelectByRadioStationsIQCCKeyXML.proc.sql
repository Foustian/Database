-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_RL_GUIDS_SelectByRadioStationsIQCCKeyXML]
	 @IQ_Station_ID  XML,  
	 @PageNumber  int,  
	 @PageSize  int,  
	 @SortField  VARCHAR(250),  
	 @IsSortDirectionAsc bit,
	 @FromDate datetime,
	 @Todate datetime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
DECLARE @StartRowNo AS BIGINT,@EndRowNo AS BIGINT   
    
 SET @StartRowNo = 1  
 SET @EndRowNo = 1      
      
 SET @StartRowNo = (@PageNumber * @PageSize) + 1  
 SET @EndRowNo   = (@PageNumber * @PageSize) + @PageSize 
 
 ;WITH IQMediaRL_GUIDS_CTE  AS ( Select  Row_Number() Over (Order by 
   Case When @IsSortDirectionAsc = 1 Then ''
Else
 Case
		When @SortField = 'DateTime' OR @SortField is null OR @SortField = ''
			Then 
			CONVERT(varchar(Max),RL_GUIDS.RL_Station_Date,101) + ' '+ REPLACE(convert(varchar(Max),convert(decimal(4,2),(convert(decimal(6,2),RL_GUIDS.RL_Station_Time)/convert(decimal(5,2),100)))),'.',':')+':00'
	Else	dma_name 
	End
	End Desc
	,
	
	Case When @IsSortDirectionAsc = 0 Then '' Else
	Case
		When @SortField = 'DateTime' OR @SortField is null OR @SortField = ''
			Then
			CONVERT(varchar(Max),RL_GUIDS.RL_Station_Date,101) + ' '+ REPLACE(convert(varchar(Max),convert(decimal(4,2),(convert(decimal(6,2),RL_GUIDS.RL_Station_Time)/convert(decimal(5,2),100)))),'.',':')+':00'
	Else	dma_name 
	End 
	END asc
	)  as RowNumber,
   RL_GUIDS.IQ_CC_Key,RL_GUIDS.RL_GUID,  
   RL_GUIDS.RL_Station_ID,  
   Dma_Name as 'dma_name',
   RL_Station_Date,  
   RL_Station_Time  
 From  
   RL_GUIDS  
    inner join IQ_Station  
     on RL_GUIDS.RL_Station_ID=IQ_Station.IQ_Station_ID  
     
     Inner Join @IQ_Station_ID.nodes('/IQ_Station_ID_Set/IQ_Station_ID') T(c)
     On RL_GUIDS.RL_station_id = T.c.value('.','varchar(max)')
 Where  
   RL_GUIDS.IsActive=1 AND IQ_Station.ISActive = 1
   and cast(CONVERT(datetime,CONVERT(varchar(Max),RL_GUIDS.RL_Station_Date,101) + ' '+ REPLACE(convert(varchar(Max),convert(decimal(4,2),(convert(decimal(6,2),RL_GUIDS.RL_Station_Time)/convert(decimal(5,2),100)))),'.',':')+':00')  as datetime) between cast(cast(@fromdate as varchar(max)) as datetime) and cast( cast(@todate as varchar(max)) as datetime) 
  )
   
   SELECT * FROM IQMediaRL_GUIDS_CTE Where RowNumber >= @StartRowNo   AND RowNumber <= @EndRowNo 
   
   
   Select count(*) from RL_GUIDS Inner Join @IQ_Station_ID.nodes('/IQ_Station_ID_Set/IQ_Station_ID') T(c) On RL_GUIDS.RL_station_id = T.c.value('.','varchar(max)') Where IsActive = 1  and cast(CONVERT(datetime,CONVERT(varchar(Max),RL_GUIDS.RL_Station_Date,101) + ' '+ REPLACE(convert(varchar(Max),convert(decimal(4,2),(convert(decimal(6,2),RL_GUIDS.RL_Station_Time)/convert(decimal(5,2),100)))),'.',':')+':00')  as datetime) between cast( cast(@fromdate as varchar(max))as datetime) and cast( cast(@todate as varchar(max)) as datetime)   
   
   
    
 --Declare @Query nvarchar(Max)  
   
 --set @Query='declare @IQ_Station_IDXML xml set @IQ_Station_IDXML = ''' + cast(@IQ_Station_ID as varchar(max)) +'''  ;WITH IQMediaRL_GUIDS_CTE  AS ( Select  ROW_NUMBER() OVER (Order by '  
 --IF @SortField IS NOT NULL OR @SortField <> ''  
 --      BEGIN  
         
 --       IF @SortField = 'DateTime'  
 --        BEGIN  
 --         SET @Query = @Query + ' CONVERT(datetime,CONVERT(varchar(Max),RL_GUIDS.RL_Station_Date,101) + '' ''+ REPLACE(convert(varchar(Max),convert(decimal(4,2),(convert(decimal(6,2),RL_GUIDS.RL_Station_Time)/convert(decimal(5,2),100)))),''.'','':'')+'':00'') '  
 --        END  
 --       ELSE  
 --        BEGIN  
 --         set @Query = @Query + @SortField   
 --        END  
          
 --       IF @IsSortDirectionAsc = 0   
 --        BEGIN  
 --         SET @Query = @Query + ' DESC '  
 --        END  
 --      END  
 --     ELSE  
 --      BEGIN  
 --       SET @Query = @Query + ' Station_ID '  
 --      END  
 --    SET @Query = @Query +  ') as RowNumber,'  
 -- set @Query=@Query +'RL_GUIDS.IQ_CC_Key,RL_GUIDS.RL_GUID,  
 --  RL_GUIDS.RL_Station_ID,  
 --  Dma_Name as ''dma_name'',
 --  RL_Station_Date,  
 --  RL_Station_Time  
 --From  
 --  RL_GUIDS  
 --   inner join IQ_Station  
 --    on RL_GUIDS.RL_Station_ID=IQ_Station.IQ_Station_ID  
     
 --    Inner Join @IQ_Station_IDXML.nodes(''/IQ_Station_ID_Set/IQ_Station_ID'') T(c)
 --    On RL_GUIDS.RL_station_id = T.c.value(''.'',''varchar(max)'')
 --Where  
 --  RL_GUIDS.IsActive=1 AND IQ_Station.ISActive = 1
 --  and cast(CONVERT(datetime,CONVERT(varchar(Max),RL_GUIDS.RL_Station_Date,101) + '' ''+ REPLACE(convert(varchar(Max),convert(decimal(4,2),(convert(decimal(6,2),RL_GUIDS.RL_Station_Time)/convert(decimal(5,2),100)))),''.'','':'')+'':00'')  as datetime) between cast(''' + cast(@fromdate as varchar(max))+''' as datetime) and cast(''' + cast(@todate as varchar(max))+''' as datetime) 
 --  )'
   
   
 --set @Query=@Query+' SELECT * FROM IQMediaRL_GUIDS_CTE Where RowNumber >=' + CAST(@StartRowNo as VARCHAR) + ' AND RowNumber <= ' + CAST(@EndRowNo as VARCHAR)  
 --print @Query  
 --exec sp_executesql @Query  
   
 --DECLARE @CountQuery NVARCHAR(Max)  
      
 --set @CountQuery='declare @IQ_Station_IDXML xml set @IQ_Station_IDXML = ''' + cast(@IQ_Station_ID as varchar(max)) +''' Select count(*) from RL_GUIDS Inner Join @IQ_Station_IDXML.nodes(''/IQ_Station_ID_Set/IQ_Station_ID'') T(c) On RL_GUIDS.RL_station_id = T.c.value(''.'',''varchar(max)'') Where IsActive = 1  and cast(CONVERT(datetime,CONVERT(varchar(Max),RL_GUIDS.RL_Station_Date,101) + '' ''+ REPLACE(convert(varchar(Max),convert(decimal(4,2),(convert(decimal(6,2),RL_GUIDS.RL_Station_Time)/convert(decimal(5,2),100)))),''.'','':'')+'':00'')  as datetime) between cast(''' + cast(@fromdate as varchar(max))+''' as datetime) and cast(''' + cast(@todate as varchar(max))+''' as datetime)'  
 
 --exec sp_executesql @CountQuery
   

   

   
END  