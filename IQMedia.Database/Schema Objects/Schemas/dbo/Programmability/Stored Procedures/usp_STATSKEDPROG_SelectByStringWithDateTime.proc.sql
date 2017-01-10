
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_STATSKEDPROG_SelectByStringWithDateTime] 
	-- Add the parameters for the stored procedure here
	@IQ_Time_Zone		VARCHAR(250),	
	@FromDate			DATETIME,	
	@ToDate				DATETIME,
	@IQ_Dma_Num			VARCHAR(MAX),
	@IQ_Class			VARCHAR(MAX),
	@IQ_Cat				VARCHAR(MAX),
	@Title120			VARCHAR(MAX),
	@Desc100			VARCHAR(MAX),
	@Station_Affil		VARCHAR(MAX),
	@PageNumber			INT,
	@PageSize			INT,
	@SortField			VARCHAR(250)	
	
AS
BEGIN
				-- SET NOCOUNT ON added to prevent extra result sets from
				-- interfering with SELECT statements.
				SET NOCOUNT ON;
				
				DECLARE @Query NVARCHAR(MAX)
				
				DECLARE @StartRowNo AS BIGINT,@EndRowNo AS BIGINT
				DECLARE @SortDirection AS INT
				
				SET @SortDirection = CHARINDEX('-',@SortField)
				
				SET @SortField = REPLACE(@SortField,'-','')
				
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
										SET @Query = @Query + ' CONVERT(datetime,CONVERT(varchar(Max),STATSKEDPROG.IQ_Local_Air_Date,101) + '' ''+ REPLACE(convert(varchar(Max),convert(decimal(4,2),(convert(decimal(6,2),STATSKEDPROG.IQ_Local_Air_Time)/convert(decimal(5,2),100)))),''.'','':'')+'':00'') '
									END
								ELSE
									BEGIN
										set @Query = @Query + @SortField	
									END
								
								IF @SortDirection > 0 
									BEGIN
										SET @Query = @Query + ' DESC '
									END
							END
						ELSE
							BEGIN
								SET @Query = @Query + ' Station_ID '
							END
							
						
						SET @Query = @Query + 	') as RowNumber,
												Station_ID,IQ_Dma_Name,IQ_Dma_Num,IQ_Local_Air_Date,IQ_Local_Air_Time,Title120,STATSKEDPROG.IQ_CC_Key,RL_GUIDS.RL_GUID from STATSKEDPROG inner join RL_GUIDS on STATSKEDPROG.IQ_CC_Key=RL_GUIDS.IQ_CC_Key where 
	    										CONVERT(datetime,CONVERT(varchar(Max),STATSKEDPROG.IQ_Local_Air_Date,101) + '' ''+ REPLACE(convert(varchar(Max),convert(decimal(4,2),(convert(decimal(6,2),STATSKEDPROG.IQ_Local_Air_Time)/convert(decimal(5,2),100)))),''.'','':'')+'':00'') between '''+CONVERT(varchar(Max),@FromDate)+''' and '''+CONVERT(Varchar(Max),@ToDate)+''' and
												STATSKEDPROG.IQ_Dma_Num in ('+@IQ_Dma_Num+') and
												STATSKEDPROG.IQ_Cat in ('+@IQ_Cat+') and
												STATSKEDPROG.IQ_Class in ('+@IQ_Class+') and
												STATSKEDPROG.Station_Affil in ('+@Station_Affil+') '
									
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
						
				
				
				
				
				-- For Count --
				
				DECLARE @CountQuery NVARCHAR(Max)
				
				 set @CountQuery='Select count(STATSKEDPROG.STATSKEDPROGKey) as TotalRowCount from STATSKEDPROG inner join RL_GUIDS on STATSKEDPROG.IQ_CC_Key=RL_GUIDS.IQ_CC_Key where 
			    						CONVERT(datetime,CONVERT(varchar(Max),STATSKEDPROG.IQ_Local_Air_Date,101) + '' ''+ REPLACE(convert(varchar(Max),convert(decimal(4,2),(convert(decimal(6,2),STATSKEDPROG.IQ_Local_Air_Time)/convert(decimal(5,2),100)))),''.'','':'')+'':00'') between '''+CONVERT(varchar(Max),@FromDate)+''' and '''+CONVERT(Varchar(Max),@ToDate)+''' and
										STATSKEDPROG.IQ_Dma_Num in ('+@IQ_Dma_Num+') and
										STATSKEDPROG.IQ_Cat in ('+@IQ_Cat+') and
										STATSKEDPROG.IQ_Class in ('+@IQ_Class+') and
										STATSKEDPROG.Station_Affil in ('+@Station_Affil+') '
							
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
					
				EXEC SP_EXECUTESQL @CountQuery
					
				--EXEC sp_executesql 
				--	@query = @CountQuery, 
				--	@params = N'@TotalRowCount INT OUTPUT', 
				--	@TotalRowCount = @TotalRowCount OUTPUT 
   
   END