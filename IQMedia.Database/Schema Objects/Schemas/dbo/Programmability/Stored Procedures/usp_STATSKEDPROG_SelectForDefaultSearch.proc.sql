
CREATE PROCEDURE [dbo].[usp_STATSKEDPROG_SelectForDefaultSearch]
(
	@IQ_Time_Zone		VARCHAR(250),	
	@FromDate			DATETIME,	
	@ToDate				DATETIME,
	@IQ_Dma_Num			VARCHAR(MAX),
	@IQ_Class_Num		VARCHAR(MAX),
	--@IQ_Cat_Num			VARCHAR(MAX),	
	@Station_Affil_Num	VARCHAR(MAX),
	@Title120			VARCHAR(MAX),
	@Desc100			VARCHAR(MAX),
	@PageNumber			INT,
	@PageSize			INT,
	@SortField			VARCHAR(250),
	@IsAscending		bit
)
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @Query NVARCHAR(MAX)
				
	DECLARE @StartRowNo AS BIGINT,@EndRowNo AS BIGINT
	
	SET @StartRowNo = 1
	SET @EndRowNo = 1				
	
	SET @StartRowNo = (@PageNumber * @PageSize) + 1
	SET @EndRowNo   = (@PageNumber * @PageSize) + @PageSize
	
	SET @Query = ' WITH IQMediaStatSkedProg_CTE  '
	SET @Query = @Query + ' AS ( '
					 
	SET @Query = @Query + 'Select  ROW_NUMBER() OVER (ORDER BY '
						
	IF @SortField IS NOT NULL OR @SortField <> ''
		BEGIN
		
			IF @SortField = 'DateTime'
				BEGIN
					SET @Query = @Query + ' STATSKEDPROG.IQ_Local_Air_Date '
				END
			ELSE
				BEGIN
					set @Query = @Query + @SortField	
				END
			
			IF @IsAscending=0
				BEGIN
					SET @Query = @Query + ' DESC '
				END
		END
	ELSE
		BEGIN
			SET @Query = @Query + ' IQ_Local_Air_Date desc '
		END
		
	
	SET @Query = @Query + 	') as RowNumber,
							Station_ID,IQ_Dma_Name,IQ_Dma_Num,IQ_Local_Air_Date,IQ_Local_Air_Time,Title120,STATSKEDPROG.IQ_CC_Key,RL_GUIDS.RL_GUID from STATSKEDPROG inner join RL_GUIDS on STATSKEDPROG.IQ_CC_Key=RL_GUIDS.IQ_CC_Key where 
							STATSKEDPROG.IQ_Local_Air_Date between '''+CONVERT(varchar(Max),@FromDate)+''' and '''+CONVERT(Varchar(Max),@ToDate)+''''
							
	Declare @SubQuery varchar(Max)
	
	SET @SubQuery='select 
										MIN(STATSKEDPROGKey)
								From
										STATSKEDPROG
											inner join RL_GUIDS
												on STATSKEDPROG.IQ_CC_KEY=RL_GUIDS.IQ_CC_Key
								where 
										STATSKEDPROG.IQ_Local_Air_Date between '''+CONVERT(varchar(Max),@FromDate)+''' and '''+CONVERT(Varchar(Max),@ToDate)+''''
								
	
	IF @IQ_Dma_Num IS NOT NULL AND @IQ_Dma_Num!=''
		BEGIN
				SET @Query=@Query+' AND STATSKEDPROG.IQ_Dma_Num in ('+@IQ_Dma_Num+')'
				SET @SubQuery=@SubQuery+' AND STATSKEDPROG.IQ_Dma_Num in ('+@IQ_Dma_Num+')'
		END
		
	--IF @IQ_Cat_Num IS NOT NULL AND @IQ_Cat_Num!=''
	--	BEGIN
	--			SET @Query=@Query+' AND STATSKEDPROG.IQ_Cat_Num in ('+@IQ_Cat_Num+')'
	--			SET @SubQuery=@SubQuery+' AND STATSKEDPROG.IQ_Cat_Num in ('+@IQ_Cat_Num+')'
	--	END
	
	IF @IQ_Class_Num IS NOT NULL AND @IQ_Class_Num!=''
		BEGIN
				SET @Query=@Query+' AND STATSKEDPROG.IQ_Class_Num in ('+@IQ_Class_Num+')'
				SET @SubQuery=@SubQuery+' AND STATSKEDPROG.IQ_Class_Num in ('+@IQ_Class_Num+')'
		END
		
	IF @Station_Affil_Num IS NOT NULL AND @Station_Affil_Num!=''
		BEGIN
				SET @Query=@Query+' AND STATSKEDPROG.Station_Affil_Num in ('+@Station_Affil_Num+')'
				SET @SubQuery=@SubQuery+' AND STATSKEDPROG.Station_Affil_Num in ('+@Station_Affil_Num+')'
		END					
				
	IF @Title120 IS NOT NULL AND @Title120 <> ''
		BEGIN
			SET @Query = @Query + ' AND (STATSKEDPROG.Title120  like (''%'+@Title120+'%''))'
			SET @SubQuery=@SubQuery+' AND (STATSKEDPROG.Title120  like (''%'+@Title120+'%''))'
		END
		
	IF @Desc100 IS NOT NULL AND @Desc100 <> ''
		BEGIN
			SET @Query = @Query + ' AND (STATSKEDPROG.Desc100  like (''%'+@Desc100+'%''))'	
			SET @SubQuery=@SubQuery+' AND (STATSKEDPROG.Desc100  like (''%'+@Desc100+'%''))'	
		END				
	
	IF @IQ_Time_Zone IS NOT NULL AND @IQ_Time_Zone <> ''
		BEGIN
			SET @Query = @Query + ' AND STATSKEDPROG.IQ_Time_Zone in('''+ @IQ_Time_Zone +''')'
			SET @SubQuery=@SubQuery+' AND STATSKEDPROG.IQ_Time_Zone in('''+ @IQ_Time_Zone +''')'
		END
		
	SET @SubQuery=@SubQuery+' Group by RL_GUID'
		
	SET @Query=@Query + ' AND STATSKEDPROG.StatSkedProgKey in
							('
								+ @SubQuery +	
							')'
		
	SET @Query = @Query + ') '
		
	SET  @Query = @Query + ' SELECT * FROM IQMediaStatSkedProg_CTE Where RowNumber >=' + CAST(@StartRowNo as VARCHAR) + ' AND RowNumber <= ' + CAST(@EndRowNo as VARCHAR)						
	
	print @Query
	
	EXEC SP_EXECUTESQL @Query
	
	DECLARE @CountQuery NVARCHAR(Max)
				
	 set @CountQuery='Select count(STATSKEDPROG.STATSKEDPROGKey) as TotalRowCount  from STATSKEDPROG inner join RL_GUIDS on STATSKEDPROG.IQ_CC_Key=RL_GUIDS.IQ_CC_Key where 
    						STATSKEDPROG.IQ_Local_Air_Date between '''+CONVERT(varchar(Max),@FromDate)+''' and '''+CONVERT(Varchar(Max),@ToDate)+''''
    						
	IF @IQ_Dma_Num IS NOT NULL AND @IQ_Dma_Num!=''
		BEGIN
				SET @CountQuery=@CountQuery+' AND STATSKEDPROG.IQ_Dma_Num in ('+@IQ_Dma_Num+')'
		END
		
	--IF @IQ_Cat_Num IS NOT NULL AND @IQ_Cat_Num!=''
	--	BEGIN
	--			SET @CountQuery=@CountQuery+' AND STATSKEDPROG.IQ_Cat_Num in ('+@IQ_Cat_Num+')'
	--	END
	
	IF @IQ_Class_Num IS NOT NULL AND @IQ_Class_Num!=''
		BEGIN
				SET @CountQuery=@CountQuery+' AND STATSKEDPROG.IQ_Class_Num in ('+@IQ_Class_Num+')'
		END
		
	IF @Station_Affil_Num IS NOT NULL AND @Station_Affil_Num!=''
		BEGIN
				SET @CountQuery=@CountQuery+' AND STATSKEDPROG.Station_Affil_Num in ('+@Station_Affil_Num+')'
		END
							
				
	IF @Title120 IS NOT NULL AND @Title120 <> ''
		BEGIN
			SET @CountQuery = @CountQuery + ' AND (STATSKEDPROG.Title120  like (''%'+@Title120+'%''))'	
		END
		
	IF @Desc100 IS NOT NULL AND @Desc100 <> ''
		BEGIN
			SET @CountQuery = @CountQuery + ' AND (STATSKEDPROG.Desc100  like (''%'+@Desc100+'%''))'	
		END
	
	IF @IQ_Time_Zone IS NOT NULL AND @IQ_Time_Zone <> ''
		BEGIN
			SET @CountQuery = @CountQuery + ' AND STATSKEDPROG.IQ_Time_Zone in('''+ @IQ_Time_Zone +''')'
		END
		
	SET @CountQuery=@CountQuery+' AND STATSKEDPROG.StatSkedProgKey in
							('
								+ @SubQuery +	
							')'
		
	EXEC SP_EXECUTESQL @CountQuery
END
