
CREATE PROCEDURE [dbo].[usp_STATSKEDPROG_SelectByParams_Service]
(
	@SessionID			VARCHAR(MAX),
	@SearchCriteria		VARCHAR(MAX),
	@IsEqual			bit,
	@IsFirst			bit,
	@IsExistingPage		bit,
	@ExistingPageNo		int,
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
	
		DECLARE @Query NVARCHAR(MAX),
				@SSPQuery NVARCHAR(MAX)
		
		DECLARE @StartRowNo AS BIGINT,@EndRowNo AS BIGINT
		
		Declare @RemainingIQCCKey		VARCHAR(MAX),
				@ProcessedIQCCKey		VARCHAR(MAX),
				--@NoOfSSPRecordsProcessed	int,
				@ProcessedPageNumber	int
				
		SET @StartRowNo = 1
		SET @EndRowNo = 1
				
		SET @SSPQuery = ' WITH IQMediaStatSkedProg_CTE  '
		SET @SSPQuery = @SSPQuery + ' AS ( '
	 
		SET @SSPQuery = @SSPQuery + 'Select  ROW_NUMBER() OVER (ORDER BY '
		
		IF (@SortField IS NOT NULL AND @SortField != '')
			BEGIN
			
				SET @SortField = REPLACE(@SortField,'-',' desc')
				set @SSPQuery = @SSPQuery + @SortField	
				
			END
		ELSE
			BEGIN
				SET @SSPQuery = @SSPQuery + ' IQ_Local_Air_Date '
			END
			
		
		SET @SSPQuery = @SSPQuery + 	') as RowNumber,
									 IQ_CC_Key
								from 
										STATSKEDPROG 												
								where 
										IQ_Local_Air_Date between '''+CONVERT(varchar(Max),@FromDate)+''' and '''+CONVERT(Varchar(Max),@ToDate)+''' and
										STATSKEDPROG.SSP_Index_Key in ('+@SSP_Index_Key+') '
					
		IF @Title120 IS NOT NULL AND @Title120 <> ''
			BEGIN
				SET @SSPQuery = @SSPQuery + ' AND (STATSKEDPROG.Title120  like (''%'+@Title120+'%''))'	
			END
			
		IF @Desc100 IS NOT NULL AND @Desc100 <> ''
			BEGIN
				SET @SSPQuery = @SSPQuery + ' AND (STATSKEDPROG.Desc100  like (''%'+@Desc100+'%''))'	
			END				
		
		IF @IQ_Time_Zone IS NOT NULL AND @IQ_Time_Zone <> ''
			BEGIN
				SET @SSPQuery = @SSPQuery + ' AND STATSKEDPROG.IQ_Time_Zone in('''+ @IQ_Time_Zone +''')'
			END
			
		SET @SSPQuery = @SSPQuery + ') '
	
		if(@IsEqual=0)
			begin			
				
				if(@IsFirst=1)
					begin
							delete 
							from
									AdvancedSearchServiceState
							Where
									SessionID=@SessionID
					end
							
					/*SET @StartRowNo = (((@SSPPageNumber * @PageSize) + 1)-@PageSize)
					SET @EndRowNo   = (@SSPPageNumber * @PageSize)*/
					
					SET @StartRowNo=((@PageNumber*@PageSize)-@PageSize)+1
					SET @EndRowNo=(@PageNumber*@PageSize)
							
					SET  @SSPQuery = @SSPQuery + ' SELECT * FROM IQMediaStatSkedProg_CTE Where RowNumber >=' + CAST(@StartRowNo as VARCHAR) + ' AND RowNumber <= ' + CAST(@EndRowNo as VARCHAR)
							
					EXEC SP_EXECUTESQL @SSPQuery
				
			end
		else
			begin
			
				if(@IsExistingPage=1)
					begin
			
							Select
									
									@ProcessedIQCCKey=COALESCE(@ProcessedIQCCKey + ', ', '') + 
											CAST(AdvancedSearchServiceState.IQCCKeyServed AS varchar(Max))
							From
									AdvancedSearchServiceState
							Where
									SessionID=@SessionID and
									AdvancedSearchServiceState.PageNo=@ExistingPageNo
								
							Set @Query='Select											
											IQ_CC_Key
								from 
										STATSKEDPROG 												
								Where
										IQ_CC_Key in ('+@ProcessedIQCCKey+')'
					
							EXEC SP_EXECUTESQL @Query
								
					end
				else
					begin
							SET @StartRowNo=((@PageNumber*@PageSize)-@PageSize)+1
							SET @EndRowNo=(@PageNumber*@PageSize)
									
							SET  @SSPQuery = @SSPQuery + ' SELECT * FROM IQMediaStatSkedProg_CTE Where RowNumber >=' + CAST(@StartRowNo as VARCHAR) + ' AND RowNumber <= ' + CAST(@EndRowNo as VARCHAR)
									
							EXEC SP_EXECUTESQL @SSPQuery
					end		
			end 
		
		-- For Count --
		
		DECLARE @CountQuery NVARCHAR(Max)
		
		 set @CountQuery='Select @TotalRecordsCount=count(iq_cc_key) from STATSKEDPROG where 
	    						IQ_Local_Air_Date between '''+CONVERT(varchar(Max),@FromDate)+''' and '''+CONVERT(Varchar(Max),@ToDate)+''' and
								STATSKEDPROG.SSP_Index_Key in ('+@SSP_Index_Key+')'
					
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
