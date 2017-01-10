
CREATE PROCEDURE [dbo].[usp_STATSKEDPROG_SelectForDefaultSearch_Service]
(
	@IQ_Time_Zone		VARCHAR(250),
	@SSP_Index_Key		VARCHAR(MAX),
	@FromDate			DATETIME,	
	@ToDate				DATETIME,	
	@Title120			VARCHAR(MAX),
	@Desc100			VARCHAR(MAX),
	@PageNumber			INT,
	@PageSize			INT,
	@SortField			VARCHAR(250),	
	@TotalRecordsCount	INT output
)
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @Query NVARCHAR(MAX)
				
	DECLARE @StartRowNo AS BIGINT,@EndRowNo AS BIGINT
	
	SET @StartRowNo = 1
	SET @EndRowNo = 1				
	
	SET @StartRowNo = (((@PageNumber * @PageSize) + 1)-@PageSize)
	SET @EndRowNo   = (@PageNumber * @PageSize) 
	
	SET @Query = ' WITH IQMediaStatSkedProg_CTE  '
	SET @Query = @Query + ' AS ( '
					 
	SET @Query = @Query + 'Select  ROW_NUMBER() OVER (ORDER BY '
						
	IF (@SortField IS NOT NULL AND @SortField <> '')
		BEGIN
				SET @SortField = REPLACE(@SortField,'-',' desc')
				set @Query = @Query + @SortField
		END
	ELSE
		BEGIN
			SET @Query = @Query + ' IQ_Local_Air_Date '
		END
		
	/*IF @IsAscending=0
				BEGIN
					SET @Query = @Query + ' DESC '
				END*/
		
	
	SET @Query = @Query + 	') as RowNumber,
							Station_ID,IQ_Dma_Name,IQ_Local_Air_Date,Title120,RL_GUIDS.RL_GUID from STATSKEDPROG inner join RL_GUIDS on STATSKEDPROG.IQ_CC_Key=RL_GUIDS.IQ_CC_Key where 
							IQ_Local_Air_Date between '''+CONVERT(varchar(Max),@FromDate)+''' and '''+CONVERT(Varchar(Max),@ToDate)+''''
			
	IF @SSP_Index_Key IS NOT NULL AND @SSP_Index_Key <> ''
		BEGIN
				SET @Query = @Query + 'AND STATSKEDPROG.SSP_Index_Key in ('+@SSP_Index_Key+') '
		END			 
				
	IF @Title120 IS NOT NULL AND @Title120 <> ''
		BEGIN
			SET @Query = @Query + ' AND (STATSKEDPROG.Title120  like (''%'+@Title120+'%''))'	
		END
		
	IF @Desc100 IS NOT NULL AND @Desc100 <> ''
		BEGIN
			SET @Query = @Query + ' AND (STATSKEDPROG.Desc100  like (''%'+@Desc100+'%''))'	
		END				
	
	IF @IQ_Time_Zone IS NOT NULL AND @IQ_Time_Zone <> ''
		BEGIN
			SET @Query = @Query + ' AND STATSKEDPROG.IQ_Time_Zone in('''+ @IQ_Time_Zone +''')'
		END
		
	SET @Query = @Query + ') '
		
	SET  @Query = @Query + ' SELECT * FROM IQMediaStatSkedProg_CTE Where RowNumber >=' + CAST(@StartRowNo as VARCHAR) + ' AND RowNumber <= ' + CAST(@EndRowNo as VARCHAR)						
	
	EXEC SP_EXECUTESQL @Query
	
	print @Query
	
	DECLARE @CountQuery NVARCHAR(Max)
				
	--N'SELECT @A = PRODUCTNAME FROM PRODUCTS WHERE PRODUCTID = 1', N'@A VARCHAR(100) OUTPUT', @A OUTPUT

				
	 set @CountQuery='Select @TotalRecordsCount=count(STATSKEDPROG.STATSKEDPROGKey) from STATSKEDPROG inner join RL_GUIDS on STATSKEDPROG.IQ_CC_Key=RL_GUIDS.IQ_CC_Key where 
    						IQ_Local_Air_Date between '''+CONVERT(varchar(Max),@FromDate)+''' and '''+CONVERT(Varchar(Max),@ToDate)+'''' 
							
	IF @SSP_Index_Key IS NOT NULL AND @SSP_Index_Key <> ''
		BEGIN
				SET @CountQuery = @CountQuery + 'AND STATSKEDPROG.SSP_Index_Key in ('+@SSP_Index_Key+') '
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
		
	EXEC SP_EXECUTESQL @CountQuery,N'@TotalRecordsCount int output',@TotalRecordsCount output
END
