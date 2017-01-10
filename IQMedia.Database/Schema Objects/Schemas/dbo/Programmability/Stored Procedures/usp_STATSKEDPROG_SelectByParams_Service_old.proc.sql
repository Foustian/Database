
CREATE PROCEDURE [dbo].[usp_STATSKEDPROG_SelectByParams_Service_old]
(
	@SessionID			VARCHAR(MAX),
	@SearchCriteria		VARCHAR(MAX),
	@IsEqual			bit,
	@IQ_Time_Zone		VARCHAR(250),	
	@SSP_Index_Key		VARCHAR(MAX),
	@FromDate			DATETIME,	
	@ToDate				DATETIME,	
	@Title120			VARCHAR(MAX),
	@Desc100			VARCHAR(MAX),	
	@PageNumber			INT,
	@PageSize			INT,
	@SortField			VARCHAR(250),
	@IsFirst			bit,
	@NoOfSSPRecordsProcessed	INT output,		
	@TotalRecordsCount	INT output	
)
AS
BEGIN
	SET NOCOUNT ON;  
	
		DECLARE @Query NVARCHAR(MAX),
				@SSPQuery NVARCHAR(MAX)
		
		DECLARE @StartRowNo AS BIGINT,@EndRowNo AS BIGINT
		
		Declare @RemainingRLGUID		VARCHAR(MAX),
				@ProcessedRLGUID		VARCHAR(MAX),
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
									Station_ID,IQ_Dma_Name,IQ_Dma_Num,IQ_Local_Air_Date,Title120,
									STATSKEDPROG.IQ_CC_Key,RL_GUIDS.RL_GUID 
								from 
										STATSKEDPROG 
												inner join RL_GUIDS 
													on STATSKEDPROG.IQ_CC_Key=RL_GUIDS.IQ_CC_Key 
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
					delete 
					from
							AdvancedSearchServiceState
					Where
							SessionID=@SessionID
							
					/*SET @StartRowNo = (((@SSPPageNumber * @PageSize) + 1)-@PageSize)
					SET @EndRowNo   = (@SSPPageNumber * @PageSize)*/
					
					SET @StartRowNo=(@NoOfSSPRecordsProcessed+1)
					SET @EndRowNo=(@NoOfSSPRecordsProcessed+@PageSize)
							
					SET @NoOfSSPRecordsProcessed=@EndRowNo
							
					SET  @SSPQuery = @SSPQuery + ' SELECT * FROM IQMediaStatSkedProg_CTE Where RowNumber >=' + CAST(@StartRowNo as VARCHAR) + ' AND RowNumber <= ' + CAST(@EndRowNo as VARCHAR)
							
					EXEC SP_EXECUTESQL @SSPQuery
				
			end
		else
			begin
			
				if(@IsFirst=1)
					begin
			
							Select
									@RemainingRLGUID=AdvancedSearchServiceState.GUIDRemaining,
									@ProcessedRLGUID=AdvancedSearchServiceState.GUIDServed,
									@NoOfSSPRecordsProcessed=AdvancedSearchServiceState.NoOfSSPRecordsProcessed,
									@ProcessedPageNumber=AdvancedSearchServiceState.PageNumber
							From
									AdvancedSearchServiceState
							Where
									SessionID=@SessionID and
									(PageNumber=@PageNumber or PageNumber=@PageNumber-1)
					
							if(@ProcessedPageNumber=@PageNumber)
								begin
								
									declare @TempRLGUIDs	varchar(Max)
									
									if (@RemainingRLGUID is not null and @RemainingRLGUID!='')
										begin
										
												set @TempRLGUIDs=@ProcessedRLGUID+','+@RemainingRLGUID						
										end						
									else
										begin
												
												set @TempRLGUIDs=@ProcessedRLGUID
										end
								
									Set @Query='Select
										Station_ID,IQ_Dma_Name,IQ_Dma_Num,IQ_Local_Air_Date,Title120,
											STATSKEDPROG.IQ_CC_Key,RL_GUIDS.RL_GUID 
										from 
												STATSKEDPROG 
														inner join RL_GUIDS 
															on STATSKEDPROG.IQ_CC_Key=RL_GUIDS.IQ_CC_Key 
										Where
												RL_GUIDS.RL_GUID in ('+@TempRLGUIDs+')'
												
									EXEC SP_EXECUTESQL @Query
								
								end
							else if(@ProcessedPageNumber=@PageNumber-1)
								begin				
										
										--SET @StartRowNo = (((@PageNumber * @PageSize) + 1)-@PageSize)
										--SET @EndRowNo   = (@PageNumber * @PageSize) 
									 
										SET @StartRowNo = (@NoOfSSPRecordsProcessed+1)
										SET @EndRowNo   = (@NoOfSSPRecordsProcessed+@PageSize)
										
										set @NoOfSSPRecordsProcessed=@EndRowNo								
									 
										/*SET @Query = ' WITH IQMediaStatSkedProg_CTE  '
										SET @Query = @Query + ' AS ( '
									 
										SET @Query = @Query + 'Select  ROW_NUMBER() OVER (ORDER BY '
										
										IF (@SortField IS NOT NULL AND @SortField != '')
											BEGIN
											
												SET @SortField = REPLACE(@SortField,'-',' desc')
												set @Query = @Query + @SortField	
												
											END
										ELSE
											BEGIN
												SET @Query = @Query + ' IQ_Local_Air_Date '
											END
											
										
										SET @Query = @Query + 	') as RowNumber,
																	Station_ID,IQ_Dma_Name,IQ_Dma_Num,IQ_Local_Air_Date,Title120,
																	STATSKEDPROG.IQ_CC_Key,RL_GUIDS.RL_GUID 
																from 
																		STATSKEDPROG 
																				inner join RL_GUIDS 
																					on STATSKEDPROG.IQ_CC_Key=RL_GUIDS.IQ_CC_Key 
																where 
																		IQ_Local_Air_Date between '''+CONVERT(varchar(Max),@FromDate)+''' and '''+CONVERT(Varchar(Max),@ToDate)+''' and
																		STATSKEDPROG.SSP_Index_Key in ('+@SSP_Index_Key+') '
													
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
											
										SET @Query = @Query + ') '*/					
										
										SET  @SSPQuery = @SSPQuery +'Select
										1 as RowNumber,Station_ID,IQ_Dma_Name,IQ_Dma_Num,IQ_Local_Air_Date,Title120,
											STATSKEDPROG.IQ_CC_Key,RL_GUIDS.RL_GUID
										from 
												STATSKEDPROG 
														inner join RL_GUIDS 
															on STATSKEDPROG.IQ_CC_Key=RL_GUIDS.IQ_CC_Key 
										Where
												RL_GUIDS.RL_GUID in ('+@RemainingRLGUID+')'
										
										SET  @SSPQuery = @SSPQuery + ' union all SELECT * FROM IQMediaStatSkedProg_CTE Where RowNumber >=' + CAST(@StartRowNo as VARCHAR) + ' AND RowNumber <= ' + CAST(@EndRowNo as VARCHAR)						
										
										/*SET @SSPQuery=@SSPQuery+' union all Select
										Station_ID,IQ_Dma_Name,IQ_Dma_Num,IQ_Local_Air_Date,Title120,
											STATSKEDPROG.IQ_CC_Key,RL_GUIDS.RL_GUID 
										from 
												STATSKEDPROG 
														inner join RL_GUIDS 
															on STATSKEDPROG.IQ_CC_Key=RL_GUIDS.IQ_CC_Key 
										Where
												RL_GUIDS.RL_GUID in ('+@RemainingRLGUID+')'*/
										print @SSPQuery
										
										EXEC SP_EXECUTESQL @SSPQuery
										
								end
						
					end
				else
					begin
					
							SET @StartRowNo = (@NoOfSSPRecordsProcessed+1)
							SET @EndRowNo   = (@NoOfSSPRecordsProcessed+@PageSize)
										
							set @NoOfSSPRecordsProcessed=@EndRowNo				
					
							SET  @SSPQuery = @SSPQuery + 'SELECT * FROM IQMediaStatSkedProg_CTE Where RowNumber >=' + CAST(@StartRowNo as VARCHAR) + ' AND RowNumber <= ' + CAST(@EndRowNo as VARCHAR)						
							
							exec sp_Executesql @SSPQuery
					end
			
			end 
		
		-- For Count --
		
		DECLARE @CountQuery NVARCHAR(Max)
		
		 set @CountQuery='Select @TotalRecordsCount=count(STATSKEDPROG.STATSKEDPROGKey) from STATSKEDPROG inner join RL_GUIDS on STATSKEDPROG.IQ_CC_Key=RL_GUIDS.IQ_CC_Key where 
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
